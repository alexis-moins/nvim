-- Define config table to be able to pass data between scripts
_G.Config = {}

-- Define custom autocommand group and helper to create an autocommand.
-- Autocommands are Neovim's way to define actions that are executed on events
-- (like creating a buffer, setting an option, etc.).
local gr = vim.api.nvim_create_augroup("UserConfig", {})

_G.Config.new_autocmd = function(event, pattern, callback, desc)
	local opts = { group = gr, pattern = pattern, callback = callback, desc = desc }
	vim.api.nvim_create_autocmd(event, opts)
end

_G.Config.map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { desc = desc })
end

_G.Config.maplocal = function(mode, lhs, rhs, desc, buffer)
	vim.keymap.set(mode, lhs, rhs, { desc = desc, buffer = buffer or true })
end

Config.new_autocmd("FileType", "*", function()
	local ok = pcall(vim.treesitter.start)

	if not ok then
		vim.notify("Failed to start treesitter", vim.log.levels.WARN)
	end
end)

-- Show 'cursorline' in current buffer
Config.new_autocmd({ "WinEnter", "BufEnter" }, nil, function()
	vim.wo.cursorline = true
end)

-- Hide 'cursorline' in other buffers
Config.new_autocmd({ "WinLeave", "BufLeave" }, nil, function()
	vim.wo.cursorline = false
end)

-- Resize splits when terminal resizes
Config.new_autocmd("VimResized", nil, function()
	vim.cmd.tabdo("wincmd =")
end)

-- Highlight on yank
Config.new_autocmd("TextYankPost", nil, function()
	vim.highlight.on_yank({
		higroup = "Visual",
		timeout = 200,
		on_visual = false,
	})
end)

Config.new_autocmd("FileType", {
	"markdown",
	"html",
	"vue",
	"javascriptreact",
	"typescriptreact",
}, function()
	MiniPairs.map_buf(0, "i", "<", { action = "open", pair = "<>", register = { cr = false } })
	MiniPairs.map_buf(0, "i", ">", { action = "close", pair = "<>", register = { cr = false } })
end)
