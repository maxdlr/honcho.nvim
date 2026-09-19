# honcho.nvim

A Telescope command picker for Neovim. Build a dropdown list of labeled actions and open it wherever you want.

## Requirements

telescope.nvim. Nothing else.

## Setup

```lua
require('honcho').setup()
```

`setup()` is optional. It only matters if you want to override the default colors.

## Default config

```lua
{
  defaults = {
    color = {
      fg = '#ffffff',
      bg = '#000000',
      neutral = '#555555',
    },
  },
}
```

`fg` is the label color for normal command entries. `neutral` is the label color for separators. `bg` is currently unused.

Override with:

```lua
require('honcho').setup({
  defaults = {
    color = {
      fg = '#ffffff',
      neutral = '#555555',
    },
  },
})
```

## Usage

```lua
local honcho = require('honcho')
local picker = honcho.honcho_picker
local separator = honcho.honcho_separator

local cmds = {
  {
    label = 'test command',
    action = function()
      print('hello')
    end,
  },
  {
    label = '------ separator -------',
    action = separator,
  },
  {
    label = 'open netrw',
    action = 'Explore',
  },
}

vim.keymap.set('n', '<leader>o', picker('Honcho test', cmds), { desc = 'Honcho: pick a task' })
```

Each entry needs `label` and `action`. `action` is one of:

- a function, called when the entry is selected
- a string, run as a vim command (`vim.cmd(action)`)
- `separator`, marks the entry as a non-selectable divider

Fields must be named (`label = ...`, `action = ...`). Positional table entries (`{ 'label', fn }`) will not work — `action` is read by name, not by position.

`picker(title, commands, opts)` returns a function. Call it from a keymap, a user command, wherever. It doesn't run immediately.

`opts.border_color` is optional. Set it to a hex color to override the Telescope border/prompt title color while the picker is open. It's restored when the picker closes.

## What it does so far

- Opens a Telescope dropdown from a list of commands.
- Runs a function or a vim command on selection.
- Supports separator rows: grayed out, skipped when navigating with arrows or `<C-n>`/`<C-p>`.
- Lets you set a custom border color per picker, restored automatically on close.
- Lets you override the default label colors globally via `setup()`.

## What it doesn't do yet

- No per-picker color override beyond `border_color`.
- No validation on malformed command entries (missing `action` will error at selection time, not at picker creation).
- No README-documented named pickers or command registry — you call `picker(...)` directly, there's no `:Honcho` command yet.
