#!/bin/bash
# scaffold-plugin.sh — Interactive plugin scaffolding for kit
# Usage: bash scripts/scaffold-plugin.sh
#        curl -sSL https://raw.githubusercontent.com/hamsurang/kit/main/scripts/scaffold-plugin.sh | bash

set -euo pipefail

# ── Colors ────────────────────────────────────────────────────────────────────
if [ -t 1 ] && command -v tput >/dev/null 2>&1; then
  RED=$(tput setaf 1)
  GREEN=$(tput setaf 2)
  YELLOW=$(tput setaf 3)
  BLUE=$(tput setaf 4)
  BOLD=$(tput bold)
  RESET=$(tput sgr0)
else
  RED="" GREEN="" YELLOW="" BLUE="" BOLD="" RESET=""
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
info()    { printf "%s%s%s\n" "${BLUE}" "$*" "${RESET}"; }
success() { printf "%s%s%s\n" "${GREEN}" "$*" "${RESET}"; }
warn()    { printf "%s%s%s\n" "${YELLOW}" "$*" "${RESET}"; }
error()   { printf "%s%s%s\n" "${RED}" "$*" "${RESET}" >&2; }
bold()    { printf "%s%s%s\n" "${BOLD}" "$*" "${RESET}"; }

prompt() {
  local question="$1"
  local default="${2:-}"
  local answer
  if [ -n "$default" ]; then
    printf "%s [%s]: " "$question" "$default"
  else
    printf "%s: " "$question"
  fi
  if [ -t 0 ]; then
    read -r answer
  else
    answer=""
  fi
  if [ -z "$answer" ] && [ -n "$default" ]; then
    answer="$default"
  fi
  printf "%s" "$answer"
}

prompt_yn() {
  local question="$1"
  local default="${2:-n}"
  local answer
  if [ "$default" = "y" ]; then
    printf "%s [Y/n]: " "$question"
  else
    printf "%s [y/N]: " "$question"
  fi
  if [ -t 0 ]; then
    read -r answer
  else
    answer=""
  fi
  answer="${answer:-$default}"
  case "$answer" in
    [Yy]*) return 0 ;;
    *)     return 1 ;;
  esac
}

# Reject shell metacharacters from free-text inputs to prevent heredoc injection
sanitize_text() {
  local value="$1"
  local field="$2"
  # Reject backtick and $( command substitution sequences
  if printf "%s" "$value" | grep -qE '`|\$\('; then
    error "Invalid characters in $field: backticks and \$() are not allowed."
    return 1
  fi
  printf "%s" "$value"
}

# ── Context Detection ─────────────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd || pwd)"
REPO_ROOT=""

# Check if we're in a kit repo
if [ -d "$SCRIPT_DIR/../plugins" ]; then
  REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
elif [ -d "$(pwd)/plugins" ]; then
  REPO_ROOT="$(pwd)"
fi

if [ -z "$REPO_ROOT" ]; then
  warn "Could not find a kit repo (no plugins/ directory found)."
  warn "Cloning kit to ./kit/ ..."
  if command -v git >/dev/null 2>&1; then
    git clone https://github.com/hamsurang/kit kit
    REPO_ROOT="$(pwd)/kit"
  else
    error "git is not installed. Please clone hamsurang/kit manually."
    exit 2
  fi
fi

PLUGINS_DIR="$REPO_ROOT/plugins"

# ── Banner ────────────────────────────────────────────────────────────────────
printf "\n"
bold "  kit Plugin Scaffolder"
info "  github.com/hamsurang/kit"
printf "\n"

# ── Collect Inputs ────────────────────────────────────────────────────────────

# Plugin name (validated: kebab-case only, max 50 chars)
while true; do
  PLUGIN_NAME=$(prompt "Plugin name (kebab-case, e.g. my-plugin)")
  if [ -z "$PLUGIN_NAME" ]; then
    error "Plugin name is required."
    continue
  fi
  if ! printf "%s" "$PLUGIN_NAME" | grep -qE '^[a-z0-9-]+$'; then
    error "Invalid name '$PLUGIN_NAME'. Use only lowercase letters, numbers, and hyphens."
    continue
  fi
  if [ "${#PLUGIN_NAME}" -gt 50 ]; then
    error "Plugin name must be 50 characters or fewer (currently ${#PLUGIN_NAME})."
    continue
  fi
  if [ -d "$PLUGINS_DIR/$PLUGIN_NAME" ]; then
    error "Plugin '$PLUGIN_NAME' already exists at plugins/$PLUGIN_NAME/."
    continue
  fi
  break
