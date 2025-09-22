-- ui.lua - user interface and input buffer functions

local M = {}

-- Configuration for cache file
M.CACHE_FILE = "/tmp/claude-prompt.md"

-- Create and configure a saveable buffer with proper options
function M.create_saveable_buffer(file_path)
	local buf = vim.api.nvim_create_buf(false, false)
	vim.api.nvim_buf_set_name(buf, file_path)
	vim.api.nvim_buf_set_option(buf, "buftype", "")
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
	vim.api.nvim_buf_set_option(buf, "swapfile", false)
	vim.api.nvim_buf_set_option(buf, "filetype", "markdown")
	vim.api.nvim_buf_set_option(buf, "spell", true)
	return buf
end

-- Set up autocommands for the input buffer
function M.setup_buffer_autocommands(buf, callback)
	local augroup = vim.api.nvim_create_augroup("ClaudeCode", { clear = false })

	-- Handle saving
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		buffer = buf,
		once = true,
		callback = function()
			local content = table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), "\n")
			local trimmed_content = content:gsub("%s+$", "")

			vim.cmd("close")
			os.remove(M.CACHE_FILE)

			if trimmed_content and trimmed_content ~= "" and not trimmed_content:match("^%s*$") then
				callback(trimmed_content)
			end
		end,
	})

	-- Handle cleanup on close
	vim.api.nvim_create_autocmd({"BufWinLeave", "BufHidden"}, {
		group = augroup,
		buffer = buf,
		once = true,
		callback = function()
			os.remove(M.CACHE_FILE)
		end,
	})
end

-- Create a saveable buffer for user input in a floating window
function M.create_input_buffer(callback)
	local file_path = M.CACHE_FILE

	local buf = M.create_saveable_buffer(file_path)

	-- Calculate floating window size and position
	local width = math.floor(vim.o.columns * 0.5)
	local height = math.floor(vim.o.lines * 0.4)
	local row = 0
	local col = vim.o.columns - width

	-- Create floating window
	vim.api.nvim_open_win(buf, true, {
		relative = "editor",
		width = width,
		height = height,
		row = row,
		col = col,
		title = " ClaudeCode Prompt ",
	})

	M.setup_buffer_autocommands(buf, callback)
end

return M