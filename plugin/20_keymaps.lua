-- ┌─────────────────┐
-- │ Custom mappings │
-- └─────────────────┘
--
-- This file contains definitions of custom general and Leader mappings.

-- General ====================================================================

-- Use this section to add custom general mappings. See `:h vim.keymap.set()`.
local map = _G.Config.map

map("i", "jk", "<Esc>", "Leave insert mode")
map("n", "<C-E>", "<C-^>", "Edit alternate file")

map("n", "<BS>", vim.cmd.nohlsearch, "Clear search highlighting")
map("n", "<Leader>so", vim.cmd.source, "Source current file")

map("n", "<Leader>o", vim.cmd.only, "Close all splits")
map("n", "<Leader>-", vim.cmd.bdelete, "Delete the current buffer")

map({ "n", "v" }, "j", "gj", "Move down (respects wrap)")
map({ "n", "v" }, "k", "gk", "Move up (respects wrap)")

map("n", "<C-U>", "<C-U>zz", "Scroll upwards (center)")
map("n", "<C-D>", "<C-D>zz", "Scroll downwards (center)")

map("n", "n", "nzz", "Repeat last search (center)")
map("n", "N", "Nzz", "Repeat last search in opposite direction (center)")

map({ "n", "x" }, "gy", '"+y', "Copy (+register)")

map({ "n", "x" }, "gp", '"+p', "Paste after cursor (+register)")
map({ "n", "x" }, "gP", '"+P', "Paste before cursor (+register)")

map("n", "c*", '*``"_cgn', "Replace word under cursor (dot repeatable)")
map("n", "c#", '#``"_cgN', "Backward replace word under cursor (dot respeatable)")

map("n", "d*", '*``"_dgn', "Delete word under cursor (dot repeatable)")
map("n", "d#", '#``"_dgN', "Backward delete word under cursor (dot respeatable)")

map("n", "H", "<Cmd>lua vim.diagnostic.open_float()<CR>", "")

-- Plugins ====================================================================

map("n", "<Leader><Space>", "<Cmd>Pick files<CR>", "Find files")
map("n", "<C-b>", "<Cmd>Pick buffers<CR>", "Find buffers")

map("n", "<Leader>fg", "<Cmd>Pick grep_live<CR>", "Grep files")
map("n", "<Leader>*", "<Cmd>Pick grep pattern='<cword>'<CR>", "Grep <cword>")

-- map("n", "<Leader>z", MiniPick.builtin.resume, "Resume last picker")

map("n", "<Leader>fk", "<Cmd>Pick keymaps<CR>", "Find keymaps")
map("n", "<Leader>fh", "<Cmd>Pick help<CR>", "Find help")

-- map("n", "z=", MiniExtra.pickers.spellsuggest, "Find spelling")

map("n", "-", "<Cmd>lua MiniFiles.open(vim.fn.expand('%'))<CR>", "Open file explorer")
map("n", "+", "<Cmd>lua MiniFiles.open()<CR>", "Open file explorer (cwd)")

map("n", "=", "<Cmd>lua require('conform').format()<CR>", "Format file")

map("n", [[\d]], "<Cmd>lua MiniDiff.toggle_overlay()<CR>", "Toggle diff overlay")
map("n", [[\g]], "<Cmd>lua MiniDiff.toggle()<CR>", "Toggle git signs")
