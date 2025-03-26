local add = MiniDeps.add

vim.diagnostic.config({
	float = { border = "single" },
	update_in_insert = true,
	virtual_text = false,
	virtual_lines = {
		current_line = false,
	},
	underline = false,
	jump = { float = true },
	signs = false,
})

--
-- Mason
--
add({
	source = "williamboman/mason-lspconfig.nvim",
	depends = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
})

--
-- Add documentation for nvim-lua api and plugins
--
add("folke/neodev.nvim")
require("neodev").setup()

--
-- Mason
--
require("mason").setup()

require("mason-lspconfig").setup({
	ensure_installed = { "lua_ls", "pyright", "ts_ls", "volar" },
})

require("mason-lspconfig").setup_handlers({
	function(server_name)
		require("lspconfig")[server_name].setup({})
	end,

	["lua_ls"] = function()
		require("lspconfig").lua_ls.setup({
			settings = {
				Lua = {
					diagnostics = {
						globals = { "vim" },
					},

					hint = { enable = true },
				},
			},
		})
	end,

	["ts_ls"] = function()
		local vue_typescript_plugin = require("mason-registry").get_package("vue-language-server"):get_install_path()
			.. "/node_modules/@vue/language-server"
			.. "/node_modules/@vue/typescript-plugin"

		require("lspconfig").ts_ls.setup({
			init_options = {
				plugins = {
					{
						name = "@vue/typescript-plugin",
						location = vue_typescript_plugin,
						languages = { "javascript", "typescript", "vue" },
					},
				},
			},
			filetypes = {
				"javascript",
				"javascriptreact",
				"javascript.jsx",
				"typescript",
				"typescriptreact",
				"typescript.tsx",
				"vue",
			},
		})
	end,
})

local function lsp(scope)
	return function()
		MiniExtra.pickers.lsp({ scope = scope })
	end
end

event.autocmd("LspAttach", {
	group = event.augroup("LspConfig"),
	callback = function(args)
		local buffer = args.buf

		-- vim.lsp.completion.enable(true, 0, buffer, { autotrigger = true })

		keys.maplocal("n", ";d", lsp("definition"), "Go to definitions", buffer)
		keys.maplocal("n", ";r", lsp("references"), "Go to references", buffer)
		keys.maplocal("n", ";t", lsp("type_definition"), "Go to type definitions", buffer)

		keys.maplocal("n", ";f", lsp("document_symbol"), "Find document symbol", buffer)

		keys.maplocal("n", ";R", vim.cmd.LspRestart, "Restart Lsp client", buffer)

		keys.maplocal("n", ";c", vim.lsp.buf.code_action, "Code actions", buffer)
		keys.maplocal("n", ";n", vim.lsp.buf.rename, "Rename", buffer)

		keys.maplocal("n", "H", function()
			vim.diagnostic.open_float(nil, { focus = false })
		end, "Open diagnostics popup", buffer)

		keys.maplocal("n", "K", function()
			vim.lsp.buf.hover({ border = "single" })
		end, "Open signature popup", buffer)
	end,
})

keys.map("n", "<Leader>li", "<cmd>LspInfo<cr>", "Show LSP info")
