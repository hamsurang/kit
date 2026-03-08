# Vault Setup Reference

Load this reference when setting up the vault for the first time or when vault path resolution is needed.

## Vault Path Resolution

Resolve the vault path in this order. Stop at the first success:

1. **User override**: Read `~/.claude/obsidian-brain/config.json` — if `vaultPath` exists and the directory is valid, use it
2. **obsidian-cli**: Run `obsidian-cli print-default --path-only` — if installed and a default vault is set
3. **Obsidian app config**: Read the Obsidian config file for the default vault path:
   - macOS: `~/Library/Application Support/obsidian/obsidian.json`
   - Linux: `~/.config/obsidian/obsidian.json`
   - Windows: `%APPDATA%/obsidian/obsidian.json`
4. **Ask user**: If all above fail, ask: "Obsidian vault 경로를 알려주세요"
   - Validate the path exists as a directory
   - Save to `~/.claude/obsidian-brain/config.json`

### Config File Structure

```json
{
  "vaultPath": "/Users/username/my-vault",
  "language": "ko"
}
```

Create `~/.claude/obsidian-brain/` directory if it doesn't exist.
If the directory is not writable, use the resolved path in-memory for the current session only.

### Path Validation

After resolving the path:
1. Verify the directory exists: `ls <vaultPath>`
2. If the directory does not exist, inform the user: "vault 경로가 변경된 것 같습니다. 새 경로를 알려주세요"
3. Clear the stored config and re-run resolution from step 4

## Vault Structure Bootstrap

Check if the required directories exist inside the vault:

```
<vaultPath>/
├── 0-inbox/
├── 1-zettelkasten/
├── 2-maps/
└── templates/
```

If any are missing, propose creation:

```
다음 디렉토리를 생성하겠습니다:
- 0-inbox/       (새 노트가 처음 저장되는 곳)
- 1-zettelkasten/ (정리된 원자적 노트)
- 2-maps/        (주제별 MOC 인덱스 노트)
- templates/     (노트 템플릿)

진행할까요?
```

Wait for user confirmation before creating directories.

## Cold Start (Empty Vault)

When the vault is empty (no MOCs in `2-maps/`):

1. Skip MOC scanning — there is nothing to scan
2. After the first note is saved to `0-inbox/`, **propose creating the first MOC**:

```
첫 번째 노트가 저장되었습니다. 이 주제에 대한 MOC(Map of Contents)를
만들어서 노트를 연결할까요?

MOC는 주제별 인덱스 역할을 하며, 나중에 관련 노트를 쉽게 찾을 수 있게 합니다.
```

3. If approved, create the MOC in `2-maps/` using the MOC template (see `references/templates.md`)
4. Add the first note's wikilink to the new MOC

This ensures the first use demonstrates the full value of the Zettelkasten system.