done

# Display name (derived from plugin name — safe, no user injection)
DISPLAY_NAME=$(printf "%s" "$PLUGIN_NAME" | sed 's/-/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) substr($i,2)} 1')

# Description (free text — sanitized, max 200 chars)
while true; do
  DESCRIPTION=$(prompt "Description (one sentence, max 200 chars)")
  if [ -z "$DESCRIPTION" ]; then
    error "Description is required."
    continue
  fi
  if [ "${#DESCRIPTION}" -gt 200 ]; then
    error "Description must be 200 characters or fewer (currently ${#DESCRIPTION})."
    continue
  fi
  sanitize_text "$DESCRIPTION" "description" || continue
  break
done

# Author name (free text — sanitized)
GIT_AUTHOR=$(git config user.name 2>/dev/null || true)
while true; do
  AUTHOR_NAME=$(prompt "Author name" "$GIT_AUTHOR")
  if [ -z "$AUTHOR_NAME" ]; then
    error "Author name is required."
    continue
  fi
  sanitize_text "$AUTHOR_NAME" "author name" || continue
  break
done

# Author GitHub username (alphanumeric + hyphens only)
GIT_EMAIL=$(git config user.email 2>/dev/null || true)
GIT_GITHUB="${GIT_EMAIL%%@*}"
while true; do
  AUTHOR_GITHUB=$(prompt "GitHub username" "$GIT_GITHUB")
  if [ -z "$AUTHOR_GITHUB" ]; then
    error "GitHub username is required."
    continue
  fi
  if ! printf "%s" "$AUTHOR_GITHUB" | grep -qE '^[a-zA-Z0-9][a-zA-Z0-9-]*$'; then
    error "Invalid GitHub username '$AUTHOR_GITHUB'. Use only letters, numbers, and hyphens."
    continue
  fi
  break
done

# License (SPDX identifier — alphanumeric + hyphens + dots)
while true; do
  LICENSE=$(prompt "License (SPDX identifier)" "MIT")
  if ! printf "%s" "$LICENSE" | grep -qE '^[a-zA-Z0-9.+-]+$'; then
    error "Invalid license '$LICENSE'. Use a valid SPDX identifier (e.g. MIT, Apache-2.0)."
    continue
  fi
  break
done

# Components
printf "\nSelect components to include:\n"
INCLUDE_COMMANDS=false
INCLUDE_SKILLS=false
INCLUDE_AGENTS=false
INCLUDE_MCP=false

if prompt_yn "  commands/ (slash commands, e.g. /my-plugin:do-thing)" "y"; then
  INCLUDE_COMMANDS=true
fi
if prompt_yn "  skills/   (auto-invoked context skills)" "n"; then
  INCLUDE_SKILLS=true
fi
if prompt_yn "  agents/   (agent definitions)" "n"; then
  INCLUDE_AGENTS=true
fi
if prompt_yn "  .mcp.json (MCP server integration)" "n"; then
  INCLUDE_MCP=true
fi

# ── Confirm ───────────────────────────────────────────────────────────────────
printf "\n"
bold "Plugin summary:"
printf "  Name:     %s\n" "$PLUGIN_NAME"
printf "  Display:  %s\n" "$DISPLAY_NAME"
printf "  Desc:     %s\n" "$DESCRIPTION"
printf "  Author:   %s (@%s)\n" "$AUTHOR_NAME" "$AUTHOR_GITHUB"
printf "  License:  %s\n" "$LICENSE"
printf "  Includes:"
$INCLUDE_COMMANDS && printf " commands"
$INCLUDE_SKILLS   && printf " skills"
$INCLUDE_AGENTS   && printf " agents"
$INCLUDE_MCP      && printf " mcp"
printf "\n\n"

if ! prompt_yn "Create plugin?" "y"; then
  warn "Aborted."
  exit 1
fi

# ── Create Files ──────────────────────────────────────────────────────────────
PLUGIN_DIR="$PLUGINS_DIR/$PLUGIN_NAME"

