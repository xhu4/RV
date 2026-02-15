-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local set_keymaps = function()
  vim.keymap.set("i", "jk", "<Esc>", { desc = "Escape" })
  vim.keymap.set("n", "gh", function()
    local node = vim.treesitter.get_node()
    if node == nil then
      vim.notify("No identifier found under cursor", vim.log.levels.ERROR)
      return
    end
    vim.cmd("h " .. vim.treesitter.get_node_text(node, vim.api.nvim_get_current_buf()))
  end, { desc = "Go to help." })
  -- vim.keymap.del({ "n", "t" }, "<C-/>")
  vim.keymap.set({ "n", "t" }, "<C-S-/>", function()
    Snacks.terminal.toggle(nil, { cwd = LazyVim.root() })
  end, { desc = "Terminal (Root Dir)" })
  local comment = require("vim._comment")
  local operator_rhs = function()
    return comment.operator()
  end
  vim.keymap.set("v", "<C-/>", operator_rhs, { expr = true, desc = "Toggle comment" })

  local line_rhs = function()
    return comment.operator() .. "_"
  end
  vim.keymap.set("n", "<C-/>", line_rhs, { expr = true, desc = "Toggle comment line" })
  vim.keymap.set("i", "<C-/>", function()
    local line = vim.fn.line(".")
    comment.toggle_lines(line, line)
  end, { expr = false, desc = "Toggle comment line" })
  vim.keymap.set({ "i", "n" }, "<C-.><C-.>", "<Cmd>source %<CR>", { desc = "Source current file." })
  vim.keymap.set({ "i", "n" }, "<C-Q>", "<Cmd>bdelete<CR>", { desc = "Delete buffer and window." })
end

vim.schedule(set_keymaps)
