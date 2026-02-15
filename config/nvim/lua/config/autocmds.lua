-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- copyright
local edit_file = function(filename)
  local file = vim.fs.find(filename, { upward = true, type = "file", path = vim.fn.expand("%:p") })[1]
  if file ~= nil then
    vim.cmd("edit " .. file)
  else
    vim.notify("No " .. filename .. " found", vim.log.levels.WARN)
  end
end

local setup = function()
  -- if vim.fn.hostname() ~= "precision" then
  --   return
  -- end
  local glam_group = vim.api.nvim_create_augroup("glam", {})
  local utils = require("user.utils")
  -- make sure this goes first because we want the copyright header before pragma
  vim.api.nvim_create_autocmd({ "BufWrite" }, {
    group = glam_group,
    pattern = "/app/gecko-glam/ros2_ws/src/{*.cpp,*.hpp,*.py}",
    desc = "Auto copyright header",
    callback = function(opts)
      return utils.ensure_copyright(opts.buf)
    end,
    once = true,
  })
  vim.api.nvim_create_autocmd({ "BufNew" }, {
    group = glam_group,
    pattern = "/app/gecko-glam/ros2_ws/*",
    desc = "GLAM keymaps",
    callback = function()
      vim.keymap.set({ "i", "n" }, "<C-.><C-M>", function()
        edit_file("CMakeLists.txt")
      end, { desc = "Jump to CMakeLists.txt", buffer = true })
      vim.keymap.set({ "i", "n" }, "<C-.><C-P>", function()
        edit_file("package.xml")
      end, { desc = "Jump to package.xml", buffer = true })
    end,
  })

  local cpp_group = vim.api.nvim_create_augroup("auto_cpp", {})
  vim.api.nvim_create_autocmd({ "BufWrite" }, {
    group = cpp_group,
    pattern = "*.hpp",
    desc = "Auto fill #pragma once",
    callback = function(opts)
      return utils.ensure_pragma_once(opts.buf)
    end,
    once = true,
  })
end
vim.schedule(setup)
