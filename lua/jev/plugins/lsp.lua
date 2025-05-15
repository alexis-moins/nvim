local add = MiniDeps.add

vim.diagnostic.config({
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
	source = "mason-org/mason-lspconfig.nvim",
	depends = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
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
	ensure_installed = {
		"lua_ls",
		"pyright",
		"ts_ls",
		"volar",
	},
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

		keys.maplocal("n", ";d", lsp("definition"), "Go to definitions", buffer)
		keys.maplocal("n", ";r", lsp("references"), "Go to references", buffer)
		keys.maplocal("n", ";t", lsp("type_definition"), "Go to type definitions", buffer)

		keys.maplocal("n", ";f", lsp("document_symbol"), "Find document symbol", buffer)

		keys.maplocal("n", ";R", function()
			local clients = vim.lsp.get_clients()
			vim.lsp.stop_client(clients)
			vim.cmd.edit()
		end, "Restart Lsp client", buffer)

		keys.maplocal("n", ";c", vim.lsp.buf.code_action, "Code actions", buffer)
		keys.maplocal("n", ";n", vim.lsp.buf.rename, "Rename", buffer)

		keys.maplocal("n", "H", function()
			vim.diagnostic.open_float(nil, { focus = false })
		end, "Open diagnostics popup", buffer)
	end,
})

keys.map("n", "<Leader>li", "<cmd>LspInfo<cr>", "Show LSP info")
