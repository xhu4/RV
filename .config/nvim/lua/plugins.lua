-- bootstrap packer.nvim {{{
local bootstrap_packer = function()
	local fn = vim.fn
	local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
	local packer_installed = fn.empty(fn.glob(install_path)) == 0
	if not packer_installed then
		-- install and initialize packer
		fn.system({ "git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path })
		vim.cmd([[packadd packer.nvim]])
		return true
	end
	return false
end
-- }}}

local packer_bootstrap = bootstrap_packer()

return require("packer").startup(function(use)
	use("wbthomason/packer.nvim")
	use({
		"terrortylor/nvim-comment",
		config = function()
			require("nvim_comment").setup()
		end,
	})
	if vim.g.vscode then
		use({ "asvetliakov/vim-easymotion", as = "vsc-easymotion" })
	else
		use({ "easymotion/vim-easymotion" })
		use({
			"nvim-telescope/telescope.nvim",
			requires = { "nvim-lua/plenary.nvim", "kiyoon/telescope-insert-path.nvim" },
			config = function()
				local path_actions = require("telescope_insert_path")
				require("telescope").setup({
					defaults = {
						mappings = {
							n = {
								["<C-i>"] = path_actions.insert_relpath_i_insert,
								["<C-a>"] = path_actions.insert_relpath_a_insert,
							},
						},
					},
				})
			end,
		})
		use({
			"nvim-treesitter/nvim-treesitter",
			run = ":TSUpdate",
			requires = { "p00f/nvim-ts-rainbow" },
			config = function()
				require("nvim-treesitter.configs").setup({
					-- A list of parser names, or "all"
					ensure_installed = { "c", "lua", "rust", "vim", "help" },

					-- Install parsers synchronously (only applied to `ensure_installed`)
					sync_install = false,

					-- Automatically install missing parsers when entering buffer
					-- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
					auto_install = true,
					highlight = {
						enable = true,
						additional_vim_regex_highlighting = false,
					},
					rainbow = { enable = true },
				})
			end,
		})
		use({ "jose-elias-alvarez/null-ls.nvim", requires = { "nvim-lua/plenary.nvim" } })
		use({
			"nvim-tree/nvim-web-devicons",
			config = function()
				require("nvim-web-devicons").setup()
			end,
		})
		use({ "neovim/nvim-lspconfig" })
		use({
			"lukas-reineke/indent-blankline.nvim",
			config = function()
				require("indent_blankline").setup({
					space_char_blank_line = " ",
					show_current_context = true,
					show_current_context_start = true,
				})
			end,
		})
		use({
			"p00f/clangd_extensions.nvim",
			requires = { "neovim/nvim-lspconfig" },
		})
		use({
			"nvim-tree/nvim-tree.lua",
			requires = "nvim-tree/nvim-web-devicons",
			tag = "nightly",
			config = function()
				require("nvim-tree").setup({ sort_by = "case_sensitive" })
			end,
		})
		use("p00f/nvim-ts-rainbow")
	end
	use({ "sindrets/diffview.nvim", requires = "nvim-lua/plenary.nvim" })
	use("tpope/vim-surround")
	use("chaoren/vim-wordmotion")
	use("folke/tokyonight.nvim")

	-- use {'mfussenegger/nvim-dap'}

	-- Automatically set up your configuration after cloning packer.nvim
	-- Put this at the end after all plugins
	if packer_bootstrap then
		require("packer").sync()
	end
end)
