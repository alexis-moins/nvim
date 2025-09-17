local add = MiniDeps.add

add("stevearc/conform.nvim")
local conform = require("conform")

local prettiers = { "prettierd", "prettier", stop_at_first = true }

conform.setup({
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

	-- Format after save to avoid performance issues with large files
	-- format_after_save = {},
})

-- Mappings
keys.map("n", "=", conform.format, "Format file")
