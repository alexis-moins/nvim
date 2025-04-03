local add = MiniDeps.add

--
-- Fugitive
--
-- add("tpope/vim-fugitive")


--
-- mini.git
--
add("echasnovski/mini-git")
require("mini.git").setup({})

keys.map("n", "<C-G>", function()
   MiniExtra.pickers.git_files({ scope='modified' })
end, "Find unstaged files (git)")

keys.map("n", "<C-S>", function()
    MiniPick.builtin.cli({ command = {"git", "diff", "--cached", "--name-only"} }, { source = { name = "Git files (staged)" } })
end, "Find staged files (git)")

--
-- mini.diff
--
add("echasnovski/mini.diff")
require("mini.diff").setup({
	view = {
		style = "sign",
		signs = { add = "┃", change = "┃", delete = "┃" },
		-- Default diagnostic priority is 10, so we set it to 9 to make sure it's
		-- overriden by the diagnostic signs.
		priority = 9,
	},
})

-- Mappings
keys.map("n", "\\d", MiniDiff.toggle_overlay, "Toggle diff overlay")
keys.map("n", "\\g", MiniDiff.toggle, "Toggle git signs")
