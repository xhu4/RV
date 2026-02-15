-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
-- copyright
--
local setup = function()
  -- if vim.fn.hostname() ~= "precision" then
  --   return
  -- end
  local glam_group = vim.api.nvim_create_augroup("glam", {})
  local utils = require("user.utils")
  -- make sure this goes first because we want the copyright header before pragma
  vim.api.nvim_create_autocmd({ "BufWrite" }, {
    group = glam_group,
    pattern = "*.cpp,*.hpp,*.py,CMakeLists.txt,*.capnp",
    desc = "Auto copyright header",
    callback = function(opts)
      return utils.ensure_copyright(opts.buf)
    end,
    once = true,
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
