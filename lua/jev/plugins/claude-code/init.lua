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

	-- For direct commands, build full prompt with optional context
	---@type Selection|nil
	local selection = (opts.range and opts.range > 0) and { from = opts.line1, to = opts.line2 } or nil

	if needs_input then
		ui.create_prompt_buffer(function(content)
			local prompt = command.build_prompt(content, selection)
			tmux.execute_claude_command(prompt)
		end)
	else
		local prompt = command.build_prompt(opts.args, selection)
		tmux.execute_claude_command(prompt)
	end
end

vim.api.nvim_create_user_command("ClaudeCode", claude_code_handler, {
	nargs = "*",
	range = true,
	desc = "Open Claude Code",
})

-- Using : to ensure the visual selection range is passed to the command
keys.map({ "n", "v" }, "<Leader>tc", ":ClaudeCode<CR>", "Open Claude Code")
