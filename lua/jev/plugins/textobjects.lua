local add = MiniDeps.add

--
-- NOTE: This module must be loaded after mini.lua & treesitter.lua
--

--
-- mini.ai
--
add("nvim-mini/mini.ai")

local gen_spec = require("mini.ai").gen_spec

require("mini.ai").setup({
	custom_textobjects = {
		e = MiniExtra.gen_ai_spec.buffer(),
		I = MiniExtra.gen_ai_spec.indent(),
		L = MiniExtra.gen_ai_spec.line(),
		N = MiniExtra.gen_ai_spec.number(),

		-- Requires treesitter & treesitter-textobjects
		F = gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
		P = gen_spec.treesitter({ a = "@parameter.outer", i = "@parameter.inner" }),
		c = gen_spec.treesitter({ a = "@comment.outer", i = "@comment.inner" }),

		-- snake_case, camelCase, PascalCase...
		s = {
			{
				-- PascalCaseWords (or the latter part of camelCaseWords)
				"%u[%l%d]+%f[^%l%d]",

				-- start of camelCaseWords (just the `camel`)
				-- snake_case_words in lowercase
				-- regular lowercase words
				"%f[^%s%p][%l%d]+%f[^%l%d]",
				"^[%l%d]+%f[^%l%d]",

				-- SNAKE_CASE_WORDS in uppercase
				-- Snake_Case_Words in titlecase
				-- regular UPPERCASE words
				"%f[^%s%p][%a%d]+%f[^%a%d]",
				"^[%a%d]+%f[^%a%d]",
			},
			"^().*()$",
		},
	},
})
