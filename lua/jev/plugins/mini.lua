local add = MiniDeps.add

--
-- mini.extra
--
add("echasnovski/mini.extra")
require("mini.extra").setup()

-- Mappings
keys.map("n", "<Leader>fk", MiniExtra.pickers.keymaps, "Find keymaps")
keys.map("n", "<Leader>f?", MiniExtra.pickers.commands, "Find commands")
keys.map("n", "z=", MiniExtra.pickers.spellsuggest, "Find spelling")

keys.map("n", "<C-f>", function()
	MiniExtra.pickers.history({ scope = ":" })
end, "Filter command history")

local function diagnostic(scope)
	return function()
		MiniExtra.pickers.diagnostic({ scope = scope })
	end
end

keys.map("n", "<Leader>w", diagnostic("all"), "Find diagnostic (all)")
keys.map("n", "<Leader>d", diagnostic("current"), "Find diagnostic (current)")

local function diagnostic(scope)
	return function()
		MiniExtra.pickers.diagnostic({ scope = scope })
	end
end

keys.map("n", "<Leader>w", diagnostic("all"), "Find diagnostic (all)")
keys.map("n", "<Leader>d", diagnostic("current"), "Find diagnostic (current)")

--
-- mini.pick
--
add("echasnovski/mini.pick")
require("mini.pick").setup({
	source = {
		show = require("mini.pick").default_show,
	},

	mappings = {
		refine = "<C-J>",
		choose_marked = "<C-Q>",
	},
})

-- Use mini.pick as the default selector in vim
vim.ui.select = MiniPick.ui_select

-- Mappings
keys.map("n", "<Leader><Space>", MiniPick.builtin.files, "Find files")
keys.map("n", "<Leader>z", MiniPick.builtin.resume, "Resume last picker")
keys.map("n", "<C-b>", MiniPick.builtin.buffers, "Find buffers")
keys.map("n", "<Leader>fh", MiniPick.builtin.help, "Find help")
keys.map("n", "<Leader>fg", MiniPick.builtin.grep_live, "Find content")
keys.map("n", "<Leader>*", "<cmd>Pick grep pattern='<cword>'<cr>", "Grep string under cursor")

--
-- mini.notify
--
add("echasnovski/mini.notify")
require("mini.notify").setup({
	content = {
		-- Use notification message as is
		format = function(notif)
			return notif.msg
		end,
	},
})

-- Use mini.notify for general notification
vim.notify = MiniNotify.make_notify()

-- Autocommands
local group = event.augroup("MacroNotification")

event.autocmd("RecordingEnter", {
	group = group,
	callback = function()
		MiniNotify.add("(macro) Recording @" .. vim.fn.reg_recording())
	end,
})

event.autocmd("RecordingLeave", { group = group, callback = MiniNotify.clear })

--
-- mini.bracketed
--
add("echasnovski/mini.bracketed")
require("mini.bracketed").setup({
	buffer = { suffix = "" },
	comment = { suffix = "" },
	-- conflict marker
	diagnostic = { suffix = "" },
	file = { suffix = "" },
	indent = { suffix = "" },
	jump = { suffix = "" },
	location = { suffix = "" },
	oldfile = { suffix = "" },
	treesitter = { suffix = "" },
	undo = { suffix = "" },
	-- window
	yank = { suffix = "" },
})

--
-- mini.jump
add("echasnovski/mini.jump")
require("mini.jump").setup({
	mappings = {
		repeat_jump = ",",
	},

	delay = {
		highlight = 0,
	},
})

--
-- mini.splitjoin
--
add("echasnovski/mini.splitjoin")
require("mini.splitjoin").setup()

--
-- mini.operators
--
add("echasnovski/mini.operators")
require("mini.operators").setup()

--
-- mini.colors
--
add("echasnovski/mini.colors")
require("mini.colors").setup()

--
-- mini.hipatterns
--
add("echasnovski/mini.hipatterns")
local hipatterns = require("mini.hipatterns")
local words = MiniExtra.gen_highlighter.words

hipatterns.setup({
	highlighters = {
		hex_color = hipatterns.gen_highlighter.hex_color(),
		todo = words({ "TODO", "todo" }, "MiniHipatternsTodo"),
		note = words({ "NOTE", "note" }, "MiniHipatternsNote"),
		fixme = words({ "FIXME", "fixme" }, "MiniHipatternsFixme"),
		deprecate = words({ "DEPRECATE", "deprecate" }, "MiniHipatternsDeprecate"),
	},
})

--
-- mini.tabline
--
add("echasnovski/mini.tabline")
require("mini.tabline").setup({
	format = function(buf_id, label)
		local suffix = vim.bo[buf_id].modified and "[+] " or ""
		return MiniTabline.default_format(buf_id, label) .. suffix
	end,
})

--
-- mini.indentscope
--
add("echasnovski/mini.indentscope")
require("mini.indentscope").setup({
	symbol = "┃",
})

--
-- mini.icons
--
add("echasnovski/mini.icons")
require("mini.icons").setup()
