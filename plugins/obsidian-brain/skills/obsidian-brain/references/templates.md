# Note & MOC Templates

Load this reference when creating new zettel notes or MOC entries.

## Zettel Note Template

```markdown
---
id: "{{YYYYMMDDHHmmss}}"
title: "{{declarative-title-in-english}}"
tags:
  - {{tag1}}
  - {{tag2}}
created: "{{YYYY-MM-DD}}"
source: claude-session
---

# {{declarative-title-in-english}}

{{content in Korean — explain the concept in your own words}}

## Related
- [[{{related-note-filename}}]] — {{relationship-type}} ({{brief reason in Korean}})
```

## MOC (Map of Contents) Template

```markdown
---
title: "{{Topic Name}}"
type: moc
updated: "{{YYYY-MM-DD}}"
---

# {{Topic Name}}

## Notes
- [[{{note-filename}}]] — {{brief one-line description}}
```

MOC rules:
- Keep under 25 items per MOC — split into sub-MOCs if larger
- MOCs are navigation, not content — annotations should be one-line descriptions
- One note can appear in multiple MOCs

## Filename Conventions

**Zettel notes**: `YYYYMMDDHHmmss-kebab-title.md`
- Example: `20260309143022-usetransition-defers-low-priority-updates.md`
- Batch collision: append sequential suffix `-01`, `-02` (zero-padded 2 digits)
- Sanitize: remove `/\:?*"<>|`, replace spaces with hyphens, lowercase, max 60 chars after timestamp

**MOC files**: `kebab-topic-name.md` in `2-maps/`
- Example: `2-maps/react-hooks.md`

## Title Guidelines

Titles must be **declarative phrases** that state the idea, not topic labels:

| Bad (topic label) | Good (declarative) |
|---|---|
| "useTransition" | "useTransition defers low-priority state updates" |
| "Rust lifetimes" | "Rust lifetimes ensure references never outlive their data" |
| "Docker volumes" | "Docker volumes persist data beyond container lifecycle" |

The atomicity test: if you cannot express the note's content as a single declarative title, it contains multiple ideas and should be split.

## Frontmatter Fields

### Required
| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Timestamp ID `"YYYYMMDDHHmmss"` |
| `title` | string | Declarative English title |
| `tags` | list | English tags, lowercase |
| `created` | string | `"YYYY-MM-DD"` |
| `source` | string | `claude-session` for archived notes |

### Optional (future)
| Field | Type | Description |
|-------|------|-------------|
| `updated` | string | Last modification date |
| `aliases` | list | Alternative titles for search |

## Relationship Types

Every `[[wikilink]]` in the Related section must include a relationship annotation:

| Type | Meaning | Example |
|------|---------|---------|
| `extends` | Deepens or elaborates | "Lifetime elision" extends "Rust lifetimes" |
| `prerequisite` | Must understand first | "Ownership" is prerequisite for "Borrowing" |
| `example` | Concrete instance | "useMemo caching" exemplifies "Memoization" |
| `contrast` | Opposing approach | "Composition" contrasts with "Inheritance" |
| `related` | General connection | "TS generics" related to "Rust generics" |

Format in notes:
```markdown
## Related
- [[rust-ownership]] — prerequisite (ownership 없이 lifetime 이해 불가)
- [[cpp-raii-pattern]] — contrast (C++의 같은 문제 접근법)
```

## Language Policy

- **Title**: English (declarative phrase)
- **Tags**: English, lowercase
- **Content**: Korean (자기 말로 이해한 것을 적음)
- **Related annotations**: relationship type in English, reason in Korean
