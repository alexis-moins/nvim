keys.map("n", "<Leader>t", function()
	local session_name = MiniPick.builtin.cli({ command = { "tmux", "list-sessions", "-F", "#S" } })

	if vim.env.TMUX then
		print("oui")
		vim.system({ "tmux", "switch-client", "-t", session_name }):wait()
	else
		print("non")
		vim.system({ "tmux", "attach-session", "-t", session_name }):wait()
	end
end, "Find tmux session")

keys.map("n", "<Leader>tw", function()
	if vim.env.TMUX then
		vim.system({ "tmux", "split-window", "-h" }):wait()
	else
		print("Not inside tmux session")
	end
end, "Create new tmux pane on the right")

