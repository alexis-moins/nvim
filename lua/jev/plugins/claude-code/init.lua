local tmux = require("jev.plugins.claude-code.tmux")
local ui = require("jev.plugins.claude-code.ui")
local command = require("jev.plugins.claude-code.command")

-- Handler for the ClaudeCodeAsk command - takes a prompt or opens prompt buffer
local function claude_code_ask_handler(opts)
	opts = opts or {}

	if not vim.env.TMUX then
		print("Not inside tmux session")
		return
	end

	-- Parse the command arguments
	local args = opts.args or ""

	-- For direct commands, build full prompt with optional context
	---@type Selection|nil
	local selection = (opts.range and opts.range > 0) and { from = opts.line1, to = opts.line2 } or nil

	if not args or args == "" then
		-- Open prompt buffer when no arguments provided
		ui.create_prompt_buffer(function(content)
			local prompt = command.build_prompt(content, selection)
			tmux.execute_claude_command(prompt)
		end)
	else
		-- Execute directly with provided arguments
		local prompt = command.build_prompt(args, selection)
		tmux.execute_claude_command(prompt)
	end
end

-- Handler for the ClaudeCodeAdd command - sends file context to Claude Code pane
local function claude_code_add_handler(opts)
	if not vim.env.TMUX then
		print("Not inside tmux session")
		return
	end

	-- Build context from visual selection
	local selection = (opts.range and opts.range > 0) and { from = opts.line1, to = opts.line2 } or nil
	local context = command.build_context(selection)

	if context then
		tmux.execute_claude_command(context)
	end
end

vim.api.nvim_create_user_command("ClaudeCodeAsk", claude_code_ask_handler, {
	nargs = "*",
	range = true,
	desc = "Ask Claude Code with prompt or prompt buffer",
})

vim.api.nvim_create_user_command("ClaudeCodeToggle", function()
	tmux.execute_claude_command()
end, {
	desc = "Toggle Claude Code pane",
})

vim.api.nvim_create_user_command("ClaudeCodeAdd", claude_code_add_handler, {
	range = true,
	desc = "Send selected text to Claude Code pane",
})

-- Using : to ensure the visual selection range is passed to the command
keys.map({ "n", "v" }, "<Leader>tc", ":ClaudeCodeAsk<CR>", "Ask Claude Code")
keys.map("n", "\\a", "<Cmd>ClaudeCodeToggle<CR>", "Toggle Claude Code")
keys.map("v", "ga", ":ClaudeCodeAdd<CR>", "Send selection to Claude Code")
