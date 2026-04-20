-- Return paged Markdown output and one skill-local overflow template hint.
-- 返回分页 Markdown 输出以及一个技能私有的超限模板提示。

--- Parse the requested section count and keep it within a safe demo range.
--- 解析请求的段落数量，并保持在安全的演示范围内。
--- @param args table|nil
--- @return integer
local function section_count(args)
  local raw_value = type(args) == "table" and tonumber(args.sections) or 12
  if not raw_value then
    return 12
  end

  local normalized = math.floor(raw_value)
  if normalized < 1 then
    return 1
  end
  if normalized > 40 then
    return 40
  end
  return normalized
end

--- Build one long Markdown document for host overflow handling tests.
--- 构造一份用于宿主超限处理测试的长 Markdown 文档。
--- @param count integer
--- @return string
local function build_document(count)
  local lines = {
    "# LuaSkills Overflow Demo",
    "",
    "This tool intentionally produces a long Markdown document.",
    "Use it to verify host-side paging, spill files, and local template resolution.",
    "",
  }

  for index = 1, count do
    lines[#lines + 1] = "## Section " .. tostring(index)
    lines[#lines + 1] = ""
    lines[#lines + 1] = "This is a repeated demo section used for paging behavior."
    lines[#lines + 1] = "It is intentionally verbose so the host can split the output into multiple chunks."
    lines[#lines + 1] = ""
  end

  return table.concat(lines, "\n")
end

--- Main tool entry for paged output demonstration.
--- 分页输出演示工具的主入口。
--- @param args table|nil
--- @return string, string, string
return function(args)
  local content = build_document(section_count(args))
  return content, vulcan.runtime.overflow_type.page, "demo-page.md"
end
