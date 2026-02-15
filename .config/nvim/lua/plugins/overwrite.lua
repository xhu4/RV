return {
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "chaoren/vim-wordmotion",
  },
  {
    "metakirby5/codi.vim",
  },
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<C-CR>",
        function()
          Snacks.zen.zoom()
        end,
        desc = "Toggle zoom",
      },
    },
  },
  {
    "saghen/blink.cmp",
    opts = {
      keymap = {
        preset = "super-tab",
      },
    },
  },
}