info "\nCreating plugin files..."

mkdir -p "$PLUGIN_DIR/.claude-plugin"

# plugin.json — generated via python3 for safe JSON encoding of all user input
# This prevents JSON corruption and shell injection from special chars in free-text fields.
if command -v python3 >/dev/null 2>&1; then
  python3 - "$PLUGIN_NAME" "$DESCRIPTION" "$AUTHOR_NAME" "$AUTHOR_GITHUB" \
    "$LICENSE" \
    "$INCLUDE_COMMANDS" "$INCLUDE_SKILLS" "$INCLUDE_AGENTS" "$INCLUDE_MCP" \
    "$PLUGIN_DIR/.claude-plugin/plugin.json" <<'PYEOF'
import json, sys
name, desc, author_name, author_github, license_, \
  inc_commands, inc_skills, inc_agents, inc_mcp, outfile = sys.argv[1:]
data = {
    "name": name,
    "version": "1.0.0",
    "description": desc,
    "author": {"name": author_name, "github": author_github},
    "license": license_,
    "keywords": []
}
if inc_commands == "true": data["commands"] = "./commands/"
if inc_skills  == "true": data["skills"]   = "./skills/"
if inc_agents  == "true": data["agents"]   = "./agents/"
if inc_mcp     == "true": data["mcpServers"] = "./.mcp.json"
with open(outfile, 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write('\n')
PYEOF
else
  # Fallback: all variables here are validated/sanitized above (no injection risk)
  {
    printf '{\n'
    printf '  "name": "%s",\n' "$PLUGIN_NAME"
    printf '  "version": "1.0.0",\n'
    printf '  "description": "%s",\n' "$DESCRIPTION"
    printf '  "author": {\n    "name": "%s",\n    "github": "%s"\n  },\n' "$AUTHOR_NAME" "$AUTHOR_GITHUB"
    printf '  "license": "%s",\n' "$LICENSE"
    if $INCLUDE_COMMANDS; then printf '  "commands": "./commands/",\n'; fi
    if $INCLUDE_SKILLS;   then printf '  "skills": "./skills/",\n';   fi
    if $INCLUDE_AGENTS;   then printf '  "agents": "./agents/",\n';   fi
    if $INCLUDE_MCP;      then printf '  "mcpServers": "./.mcp.json",\n'; fi
    printf '  "keywords": []\n'
    printf '}\n'
  } > "$PLUGIN_DIR/.claude-plugin/plugin.json"
fi

# README.md — uses quoted heredoc for static template; variables printed separately
cat > "$PLUGIN_DIR/README.md" <<'MDEOF'
# DISPLAY_NAME_PLACEHOLDER

> DESCRIPTION_PLACEHOLDER

## Installation

```bash
INSTALL_CMD_PLACEHOLDER
```

## Usage

<!-- Describe how to use the plugin here -->

## License

LICENSE_PLACEHOLDER
MDEOF
# Replace placeholders safely using printf
sed -i.bak \
  -e "s|DISPLAY_NAME_PLACEHOLDER|$DISPLAY_NAME|g" \
  -e "s|DESCRIPTION_PLACEHOLDER|$DESCRIPTION|g" \
  -e "s|INSTALL_CMD_PLACEHOLDER|claude plugin install $PLUGIN_NAME\@hamsurang\/kit|g" \
  -e "s|LICENSE_PLACEHOLDER|$LICENSE|g" \
  "$PLUGIN_DIR/README.md" && rm -f "$PLUGIN_DIR/README.md.bak"

# commands/
if $INCLUDE_COMMANDS; then
  mkdir -p "$PLUGIN_DIR/commands"
  cat > "$PLUGIN_DIR/commands/$PLUGIN_NAME.md" <<'CMDEOF'
---
description: DESCRIPTION_PLACEHOLDER
argument-hint: [args]
allowed-tools: [Read, Glob, Grep]
---

# DISPLAY_NAME_PLACEHOLDER

$ARGUMENTS

## Instructions

<!-- Describe what this command should do -->

1. Step one
2. Step two
3. Report results
CMDEOF
  sed -i.bak \
    -e "s|DESCRIPTION_PLACEHOLDER|$DESCRIPTION|g" \
    -e "s|DISPLAY_NAME_PLACEHOLDER|$DISPLAY_NAME|g" \
    "$PLUGIN_DIR/commands/$PLUGIN_NAME.md" && rm -f "$PLUGIN_DIR/commands/$PLUGIN_NAME.md.bak"
fi

# skills/
if $INCLUDE_SKILLS; then
  mkdir -p "$PLUGIN_DIR/skills/$PLUGIN_NAME-skill"
  cat > "$PLUGIN_DIR/skills/$PLUGIN_NAME-skill/SKILL.md" <<'SKILLEOF'
---
name: PLUGIN_NAME_PLACEHOLDER-skill
description: >
  This skill should be used when the user asks about "<!-- trigger topic -->".
  <!-- Describe additional trigger conditions -->
---

# DISPLAY_NAME_PLACEHOLDER Skill

## When This Skill Activates

<!-- Describe the trigger conditions in detail -->

## Instructions

<!-- What should Claude do when this skill activates? -->
SKILLEOF
  sed -i.bak \
    -e "s|PLUGIN_NAME_PLACEHOLDER|$PLUGIN_NAME|g" \
    -e "s|DISPLAY_NAME_PLACEHOLDER|$DISPLAY_NAME|g" \
    "$PLUGIN_DIR/skills/$PLUGIN_NAME-skill/SKILL.md" && rm -f "$PLUGIN_DIR/skills/$PLUGIN_NAME-skill/SKILL.md.bak"
fi

# agents/
if $INCLUDE_AGENTS; then
  mkdir -p "$PLUGIN_DIR/agents"
  cat > "$PLUGIN_DIR/agents/$PLUGIN_NAME-agent.md" <<'AGENTEOF'
---
name: PLUGIN_NAME_PLACEHOLDER-agent
description: >
  Use this agent when <!-- describe the use case -->.
---

# DISPLAY_NAME_PLACEHOLDER Agent

<!-- Agent system prompt goes here -->

## Role

You are a specialized agent for <!-- describe purpose -->.

## Instructions

1. <!-- Step one -->
2. <!-- Step two -->
AGENTEOF
  sed -i.bak \
    -e "s|PLUGIN_NAME_PLACEHOLDER|$PLUGIN_NAME|g" \
    -e "s|DISPLAY_NAME_PLACEHOLDER|$DISPLAY_NAME|g" \
    "$PLUGIN_DIR/agents/$PLUGIN_NAME-agent.md" && rm -f "$PLUGIN_DIR/agents/$PLUGIN_NAME-agent.md.bak"
fi

# .mcp.json — PLUGIN_NAME is validated as ^[a-z0-9-]+$ so safe to interpolate
if $INCLUDE_MCP; then
  PLUGIN_NAME_UPPER=$(printf "%s" "$PLUGIN_NAME" | tr '[:lower:]-' '[:upper:]_')
  cat > "$PLUGIN_DIR/.mcp.json" <<MCPEOF
{
  "mcpServers": {
    "$PLUGIN_NAME": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@scope/$PLUGIN_NAME"],
      "env": {
        "API_KEY": "\${${PLUGIN_NAME_UPPER}_API_KEY}"
      }
    }
  }
}
MCPEOF
fi

# ── Success ───────────────────────────────────────────────────────────────────
printf "\n"
success "Plugin '$PLUGIN_NAME' created at plugins/$PLUGIN_NAME/"
printf "\nFiles created:\n"
find "$PLUGIN_DIR" -type f | sed "s|$REPO_ROOT/||" | sort | while read -r f; do
  printf "  %s\n" "$f"
done

printf "\n"
bold "Next steps:"
printf "  1. Edit the generated files in plugins/%s/\n" "$PLUGIN_NAME"
printf "  2. See docs/contributors/plugin-spec.md for format details\n"
printf "  3. Commit and open a PR:\n"
printf "\n"
printf "       cd %s\n" "$REPO_ROOT"
printf "       git checkout -b add-%s\n" "$PLUGIN_NAME"
printf "       git add plugins/%s/\n" "$PLUGIN_NAME"
printf "       git commit -m \"feat: add %s plugin\"\n" "$PLUGIN_NAME"
printf "       gh pr create\n"
printf "\n"
info "  Contribution guide: docs/contributors/contributing.md"
info "  Plugin spec:        docs/contributors/plugin-spec.md"
printf "\n"
