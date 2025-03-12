local add = MiniDeps.add

--
-- Snippets
--
add("echasnovski/mini.snippets")
local snippet = require("mini.snippets")

snippet.setup({
	snippets = {
		-- Load custom file with global snippets first
		snippet.gen_loader.from_file(vim.fn.stdpath("config") .. "/snippets/global.json"),

		-- Load snippets based on current language by reading files from
		-- "snippets/" subdirectories from 'runtimepath' directories.
		snippet.gen_loader.from_lang(),
	},
})

--
-- Completion
--
add("echasnovski/mini.completion")
require("mini.completion").setup({
	window = {
		info = { border = "single" },
		signature = { border = "single" },
	},

	fallback_action = "<C-x><C-n>",

	mappings = {
		force_twostep = "<C-h>",
	},
})
