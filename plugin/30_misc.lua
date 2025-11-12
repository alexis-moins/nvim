-- vim: foldmethod=marker foldlevel=0 foldlevelstart=0
--
-- ┌─────────┐
-- │ Plugins │
-- └─────────┘
--
-- local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

local specs = {
	-- Mini Plugins
	"https://github.com/nvim-mini/mini.hues",
	"https://github.com/nvim-mini/mini.icons",
	"https://github.com/nvim-mini/mini.notify",
	"https://github.com/nvim-mini/mini.extra",
	"https://github.com/nvim-mini/mini.ai",
	"https://github.com/nvim-mini/mini.completion",
	"https://github.com/nvim-mini/mini.snippets",
	"https://github.com/nvim-mini/mini.diff",
	"https://github.com/nvim-mini/mini.files",
	"https://github.com/nvim-mini/mini.hipatterns",
	"https://github.com/nvim-mini/mini.move",
	"https://github.com/nvim-mini/mini.operators",
	"https://github.com/nvim-mini/mini.pairs",
	"https://github.com/nvim-mini/mini.pick",
	"https://github.com/nvim-mini/mini.surround",
	"https://github.com/nvim-mini/mini.splitjoin",

	-- Other plugins
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter",
		version = "main",
	},
	{
		src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
		version = "main",
	},
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/stevearc/conform.nvim",
}

vim.pack.add(specs, { load = true })

-- Run `:TSUpdate`
Config.new_autocmd("PackChanged", nil, function(event)
	if (event.data.kind == "install" or event.data.kind == "update") and event.data.spec.name == "nvim-treesitter" then
		local ok = pcall(vim.cmd.TSUpdate)

		if not ok then
			vim.notify("TSUpdate failed!", vim.log.levels.WARN)
		end
	end
end)

-- Hues =======================================================================

-- Once mini.hues is installed, we can set the colorscheme (which depends on it)
vim.cmd("colorscheme mini-mocha")

-- Icons ======================================================================

require("mini.icons").setup()

-- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
MiniIcons.mock_nvim_web_devicons()

-- Add LSP kind icons. Useful for 'mini.completion'.
MiniIcons.tweak_lsp_kind()

-- Notify =====================================================================

require("mini.notify").setup()

-- Extra ======================================================================

require("mini.extra").setup()

-- Textobjects ================================================================

local ai = require("mini.ai")

ai.setup({
	-- 'mini.ai' can be extended with custom textobjects
	custom_textobjects = {
		-- Make `aB` / `iB` act on around/inside whole *b*uffer
		B = MiniExtra.gen_ai_spec.buffer(),

		-- For more complicated textobjects that require structural awareness,
		-- use tree-sitter. This example makes `aF`/`iF` mean around/inside function
		-- definition (not call). See `:h MiniAi.gen_spec.treesitter()` for details.
		f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
	},
})

-- Completion =================================================================

-- Customize post-processing of LSP responses for a better user experience.
-- Don't show 'Text' suggestions (usually noisy) and show snippets last.
local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }

local process_items = function(items, base)
	return MiniCompletion.default_process_items(items, base, process_items_opts)
end

require("mini.completion").setup({
	lsp_completion = {
		-- Without this config autocompletion is set up through `:h 'completefunc'`.
		-- Although not needed, setting up through `:h 'omnifunc'` is cleaner
		-- (sets up only when needed) and makes it possible to use `<C-u>`.
		source_func = "omnifunc",

		auto_setup = false,
		process_items = process_items,
	},

	-- Fallback to built-in completion
	fallback_action = "<C-x><C-n>",

	mappings = {
		force_twostep = "<C-n>",
	},
})

-- Set 'omnifunc' for LSP completion only when needed.
Config.new_autocmd("LspAttach", nil, function(ev)
	vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
end)

-- Advertise to servers that Neovim now supports certain set of completion and
-- signature features through 'mini.completion'.
vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })

-- Snippets ===================================================================

local snippets = require("mini.snippets")

snippets.setup({
	snippets = {
		-- Load custom file with global snippets first
		snippets.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),

		-- Load snippets based on current language by reading files from
		-- "snippets/" subdirectories from 'runtimepath' directories.
		snippets.gen_loader.from_lang(),
	},
})

-- By default snippets available at cursor are not shown as candidates in
-- 'mini.completion' menu. This requires a dedicated in-process LSP server
-- that will provide them.
MiniSnippets.start_lsp_server()

