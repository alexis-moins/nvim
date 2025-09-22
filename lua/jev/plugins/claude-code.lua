-- Variable to store the ClaudeCode tmux pane ID
local claude_pane_id = nil

-- Check if a tmux pane exists by listing all panes and searching for the given ID
local function pane_exists(pane_id)
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
local function send_to_pane(pane_id, text)
	vim.system({ "tmux", "send-keys", "-t", pane_id, text, "C-m" }):wait()
end

-- Escape single quotes in shell arguments to prevent command injection
local function escape_shell_arg(str)
	return str:gsub("'", "'\"'\"'")
end

-- Create a new tmux pane running claude command and store the pane ID
local function create_claude_pane(prompt)
	local command = prompt and string.format("claude '%s'", escape_shell_arg(prompt)) or "claude"

	local result = vim.system(
		{ "tmux", "split-window", "-h", "-P", "-F", "#{pane_id}", command },
		{ capture_output = true }
	)
		:wait()

	if result.code == 0 then
		claude_pane_id = result.stdout:gsub("%s+", "")
	end
end

-- Build file context string with path and optional line range information
local function build_context(opts)
	local file_path = vim.fn.expand("%:p")
	local relative_path = vim.fn.fnamemodify(file_path, ":.")

	if opts.range > 0 then
		return string.format("File @%s (lines %d-%d)", relative_path, opts.line1, opts.line2)
	else
		return string.format("File @%s", relative_path)
	end
end

-- Build complete prompt by combining file context with user input
local function build_prompt(opts)
	if opts.args == "" then
		return nil
	end

	local context = build_context(opts)
	return string.format("%s\n\n%s", context, opts.args)
end

-- Switch focus to the specified tmux pane
local function focus_claude_pane(pane_id)
	vim.system({ "tmux", "select-pane", "-t", pane_id }):wait()
end

-- Handle interaction with existing Claude pane: send prompt if provided, then focus
local function handle_existing_pane(prompt_text)
	if prompt_text and prompt_text ~= "" then
		send_to_pane(claude_pane_id, prompt_text)
	end
	focus_claude_pane(claude_pane_id)
end

-- Create a new Claude pane with optional initial prompt
local function handle_new_pane(prompt_text)
	claude_pane_id = nil
	create_claude_pane(prompt_text)
end

-- Handle visual mode selection by prompting user for input
local function handle_visual_selection(opts)
	if opts.range and opts.range > 0 and (not opts.args or opts.args == "") then
		local prompt = vim.fn.input("(ClaudeCode) ")
		if not prompt or prompt == "" then
			vim.notify("ClaudeCode: prompt required for visual selection", vim.log.levels.ERROR)
			return false
		end

		-- Override args with user input
		opts.args = prompt
	end
	return true
end

-- Main handler for the ClaudeCode command - manages pane creation and interaction
local function claude_code_handler(opts)
	opts = opts or {}

	if not vim.env.TMUX then
		print("Not inside tmux session")
		return
	end

	if not handle_visual_selection(opts) then
		return
	end

	local prompt_text = build_prompt(opts)

	if pane_exists(claude_pane_id) then
		handle_existing_pane(prompt_text)
	else
		handle_new_pane(prompt_text)
	end
end

vim.api.nvim_create_user_command("ClaudeCode", claude_code_handler, {
	nargs = "*",
	range = true,
	desc = "Open Claude Code",
})

-- Using : to ensure the visual selection range is passed to the command
keys.map({ "n", "v" }, "<Leader>tc", ":ClaudeCode<CR>", "Open Claude Code")
