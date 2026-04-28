# demo-skill

A complete demo LuaSkill repository at `LuaSkills/demo-skill` for testing package installation, GitHub release packaging, version updates, uninstall behavior, and one no-op `rg` dependency.

## LuaSkill development manual

For LuaSkill runtime APIs, package rules, and development conventions, see the official development manuals:

- [Lua Skill Development Manual (English)](https://github.com/LuaSkills/luaskills/blob/main/docs/skill-development.md)
- [Lua Skill 开发手册（中文）](https://github.com/LuaSkills/luaskills/blob/main/docs/zh-CN/skill-development.md)

## What this repository demonstrates

- the strict `skill.yaml` package layout
- a required semantic `version` field in `skill.yaml`
- a `dependencies.yaml` file with one skill-local `rg` dependency
- multiple runtime entries under `runtime/`
- help topics under `help/`
- one overflow template under `overflow_templates/`
- one resource file under `resources/`
- GitHub Actions workflows for validation and release packaging
- a tag-driven release workflow that only builds packages after a release tag is pushed

## Skill package layout

```text
demo-skill/
├─ skill.yaml
├─ dependencies.yaml
├─ runtime/
├─ help/
├─ overflow_templates/
├─ resources/
├─ licenses/
├─ scripts/
└─ .github/workflows/
```

## Demo tools

- `demo-status`
  - returns stable runtime diagnostics for installation and lifecycle testing
- `rg-check`
  - reports the expected local `rg` dependency path and runs `rg --version` when the file exists
- `overflow-demo`
  - returns paged output and a skill-local overflow template hint

## Demo dependency

The repository declares one skill-local `rg` dependency in `dependencies.yaml`.

The dependency is intentionally non-essential:

- it is useful for testing install and uninstall behavior
- it is safe to skip when network downloads are disabled
- the `rg-check` tool can still return a diagnostic report when `rg` is missing

## Validation

This repository includes one validation workflow and one release workflow.

Local validation:

```powershell
python .\scripts\validate_skill.py
python .\scripts\package_skill.py
```

The default packaging script generates two artifacts under `dist/`:

- `<skill-id>-v<version>-skill.zip`
- `<skill-id>-v<version>-checksums.txt`

For URL-based install and update tests, you can optionally generate one source metadata file:

```powershell
python .\scripts\package_skill.py --emit-source-yaml
```

That optional command adds:

- `<skill-id>-v<version>-source.yaml`

If you do not pass `--base-url`, the generated `source.yaml` points to the matching `LuaSkills/demo-skill` GitHub release asset names for the current manifest version.

GitHub validation:

- pushes to `main` do not trigger GitHub Actions automatically
- pull requests only run structure validation
- no release package is published from branch pushes

## Tag-based release flow

This repository uses a tag-driven release flow.

Only a pushed tag that matches `v*` triggers package build and GitHub release publication.
The tag must match `skill.yaml.version`.

Recommended local release steps:

```powershell
python .\scripts\validate_skill.py
python .\scripts\package_skill.py
.\scripts\tag_release.ps1 0.1.3
```

Or on Unix-like shells:

```bash
python ./scripts/validate_skill.py
python ./scripts/package_skill.py
./scripts/tag_release.sh 0.1.3
```

The helper scripts normalize the version into a `vX.Y.Z` tag and push it to `origin`.
The packaging script treats `skill.yaml.version` as the release version source of truth and rejects mismatched tag or CLI versions.
GitHub release publication only uploads the zip package and checksum file.

If you want to generate source metadata with an explicit release asset URL, pass a base URL together with the source-yaml flag:

```powershell
python .\scripts\package_skill.py --emit-source-yaml --base-url https://github.com/LuaSkills/demo-skill/releases/download/v0.1.3
```

## Use this demo as your own skill repository

This repository is intended to be forked as the starting point for a real LuaSkill package.

Recommended first-time setup:

1. Fork this repository from GitHub.
2. In the fork form, set `Repository name` to your final skill id.
   - The repository name should match `^[a-z]([a-z0-9-]*[a-z0-9])?$`.
   - Use lowercase letters, numbers, and single hyphen-separated words, such as `my-skill` or `demo-tools`.
3. Set `Description` to a short description of your own skill.
4. Click `Create fork`.
5. Open the forked repository settings and choose `Leave fork network` so the new repository becomes an independent skill repository.
6. Clone your own repository:

```powershell
git clone https://github.com/<your-org-or-user>/<your-skill-id>.git
cd <your-skill-id>
```

7. Start replacing the demo content with your own skill implementation.
8. Update `skill.yaml`:
   - set `name` to your display name
   - set `version` to your first release version
9. Update runtime, help, README, and resource files if they still mention `demo-skill` or `LuaSkills/demo-skill`.
10. Run local validation:

```powershell
python .\scripts\validate_skill.py
python .\scripts\package_skill.py
```

11. Tag and push your release:

```powershell
.\scripts\tag_release.ps1 0.1.3
```

Important notes:

- The LuaSkill runtime identity comes from the packaged top-level directory name, not from the GitHub repository name alone.
- If you only rename the GitHub repository but keep the packaged skill directory as `demo-skill`, the installed `skill_id` still remains `demo-skill`.
- Always make sure the package root directory, release asset names, and documentation all match your final skill id before publishing.

## Release packaging

After the tag is pushed, the release workflow produces:

- `<skill-id>-v<version>-skill.zip`
- `<skill-id>-v<version>-checksums.txt`

The zip file always expands to one top-level directory named exactly:

```text
demo-skill/
```

## Notes

- Runtime output is intentionally English-only.
- Code comments inside source files follow the rule: English line first, Chinese line second.
- The repository root itself is the skill root, and the skill id is the directory name.
- The optional `source.yaml` is reserved for URL-based install flows, self-hosted package endpoints, and future skillhub-compatible metadata responses rather than GitHub release publication.