-- Diff =======================================================================

require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "┃", change = "┃", delete = "┃" },
	},
})

-- File Explorer ==============================================================

require("mini.files").setup({
	mappings = {
		go_in_plus = "<CR>",
	},
})

-- Hipatterns =================================================================

local hipatterns = require("mini.hipatterns")
local words = MiniExtra.gen_highlighter.words

hipatterns.setup({
	highlighters = {
		todo = words({ "TODO", "todo" }, "MiniHipatternsTodo"),
		note = words({ "NOTE", "note" }, "MiniHipatternsNote"),
		fixme = words({ "FIXME", "fixme" }, "MiniHipatternsFixme"),
		deprecate = words({ "DEPRECATE", "deprecate" }, "MiniHipatternsFixme"),

		-- Highlight hex color string (#aabbcc) with that color as a background
		hex_color = hipatterns.gen_highlighter.hex_color(),
	},
})

-- Move =======================================================================

require("mini.move").setup({
	mappings = {
		-- Normal mode
		up = "<C-K>",
		down = "<C-J>",
		left = "<C-H>",
		right = "<C-L>",

		-- Visual mode
		line_up = "<C-K>",
		line_down = "<C-J>",
		line_left = "<C-H>",
		line_right = "<C-L>",
	},
})

-- Operators ==================================================================

require("mini.operators").setup()

-- Pairs ======================================================================

require("mini.pairs").setup({
	modes = {
		command = true,
	},
})

-- Pickers ====================================================================

require("mini.pick").setup()

-- Add custom 'staged' scope for `:Pick git_files`
MiniPick.registry.git_files = function(local_opts)
	if local_opts.scope == "staged" then
		return MiniPick.builtin.cli(
			{ command = { "git", "diff", "--cached", "--name-only" } },
			{ source = { name = "Git files (staged)" } }
		)
	end

	return MiniExtra.pickers.git_files(local_opts)
end

-- Surround ===================================================================

require("mini.surround").setup()

-- Splitjoin ==================================================================

require("mini.splitjoin").setup()

-- Special key mappings. Provides helpers to map:
-- - Multi-step actions. Apply action 1 if condition is met; else apply
--   action 2 if condition is met; etc.
-- - Combos. Sequence of keys where each acts immediately plus execute extra
--   action if all are typed fast enough. Useful for Insert mode mappings to not
--   introduce delay when typing mapping keys without intention to execute action.
-- later(function()
-- 	add("nvim-mini/mini.keymap")
-- 	require("mini.keymap").setup()
--
-- 	-- Navigate completion menu and snippets with `<Tab>` /  `<S-Tab>`
-- 	MiniKeymap.map_multistep("i", "<Tab>", {
-- 		"minisnippets_next",
-- 		"pmenu_next",
-- 	})
--
-- 	MiniKeymap.map_multistep("i", "<S-Tab>", {
-- 		"minisnippets_prev",
-- 		"pmenu_prev",
-- 	})
--
-- 	-- On `<CR>` try to accept current completion item, fall back to accounting
-- 	-- for pairs from 'mini.pairs'
-- 	MiniKeymap.map_multistep("i", "<CR>", {
-- 		"pmenu_accept",
-- 		"minipairs_cr",
-- 	})
--
-- 	-- On `<BS>` just try to account for pairs from 'mini.pairs'
-- 	MiniKeymap.map_multistep("i", "<BS>", { "minipairs_bs" })
--
-- 	-- MiniKeymap.map_combo({ "n", "x" }, "jj", "}")
-- 	-- MiniKeymap.map_combo({ "n", "x" }, "kk", "{")
-- end)

-- Tree-sitter ================================================================

-- require("nvim-treesitter.configs").setup({
-- 	auto_install = true,
-- 	sync_install = false,
--
-- 	highlight = {
-- 		enable = true,
-- 		additional_vim_regex_highlighting = false,
--
-- 		disable = function(_, bufnr)
-- 			-- Disable in files with more than 5K
-- 			return vim.api.nvim_buf_line_count(bufnr) > 5000
-- 		end,
-- 	},
-- })

-- Language servers ===========================================================

vim.lsp.enable({
	"lua_ls",
	"pyright",
	"ts_ls",
	-- Since v3.0.0, the Vue language server requires vtsls to support typescript
	"vtsls",
	"vue_ls",
})

-- Mason ======================================================================

require("mason").setup()

-- Formatting =================================================================

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
