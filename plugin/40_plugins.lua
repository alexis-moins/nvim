-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add, later = MiniDeps.add, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
	add({
		source = "nvim-treesitter/nvim-treesitter",
		-- Use `main` branch since `master` branch is frozen, yet still default
		checkout = "main",
		-- Update tree-sitter parser after plugin is updated
		hooks = { post_checkout = vim.cmd.TSUpdate },
	})

	add({
		source = "nvim-treesitter/nvim-treesitter-textobjects",
		-- Same logic as for 'nvim-treesitter'
		checkout = "main",
	})

	require("nvim-treesitter.configs").setup({
		auto_install = true,
		sync_install = false,

		highlight = {
			enable = true,
			additional_vim_regex_highlighting = false,

			disable = function(_, bufnr)
				-- Disable in files with more than 5K
				return vim.api.nvim_buf_line_count(bufnr) > 5000
			end,
		},
	})
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
now_if_args(function()
	add("neovim/nvim-lspconfig")

	-- Use `:h vim.lsp.enable()` to automatically enable language server based on
	-- the rules provided by 'nvim-lspconfig'.
	vim.lsp.enable({
		"lua_ls",
		"pyright",
		"ts_ls",
		-- Since v3.0.0, the Vue language server requires vtsls to support typescript
		"vtsls",
		"vue_ls",
	})
end)

-- Package manager for installing external language servers, formatters, and linters.
-- It provides a unified interface for installing, updating, and deleting such programs.
later(function()
	add("mason-org/mason.nvim")
	require("mason").setup()
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
	add("stevearc/conform.nvim")

	local prettiers = {
		"prettierd",
		"prettier",
		stop_at_first = true,
	}

	require("conform").setup({
		formatters_by_ft = {
			lua = { "stylua" },
			python = { "isort", "black" },
			javascript = prettiers,
			json = prettiers,
			typescript = prettiers,
			php = { "pint" },
			ocaml = { "ocamlformat" },
		},

		-- Default format options
		default_format_opts = {
			async = true,
			lsp_format = "fallback",
		},
	})
end)
