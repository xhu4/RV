local function get_package(path)
  local package_dir = vim.fs.find("package.xml", { upward = true, type = "file", path = path })[1]
  local package_name = vim.fs.basename(vim.fs.dirname(package_dir))
  return package_name
end

return {
  generator = function()
    local file_path = vim.fn.expand("%:p")
    local pkg = get_package(file_path)
    if not pkg then
      vim.notify("No package found for " .. file_path, vim.log.levels.ERROR)
      return
    end

    local commands = { "b.pkg", "b.upto", "t.pkg" }
    local result = {}
    for _, cmd in ipairs(commands) do
      local full_cmd = cmd .. " " .. pkg
      table.insert(result, {
        name = full_cmd,
        builder = function()
          return {
            cmd = { "bash", "-lc", full_cmd },
            components = { { "on_output_quickfix", open = false, set_diagnostics = true }, "default" },
            name = full_cmd,
          }
        end,
      })
    end
    return result
  end,
}
