# luaskills-demo-skill

A complete demo LuaSkill repository for testing package installation, GitHub release packaging, version updates, uninstall behavior, and one no-op `rg` dependency.

## What this repository demonstrates

- the strict `skill.yaml` package layout
- a `dependencies.yaml` file with one skill-local `rg` dependency
- multiple runtime entries under `runtime/`
- help topics under `help/`
- one overflow template under `overflow_templates/`
- one resource file under `resources/`
- GitHub Actions workflows for validation and release packaging

## Skill package layout

```text
luaskills-demo-skill/
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
python .\scripts\package_skill.py --out-dir .\dist
```

## Release packaging

The release workflow produces:

- `<skill-id>-v<version>-skill.zip`
- `<skill-id>-v<version>-checksums.txt`

The zip file always expands to one top-level directory named exactly:

```text
luaskills-demo-skill/
```

## Notes

- Runtime output is intentionally English-only.
- Code comments inside source files follow the rule: English line first, Chinese line second.
- The repository root itself is the skill root, and the skill id is the directory name.
