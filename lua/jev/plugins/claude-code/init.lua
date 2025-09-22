local tmux = require("jev.plugins.claude-code.tmux")
local ui = require("jev.plugins.claude-code.ui")
local command = require("jev.plugins.claude-code.command")

-- Main handler for the ClaudeCode command - manages window creation and interaction
local function claude_code_handler(opts)
	opts = opts or {}

	if not vim.env.TMUX then
		print("Not inside tmux session")
		return
	end

	-- Always ask for prompt in input buffer if no prompt was passed
	local needs_input = not opts.args or opts.args == ""

	if needs_input then
		ui.create_input_buffer(function(content)
			-- Override args with user input from buffer
			opts.args = content
			local prompt_text = command.build_prompt(opts)
			tmux.execute_claude_command(prompt_text)
		end)
		return
	end

	-- Direct execution path for when args are provided
	local prompt_text = command.build_prompt(opts)
	tmux.execute_claude_command(prompt_text)
end

vim.api.nvim_create_user_command("ClaudeCode", claude_code_handler, {
	nargs = "*",
	range = true,
	desc = "Open Claude Code",
})

-- Using : to ensure the visual selection range is passed to the command
keys.map({ "n", "v" }, "<Leader>tc", ":ClaudeCode<CR>", "Open Claude Code")
