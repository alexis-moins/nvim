-- ┌────────────────────┐
-- │ MINI configuration │
-- └────────────────────┘
--
-- This file contains configuration of the MINI parts of the config.
-- It contains only configs for the '.vim-mini' plugins.lua').
--
-- To minimize the time until first screen draw, modules are enabled in two steps:
-- - Step one enables everything that is needed for first draw with `now()`.
--   Sometimes is needed only if Neovim is started as `nvim -- path/to/file`.
-- - Everything else is delayed until the first draw with `later()`.
local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later
local now_if_args = _G.Config.now_if_args

-- Icon provider. Usually no need to use manually. It is used by plugins like
-- 'mini.pick', 'mini.files', 'mini.statusline', and others.
now(function()
  add('nvim-mini/mini.icons')
  require('mini.icons').setup()

  -- Mock 'nvim-tree/nvim-web-devicons' for plugins without 'mini.icons' support.
  -- Not needed for 'mini.nvim' or MiniMax, but might be useful for others.
  later(MiniIcons.mock_nvim_web_devicons)

  -- Add LSP kind icons. Useful for 'mini.completion'.
  later(MiniIcons.tweak_lsp_kind)
end)

-- Notifications provider. Shows all kinds of notifications in the upper right
-- corner (by default).
now(function()
  add('nvim-mini/mini.notify')
  require('mini.notify').setup()
end)

-- Extra 'mini.nvim' functionality.
later(function()
  add('nvim-mini/mini.extra')
  require('mini.extra').setup()
end)

-- Extend and create a/i textobjects, like `:h a(`, `:h a'`, and more).
-- Contains not only `a` and `i` type of textobjects, but also their "next" and
-- "last" variants that will explicitly search for textobjects after and before
-- cursor.
later(function()
  add('nvim-mini/mini.ai')
  local ai = require('mini.ai')

  ai.setup({
    -- 'mini.ai' can be extended with custom textobjects
    custom_textobjects = {
      -- Make `aB` / `iB` act on around/inside whole *b*uffer
      B = MiniExtra.gen_ai_spec.buffer(),

      -- For more complicated textobjects that require structural awareness,
      -- use tree-sitter. This example makes `aF`/`iF` mean around/inside function
      -- definition (not call). See `:h MiniAi.gen_spec.treesitter()` for details.
      f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
    },

    -- 'mini.ai' by default mostly mimics built-in search behavior: first try
    -- to find textobject covering cursor, then try to find to the right.
    -- Although this works in most cases, some are confusing. It is more robust to
    -- always try to search only covering textobject and explicitly ask to search
    -- for next (`an`/`in`) or last (`al`/`il`).
    -- Try this. If you don't like it - delete next line and this comment.
    -- search_method = "cover",
  })
end)

-- Completion and signature help. Implements async "two stage" autocompletion:
-- - Based on attached LSP servers that support completion.
-- - Fallback (based on built-in keyword completion) if there is no LSP candidates.
--
-- It also works with snippet candidates provided by LSP server. Best experience
-- when paired with 'mini.snippets' (which is set up in this file).
later(function()
  -- Customize post-processing of LSP responses for a better user experience.
  -- Don't show 'Text' suggestions (usually noisy) and show snippets last.
  local process_items_opts = { kind_priority = { Text = -1, Snippet = 99 } }

  local process_items = function(items, base)
    return MiniCompletion.default_process_items(items, base, process_items_opts)
  end

  add('nvim-mini/mini.completion')

  require('mini.completion').setup({
    lsp_completion = {
      -- Without this config autocompletion is set up through `:h 'completefunc'`.
      -- Although not needed, setting up through `:h 'omnifunc'` is cleaner
      -- (sets up only when needed) and makes it possible to use `<C-u>`.
      source_func = 'omnifunc',

      auto_setup = false,
      process_items = process_items,
    },

    -- Fallback to built-in completion
    fallback_action = '<C-x><C-n>',

    mappings = {
      force_twostep = '<C-n>',
    },
  })

  -- Set 'omnifunc' for LSP completion only when needed.
  Config.new_autocmd(
    'LspAttach',
    nil,
    function(ev) vim.bo[ev.buf].omnifunc = 'v:lua.MiniCompletion.completefunc_lsp' end
  )

  -- Advertise to servers that Neovim now supports certain set of completion and
  -- signature features through 'mini.completion'.
  vim.lsp.config('*', { capabilities = MiniCompletion.get_lsp_capabilities() })
end)

