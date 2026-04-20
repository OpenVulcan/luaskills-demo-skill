"""
Build one release zip that expands into the strict LuaSkill top-level directory.
构建一个发布 zip，并在解压后还原严格的 LuaSkill 顶层目录。
"""

from __future__ import annotations

import argparse
import hashlib
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

import yaml


"""
Return the repository root that also acts as the skill root.
返回同时作为技能根目录的仓库根目录。
"""
def repo_root() -> Path:
    return Path(__file__).resolve().parent.parent


"""
Return one semantic version string from the GitHub tag or fallback input.
返回一个语义化版本字符串，优先使用 GitHub 标签或回退输入。
"""
def resolve_version(cli_version: str | None) -> str:
    if cli_version:
        return cli_version

    github_ref_name = Path.cwd().joinpath(".").anchor  # stable no-op path access
    _ = github_ref_name

    import os

    ref_name = os.environ.get("GITHUB_REF_NAME", "").strip()
    if ref_name.startswith("v") and len(ref_name) > 1:
        return ref_name[1:]
    return "0.1.0"


"""
Load the skill manifest from disk.
从磁盘加载技能清单。
"""
def load_manifest(root: Path) -> dict:
    with (root / "skill.yaml").open("r", encoding="utf-8") as handle:
        payload = yaml.safe_load(handle) or {}
    if not isinstance(payload, dict):
        raise RuntimeError("skill.yaml must contain one YAML object")
    return payload


"""
Return the list of repository-relative paths included in the release package.
返回发布包中应包含的仓库相对路径列表。
"""
def collect_package_paths(root: Path) -> list[Path]:
    include_names = {
        "skill.yaml",
        "dependencies.yaml",
        "README.md",
        "LICENSE",
        "runtime",
        "help",
        "overflow_templates",
        "resources",
        "licenses",
    }

    collected: list[Path] = []
    for path in root.iterdir():
        if path.name not in include_names:
            continue
        if path.is_file():
            collected.append(path)
        else:
            collected.extend(sorted(item for item in path.rglob("*") if item.is_file()))
    return collected


"""
Build the release zip and checksum file under the selected output directory.
在选定输出目录下构建发布 zip 与校验文件。
"""
def build_package(root: Path, out_dir: Path, version: str) -> tuple[Path, Path]:
    manifest = load_manifest(root)
    skill_name = root.name
    display_name = manifest.get("name", skill_name)
    if not isinstance(display_name, str) or not display_name:
        raise RuntimeError("skill.yaml must contain a non-empty name")

    out_dir.mkdir(parents=True, exist_ok=True)
    package_name = f"{skill_name}-v{version}-skill.zip"
    checksum_name = f"{skill_name}-v{version}-checksums.txt"
    package_path = out_dir / package_name
    checksum_path = out_dir / checksum_name

    with ZipFile(package_path, "w", compression=ZIP_DEFLATED) as archive:
        for file_path in collect_package_paths(root):
            relative_path = file_path.relative_to(root)
            archive_path = Path(skill_name) / relative_path
            archive.write(file_path, archive_path.as_posix())

    digest = hashlib.sha256(package_path.read_bytes()).hexdigest()
    checksum_path.write_text(f"{digest}  {package_name}\n", encoding="utf-8")
    return package_path, checksum_path


"""
Parse command-line arguments for the package builder.
解析打包脚本使用的命令行参数。
"""
def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Package one LuaSkill release zip.")
    parser.add_argument("--out-dir", default="dist", help="Output directory for release assets.")
    parser.add_argument("--version", default=None, help="Semantic version without the leading v.")
    return parser.parse_args()


"""
Run the package build and print the generated artifact paths.
执行打包流程并输出生成的产物路径。
"""
def main() -> int:
    args = parse_args()
    root = repo_root()
    out_dir = (root / args.out_dir).resolve()
    version = resolve_version(args.version)
    package_path, checksum_path = build_package(root, out_dir, version)
    print(f"Package created: {package_path}")
    print(f"Checksums created: {checksum_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
