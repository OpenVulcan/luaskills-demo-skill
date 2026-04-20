# luaskills-demo-skill

A complete demo LuaSkill repository for testing package installation, GitHub release packaging, version updates, uninstall behavior, and one no-op `rg` dependency.

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
python .\scripts\package_skill.py
```

The default packaging script generates two artifacts under `dist/`:

- `<skill-id>-v<version>-skill.zip`
- `<skill-id>-v<version>-checksums.txt`

For non-GitHub distribution channels, you can optionally generate one URL-install metadata file:

```powershell
python .\scripts\package_skill.py --emit-source-yaml
```

That optional command adds:

- `<skill-id>-v<version>-source.yaml`

If you do not pass `--base-url`, the generated `source.yaml` uses a placeholder URL that you can edit manually for local or self-hosted tests.

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
.\scripts\tag_release.ps1 0.1.0
```

Or on Unix-like shells:

```bash
python ./scripts/validate_skill.py
python ./scripts/package_skill.py
./scripts/tag_release.sh 0.1.0
```

The helper scripts normalize the version into a `vX.Y.Z` tag and push it to `origin`.
The packaging script treats `skill.yaml.version` as the release version source of truth and rejects mismatched tag or CLI versions.
GitHub release publication only uploads the zip package and checksum file.

If you want to generate source metadata for non-GitHub channels, you can pass a base URL together with the explicit source-yaml flag:

```powershell
python .\scripts\package_skill.py --emit-source-yaml --base-url https://example.com/releases
```

## Fork and publish flow

Forking this repository is supported, but a forked repository name change alone does not rename the LuaSkill itself.

If you want to publish your own skill based on this demo, use this recommended flow:

1. Fork the repository.
2. Optionally rename the GitHub repository.
3. Rename the local repository root directory to the final skill id you want to publish.
4. Update `skill.yaml`:
   - set `name` to your display name
   - set `version` to your first release version
5. Update runtime, help, README, and resource files if they still mention `luaskills-demo-skill`.
6. Run local validation:

```powershell
python .\scripts\validate_skill.py
python .\scripts\package_skill.py
```

7. Tag and push your release:

```powershell
.\scripts\tag_release.ps1 0.1.0
```

Important notes:

- The LuaSkill runtime identity comes from the packaged top-level directory name, not from the GitHub repository name alone.
- If you only rename the GitHub repository but keep the packaged skill directory as `luaskills-demo-skill`, the installed `skill_id` still remains `luaskills-demo-skill`.
- Always make sure the package root directory, release asset names, and documentation all match your final skill id before publishing.

## Release packaging

After the tag is pushed, the release workflow produces:

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
- The optional `source.yaml` is reserved for URL-based install flows, self-hosted package endpoints, and future skillhub-compatible metadata responses rather than GitHub release publication.