-- Manage and expand snippets (templates for a frequently used text).
-- Typical workflow is to type snippet's (configurable) prefix and expand it
-- into a snippet session.
--
-- How to manage snippets:
-- - 'mini.snippets' itself doesn't come with preconfigured snippets. Instead there
--   is a flexible system of how snippets are prepared before expanding.
--   They can come from pre-defined path on disk, 'snippets/' directories inside
--   config or plugins, defined inside `setup()` call directly.
-- - This config, however, does come with snippet configuration:
--     - 'snippets/global.json' is a file with global snippets that will be
--       available in any buffer
--     - 'after/snippets/lua.json' defines personal snippets for Lua language
--     - 'friendly-snippets' plugin configured in 'plugin/40_plugins.lua' provides
--       a collection of language snippets
--
-- How to expand a snippet in Insert mode:
-- - If you know snippet's prefix, type it as a word and press `<C-j>`. Snippet's
--   body should be inserted instead of the prefix.
-- - If you don't remember snippet's prefix, type only part of it (or none at all)
--   and press `<C-j>`. It should show picker with all snippets that have prefixes
--   matching typed characters (or all snippets if none was typed).
--   Choose one and its body should be inserted instead of previously typed text.
--
-- How to navigate during snippet session:
-- - Snippets can contain tabstops - places for user to interactively adjust text.
--   Each tabstop is highlighted depending on session progression - whether tabstop
--   is current, was or was not visited. If tabstop doesn't yet have text, it is
--   visualized with special "ghost" inline text: • and ∎ by default.
-- - Type necessary text at current tabstop and navigate to next/previous one
--   by pressing `<C-l>` / `<C-h>`.
-- - Repeat previous step until you reach special final tabstop, usually denoted
--   by ∎ symbol. If you spotted a mistake in an earlier tabstop, navigate to it
--   and return back to the final tabstop.
-- - To end a snippet session when at final tabstop, keep typing or go into
--   Normal mode. To force end snippet session, press `<C-c>`.
later(function()
  add('nvim-mini/mini.snippets')
  local snippets = require('mini.snippets')

  snippets.setup({
    snippets = {
      -- Load custom file with global snippets first
      snippets.gen_loader.from_file(
        vim.fn.stdpath('config') .. '/snippets/global.json'
      ),

      -- Load snippets based on current language by reading files from
      -- "snippets/" subdirectories from 'runtimepath' directories.
      snippets.gen_loader.from_lang(),
    },
  })

  -- By default snippets available at cursor are not shown as candidates in
  -- 'mini.completion' menu. This requires a dedicated in-process LSP server
  -- that will provide them. To have that, uncomment next line (use `gcc`).
  MiniSnippets.start_lsp_server()
end)

-- Work with diff hunks that represent the difference between the buffer text and
-- some reference text set by a source. Default source uses text from Git index.
-- Also provides summary info used in developer section of 'mini.statusline'.
later(function()
  add('nvim-mini/mini.diff')
  require('mini.diff').setup({
    view = {
      style = 'sign',
      signs = { add = '┃', change = '┃', delete = '┃' },
    },
  })
end)

-- Navigate and manipulate file system
--
-- Navigation is done using column view (Miller columns) to display nested
-- directories, they are displayed in floating windows in top left corner.
--
-- Manipulate files and directories by editing text as regular buffers.
later(function()
  add('nvim-mini/mini.files')
  require('mini.files').setup({
    mappings = {
      go_in_plus = '<CR>',
    },
  })
end)

