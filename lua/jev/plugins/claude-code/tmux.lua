-- tmux.lua - tmux pane management functions

local M = {}

-- Variable to store the ClaudeCode tmux pane ID
M.claude_pane_id = nil

-- Check if a tmux pane exists by listing all panes and searching for the given ID
function M.pane_exists(pane_id)
	if not pane_id then
		return false
	end

	local result = vim.system({ "tmux", "list-panes", "-a", "-F", "#{pane_id}" }, { capture_output = true }):wait()

	if result.code == 0 then
		for line in result.stdout:gmatch("[^\r\n]+") do
			if line == pane_id then
				return true
			end
		end
	end
	return false
end

-- Send text to a tmux pane and press Enter to execute it
function M.send_to_pane(text)
	if not M.pane_exists(M.claude_pane_id) then
		vim.notify("Claude pane no longer exists", vim.log.levels.WARN)
		return
	end
	vim.system({ "tmux", "send-keys", "-t", M.claude_pane_id, text }):wait()
end

-- Escape single quotes in shell arguments to prevent command injection
function M.escape_shell_arg(str)
	return str:gsub("'", "'\"'\"'")
end

-- Create a new tmux pane running claude command
function M.create_claude_pane(prompt)
	local command = prompt and string.format("claude '%s'", M.escape_shell_arg(prompt)) or "claude"

	local result = vim.system(
		{ "tmux", "split-window", "-h", "-P", "-F", "#{pane_id}", command },
		{ capture_output = true }
	)
		:wait()

	if result.code == 0 then
		M.claude_pane_id = result.stdout:gsub("%s+", "")
	end
end

-- Switch focus to the specified tmux pane
function M.focus_claude_pane(pane_id)
	vim.system({ "tmux", "select-pane", "-t", pane_id }):wait()
end

-- Handle interaction with existing Claude pane: send prompt if provided, then focus
function M.handle_existing_pane(prompt_text)
	if prompt_text and prompt_text ~= "" then
		M.send_to_pane(prompt_text)
	end
	M.focus_claude_pane(M.claude_pane_id)
end

-- Create a new Claude pane with optional initial prompt
function M.handle_new_pane(prompt)
	M.claude_pane_id = nil

	-- Only send the user prompt without exploration message
	if prompt and prompt ~= "" then
		M.create_claude_pane(prompt)
	else
		M.create_claude_pane()
	end
end

-- Execute Claude command with given prompt
function M.execute_claude_command(prompt_text)
	if M.pane_exists(M.claude_pane_id) then
		M.handle_existing_pane(prompt_text)
	else
		M.handle_new_pane(prompt_text)
	end
end

return M
