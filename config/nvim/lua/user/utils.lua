local M = {}

local is_first_child = function(node, ignore_list)
  if node == nil then
    return false
  end
  local prev = node:prev_sibling()
  while prev ~= nil do
    if not vim.list_contains(ignore_list, prev:type()) then
      return false
    end
    prev = prev:prev_sibling()
  end
  return true
end

M.has_copyright_header = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr)
  if parser == nil then
    vim.notify(string.format("No parser found for %s", vim.fn.bufname(bufnr)))
    return
  end
  local tree = parser:parse()[1]
  local query = vim.treesitter.query.parse(
    parser:lang(),
    [[
    ((comment) @copyright.comment
    (#match? @copyright.comment "[Cc]opyright"))
  ]]
  )
  for _, node in query:iter_captures(tree:root(), bufnr) do
    return is_first_child(node, { "comment" })
  end
  return false
end

M.has_pragma_once = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr)
  local tree = parser and parser:parse()[1]
  if not (parser and tree) then
    vim.notify(string.format("No parser found for %s", vim.fn.bufname(bufnr)))
    return false
  end
  local query = vim.treesitter.query.parse(
    parser:lang(),
    [[
    (preproc_call 
      (preproc_directive) @directive
      (preproc_arg) @argument
      (#eq? @directive "#pragma")
      (#eq? @argument "once")
    ) @parent
    ]]
  )
  for id, node in query:iter_captures(tree:root(), bufnr) do
    local name = query.captures[id] -- name of the capture in the query
    if name == "parent" then
      return is_first_child(node, { "comment", "preproc_call" })
    end
  end
  return false
end

M.get_header_last_line = function(bufnr)
  local parser = vim.treesitter.get_parser(bufnr)
  local tree = parser and parser:parse()[1]
  local node = tree and tree:root():child(0)
  if not node or node:type() ~= "comment" then
    return 0
  end
  local next = node:next_sibling()
  while next and next:type() == "comment" do
    node = next
    next = next:next_sibling()
  end
  local _, _, last_row = node:range()
  return last_row + 1
end

M.ensure_copyright = function(buf)
  local copyright = string.format(
    vim.bo.commentstring,
    "Copyright (c) " .. vim.fn.strftime("%Y") .. " Gecko Robotics. All rights reserved."
  )
  if M.has_copyright_header(buf) then
    vim.notify("copyright detected", vim.log.levels.DEBUG)
    return
  end
  vim.api.nvim_buf_set_lines(buf, 0, 0, false, { copyright })
end

M.ensure_pragma_once = function(buf)
  buf = buf or 0
  if M.has_pragma_once(buf) then
    vim.notify("pragma once detected", vim.log.levels.DEBUG)
    return
  end
  vim.notify("adding pragma once")
  local ln = M.get_header_last_line(buf)
  vim.api.nvim_buf_set_lines(buf, ln, ln, false, { "", "#pragma once" })
end

M.is_cpp_file = function(filepath)
  local filename = vim.fn.fnamemodify(filepath, ":t")
  local filetype = vim.bo.filetype
  return filetype == "cpp" or filetype == "c" or filename:match("%.cpp$") or filename:match("%.hpp$")
end

M.find_cmake_file = function(start_dir)
  local dir = start_dir
  while dir ~= "/" do
    local candidate = dir .. "/CMakeLists.txt"
    if vim.fn.filereadable(candidate) == 1 then
      return candidate
    end
    dir = vim.fn.fnamemodify(dir, ":h")
  end
  return nil
end

M.jump_to_cmake_section = function()
  local current_file = vim.fn.expand("%:p")
  local filename = vim.fn.expand("%:t")
  local current_dir = vim.fn.expand("%:p:h")

  if not M.is_cpp_file(current_file) then
    vim.notify("Not a C++ or HPP file", vim.log.levels.WARN)
    return
  end

  local cmake_file = M.find_cmake_file(current_dir)
  if not cmake_file then
    vim.notify("No CMakeLists.txt found", vim.log.levels.ERROR)
    return
  end

  vim.cmd("edit " .. cmake_file)
  vim.fn.search(filename, "w")
  vim.cmd("normal! zz")
end

return M
