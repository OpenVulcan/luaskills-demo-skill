-- Report the expected local rg dependency path and optionally run rg --version.
-- 报告预期的本地 rg 依赖路径，并在需要时执行 rg --version。

--- Return the current runtime path separator.
--- 返回当前运行时使用的路径分隔符。
--- @return string
local function path_separator()
  return package.config and package.config:sub(1, 1) or "/"
end

--- Join path fragments with the host runtime helper when available.
--- 在可用时使用宿主运行时辅助函数拼接路径片段。
--- @param ...
--- @return string
local function join_path(...)
  local join = vulcan and vulcan.path and vulcan.path.join
  if type(join) == "function" then
    return join(...)
  end

  local parts = { ... }
  return table.concat(parts, path_separator())
end

--- Return the parent directory of one path string.
--- 返回一个路径字符串的父目录。
--- @param path_text string
--- @return string
local function parent_dir(path_text)
  local separator = path_separator()
  local normalized = tostring(path_text or ""):gsub("[/\\\\]+", separator)
  return normalized:match("^(.*)" .. separator .. "[^" .. separator .. "]+$") or normalized
end

--- Return the normalized LuaSkills platform key used by the demo manifest.
--- 返回当前演示清单使用的标准 LuaSkills 平台键。
--- @return string
local function current_platform_key()
  local separator = path_separator()
  local is_windows = separator == "\\"
  local jit_os = type(jit) == "table" and jit.os or nil
  local jit_arch = type(jit) == "table" and jit.arch or nil

  if is_windows then
    if jit_arch == "arm64" then
      return "windows-arm64"
    end
    return "windows-x64"
  end

  if jit_os == "OSX" then
    if jit_arch == "arm64" then
      return "macos-arm64"
    end
    return "macos-x64"
  end

  if jit_arch == "arm64" then
    return "linux-arm64"
  end
  return "linux-x64"
end

--- Build the expected local rg binary path from the skill-local dependency layout.
--- 按技能私有依赖布局构造预期的本地 rg 二进制路径。
--- @return string
local function expected_rg_binary()
  local skill_dir = vulcan and vulcan.context and vulcan.context.skill_dir or ""
  local skills_root = parent_dir(skill_dir)
  local runtime_root = parent_dir(skills_root)
  local platform_key = current_platform_key()
  local binary_name = platform_key:match("^windows") and "rg.exe" or "rg"

  return join_path(
    runtime_root,
    "dependencies",
    "tools",
    "luaskills-demo-skill",
    "rg",
    "14.1.1",
    platform_key,
    "bin",
    binary_name
  )
end

--- Try to execute rg --version from the expected local dependency path.
--- 尝试从预期的本地依赖路径执行 rg --version。
--- @param rg_path string
--- @return table|nil
local function maybe_run_rg_version(rg_path)
  local result = vulcan.process.exec({
    program = rg_path,
    args = { "--version" },
    timeout_ms = 5000,
  })

  return {
    success = result.success == true,
    code = result.code,
    stdout = result.stdout,
    stderr = result.stderr,
    timed_out = result.timed_out == true,
  }
end

--- Main tool entry for the optional rg dependency demonstration.
--- 可选 rg 依赖演示工具的主入口。
--- @param args table|nil
--- @return string
return function(args)
  local rg_path = expected_rg_binary()
  local exists = vulcan.fs.exists(rg_path)
  local run_version = type(args) == "table" and args.run_version == true

  local payload = {
    ok = true,
    dependency = "rg",
    declared_version = "14.1.1",
    install_scope = "skill",
    expected_path = rg_path,
    exists = exists,
    note = "This dependency is intentionally optional and exists only for package lifecycle demonstrations.",
  }

  if exists and run_version then
    payload.version_check = maybe_run_rg_version(rg_path)
  end

  return vulcan.json.encode(payload)
end
