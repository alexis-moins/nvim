keys.map("i", "jk", "<Esc>", "Leave insert mode")

keys.map("n", "/", "ms/", "Search a pattern forward")
keys.map("n", "?", "ms?", "Search a pattern backward")

keys.map("n", "<BS>", vim.cmd.nohlsearch, "Clear search highlighting")
keys.map("n", "<Leader>so", vim.cmd.source, "Source current file")

keys.map("n", "<Leader>o", vim.cmd.only, "Close all splits")
keys.map("n", "<Leader>-", vim.cmd.bdelete, "Delete the current buffer")

-- Play @q macro and move to next line (recursive)
keys.map("n", "Q", "@qj", "Play macro")
keys.map("x", "Q", "<cmd>norm @q<cr>", "Play macro")

-- Stay in place
keys.map("n", "J", "mzJ`z", "Join line below without moving cursor")

-- Easier line navigation
keys.map({ "n", "v" }, "L", "g$", "Go to the end of the line (respects wrap)")
keys.map({ "n", "v" }, "H", "g^", "Go to the begining of the line (respects wrap)")
keys.map({ "n", "v" }, "j", "gj", "Move down (respects wrap)")
keys.map({ "n", "v" }, "k", "gk", "Move up (respects wrap)")

keys.map("n", "<C-E>", "``", "To the postition before the latest jump")

-- Buffers
keys.map("n", "<Tab>", "<C-^>", "Edit alternate file")
keys.map("n", "<Leader>bd", "mP<cmd>sil %bd<bar>e #<bar>bd #<CR>'P", "Close all buffers but current one")

-- Scroll with centering
keys.map("n", "<C-U>", "<C-U>zz", "Scroll upwards (center)")
keys.map("n", "<C-D>", "<C-D>zz", "Scroll downwards (center)")

keys.map("n", "n", "nzz", "Repeat last search (center)")
keys.map("n", "N", "Nzz", "Repeat last search in opposite direction (center)")

keys.map({ "n", "x" }, "gy", '"+y', "Copy (+register)")
keys.map({ "n", "x" }, "gp", '"+p', "Paste after cursor (+register)")
keys.map({ "n", "x" }, "gP", '"+P', "Paste before cursor (+register)")

keys.map("v", "s", ":s/\\%V", "Substitute inside current visual selection")

keys.map("n", "g.", ":%s/<C-R><C-W>//gc<left><left><left>", "Substitute word under cursor globally")
keys.map("v", "g.", '"zy:%s/<C-R>z//gc<left><left><left>', "Substitute visual selection globally")

keys.map("n", "X", "daw", "Delete around word")

keys.map("n", "[t", vim.cmd.tabnext, "Navigate to next tab page")
keys.map("n", "]t", vim.cmd.tabprevious, "Navigate to previous tab page")

keys.map("n", "/", "ms/", "Search forward (with mark)")
keys.map("n", "?", "ms?", "Search backward (with mark)")

keys.map("n", "c*", '*``"_cgn', "Replace word under cursor (dot repeatable)")
keys.map("n", "c#", '#``"_cgN', "Backward replace word under cursor (dot respeatable)")

keys.map("n", "d*", '*``"_dgn', "Delete word under cursor (dot repeatable)")
keys.map("n", "d#", '#``"_dgN', "Backward delete word under cursor (dot respeatable)")

--
-- Option toggling
--

-- Numbers on the left
keys.map("n", "\\n", keys.toggle("number"), "Toggle line number")
keys.map("n", "\\r", keys.toggle("relativenumber"), "Toggle relative line number")

-- Toggle colorcolumn
keys.map("n", "\\c", function()
	local value = vim.opt_local.colorcolumn:get()
	opt.setlocal("colorcolumn", #value > 0 and "" or "79")
end, "Toggle colorcolumn")

-- Toggle quickfix list
keys.map("n", "\\q", function()
	for _, win in pairs(vim.fn.getwininfo()) do
		if win.quickfix == 1 then
			-- Close quickfix window if opened
			vim.cmd.cclose()
			return
		end
	end

	vim.cmd.copen()
end, "Toggle quickfix")

-- Wrap lines that are longer than 'textwidth'
keys.map("n", "\\w", keys.toggle("wrap"), "Toggle line wrapping")

-- Spelling errors and suggestions
keys.map("n", "\\s", keys.toggle("spell"), "Toggle spell checking")

keys.map("n", "\\v", function()
	local virtual_lines = not vim.diagnostic.config().virtual_lines
	local virtual_text = not vim.diagnostic.config().virtual_text

	vim.diagnostic.config({ virtual_lines = virtual_lines, virtual_text = virtual_text })
end, "Toggle diagnostic virtual lines")
