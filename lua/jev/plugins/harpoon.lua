vim.keymap.set("n", "<leader>ha", function()
	vim.cmd("argadd %")
	vim.cmd("argdedup")
	vim.cmd.args()
end)

vim.keymap.set("n", "<leader>he", function()
	vim.cmd.args()
end)

vim.keymap.set("n", "<leader>hd", function()
	vim.cmd("argdelete %")
    vim.cmd.args()
end)

vim.keymap.set("n", "<leader>hh", function()
	vim.cmd("silent! 1argument")
end)

vim.keymap.set("n", "<leader>hj", function()
	vim.cmd("silent! 2argument")
end)
