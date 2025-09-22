# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Architecture Overview

This is a personal Neovim configuration built around the `mini.nvim` ecosystem and `mini.deps` package manager. The configuration follows a modular structure under the `jev` namespace.

### Directory Structure

- `init.lua` - Entry point that loads `require("jev")`
- `lua/jev/` - Main configuration namespace
  - `init.lua` - Loads deps, core, and plugins
  - `deps.lua` - Package manager setup (mini.deps)
  - `core/` - Core Neovim configuration
    - `globals.lua` - Global helper functions and APIs
    - `options.lua` - Vim options
    - `autocmds.lua` - Autocommands
    - `keymaps.lua` - Key mappings
  - `plugins/` - Plugin configurations (each plugin in separate file)
  - `filetype/` - Filetype-specific configurations
- `after/ftplugin/` - Filetype-specific plugins and settings
- `lsp/` - LSP server configurations
- `colors/` - Custom colorschemes

### Package Management

This configuration uses `mini.deps` instead of traditional plugin managers like lazy.nvim or packer.nvim. Plugin installation is handled by:

```lua
local add = MiniDeps.add
add("plugin-author/plugin-name")
```

### Global Helper APIs

The configuration exposes three global helper APIs defined in `lua/jev/core/globals.lua`:

1. **`_G.opt`** - Option setting helpers:
   - `opt.set(name, value)` - Set vim option
   - `opt.setlocal(name, value)` - Set local option
   - `opt.setglobal(name, value)` - Set global option

2. **`_G.keys`** - Keymap helpers:
   - `keys.map(modes, keys, action, description)` - Create keymap
   - `keys.maplocal(modes, keys, action, description, buffer)` - Create buffer-local keymap
   - `keys.toggle(option)` - Create option toggle function

3. **`_G.event`** - Autocommand helpers:
   - `event.augroup(name)` - Create augroup with "Jev" prefix
   - `event.autocmd` - Alias for `vim.api.nvim_create_autocmd`

## Development Commands

### LSP and Formatting

- **LSP servers managed by Mason**: lua_ls, pyright, ts_ls, vue_ls
- **Formatting via conform.nvim**:
  - Lua: `stylua`
  - Python: `isort`, `black`
  - JavaScript/TypeScript: `prettierd` or `prettier`
  - PHP: `pint`
  - OCaml: `ocamlformat`

### Key Plugin Ecosystems

- **mini.nvim**: Core functionality (picker, completion, git, etc.)
- **Treesitter**: Syntax highlighting and text objects
- **LSP**: Language server integration via Mason
- **Conform**: Code formatting
- **AI integration**: Through dedicated ai.lua plugin

## Working with this Configuration

### Adding New Plugins

1. Add plugin via `MiniDeps.add()` in appropriate plugin file
2. Configure the plugin in the same file
3. Add keymaps using the global `keys.map()` helper
4. Follow the existing pattern of one plugin per file in `lua/jev/plugins/`

### Modifying LSP Settings

- Server-specific configurations go in `lsp/` directory (e.g., `lsp/lua_ls.lua`)
- General LSP configuration is in `lua/jev/plugins/lsp.lua`
- LSP keymaps are set up in the `LspAttach` autocommand

### Adding Filetype Settings

- Use `after/ftplugin/{filetype}.lua` for filetype-specific settings
- Use `lua/jev/filetype/{filetype}.lua` for more complex filetype logic

### Custom Helpers

The configuration includes custom helper functions in `lua/jev/core/helpers.lua` for Treesitter operations and other utilities.