-- Highlight patterns in text. Like `TODO`/`NOTE` or color hex codes.
later(function()
  add('nvim-mini/mini.hipatterns')

  local hipatterns = require('mini.hipatterns')
  local words = MiniExtra.gen_highlighter.words

  hipatterns.setup({
    highlighters = {
      -- Highlight a fixed set of common words. Will be highlighted in any place,
      -- not like "only in comments".
      todo = words({ 'TODO', 'todo' }, 'MiniHipatternsTodo'),
      note = words({ 'NOTE', 'note' }, 'MiniHipatternsNote'),
      fixme = words({ 'FIXME', 'fixme' }, 'MiniHipatternsFixme'),
      deprecate = words({ 'DEPRECATE', 'deprecate' }, 'MiniHipatternsDeprecate'),

      -- Highlight hex color string (#aabbcc) with that color as a background
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
end)

-- Move any selection in any direction.
later(function()
  add('nvim-mini/mini.move')
  require('mini.move').setup({
    mappings = {
      -- Normal mode
      up = '<C-K>',
      down = '<C-J>',
      left = '<C-H>',
      right = '<C-L>',

      -- Visual mode
      line_up = '<C-K>',
      line_down = '<C-J>',
      line_left = '<C-H>',
      line_right = '<C-L>',
    },
  })
end)

-- Text edit operators. All operators have mappings for:
-- - Regular operator (waits for motion/textobject to use)
-- - Current line action (repeat second character of operator to activate)
-- - Act on visual selection (type operator in Visual mode)
later(function()
  add('nvim-mini/mini.operators')
  require('mini.operators').setup({ replace = { prefix = 'cr' } })
end)

-- Autopairs functionality. Insert pair when typing opening character and go over
-- right character if it is already to cursor's right. Also provides mappings for
-- `<CR>` and `<BS>` to perform extra actions when inside pair.
later(function()
  add('nvim-mini/mini.pairs')
  require('mini.pairs').setup({ modes = { command = true } })
end)

-- Pick anything with single window layout and fast matching. This is one of
-- the main usability improvements as it powers a lot of "find things quickly"
-- workflows.
later(function()
  add('nvim-mini/mini.pick')
  require('mini.pick').setup()
end)

-- Surround actions: add/delete/replace/find/highlight. Working with surroundings
-- is surprisingly common: surround word with quotes, replace `)` with `]`, etc.
-- This module comes with many built-in surroundings, each identified by a single
-- character. It searches only for surrounding that covers cursor and comes with
-- a special "next" / "last" versions of actions to search forward or backward
-- (just like 'mini.ai'). All text editing actions are dot-repeatable (see `:h .`).
later(function()
  add('nvim-mini/mini.surround')
  require('mini.surround').setup()
end)

-- Split and join arguments (regions inside brackets between allowed separators).
-- It uses Lua patterns to find arguments, which means it works in comments and
-- strings but can be not as accurate as tree-sitter based solutions.
-- Each action can be configured with hooks (like add/remove trailing comma).
later(function()
  add('nvim-mini/mini.splitjoin')
  require('mini.splitjoin').setup()
end)

-- Special key mappings. Provides helpers to map:
-- - Multi-step actions. Apply action 1 if condition is met; else apply
--   action 2 if condition is met; etc.
-- - Combos. Sequence of keys where each acts immediately plus execute extra
--   action if all are typed fast enough. Useful for Insert mode mappings to not
--   introduce delay when typing mapping keys without intention to execute action.
later(function()
  add('nvim-mini/mini.keymap')
  require('mini.keymap').setup()

  -- Navigate completion menu and snippets with `<Tab>` /  `<S-Tab>`
  MiniKeymap.map_multistep('i', '<Tab>', {
    'minisnippets_next',
    'pmenu_next',
  })

  MiniKeymap.map_multistep('i', '<S-Tab>', {
    'minisnippets_prev',
    'pmenu_prev',
  })

  -- On `<CR>` try to accept current completion item, fall back to accounting
  -- for pairs from 'mini.pairs'
  MiniKeymap.map_multistep('i', '<CR>', {
    'pmenu_accept',
    'minipairs_cr',
  })

  -- On `<BS>` just try to account for pairs from 'mini.pairs'
  MiniKeymap.map_multistep('i', '<BS>', { 'minipairs_bs' })

  -- MiniKeymap.map_combo({ "n", "x" }, "jj", "}")
  -- MiniKeymap.map_combo({ "n", "x" }, "kk", "{")
end)

later(function()
  add('nvim-mini/mini.hues')
  vim.cmd("colorscheme mini-mocha")
end)
