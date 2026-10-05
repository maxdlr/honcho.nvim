# honcho.nvim

A Telescope command picker for Neovim. Build a dropdown list of labeled actions and open it wherever you want.

## Requirements

telescope.nvim. Nothing else.

## Setup

```lua
require('honcho').setup()
```

`setup()` is optional. It only matters if you want to override the default colors.

### Default config

```lua
{
  defaults = {
    color = {
      fg = '#ffffff',
      neutral = '#555555',
    },
  },
}
```

`fg` is the label color for normal command entries. `neutral` is the label color for separators.

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

local cmds = {
  {
    label = 'test command',
    action = function()
      print('hello')
    end,
  },
  {
    label = '------ separator -------',
    action = false,
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
- `false`, marks the entry as a non-selectable separator

Optional per-entry fields:

- `color` — hex color (e.g. `'#FF8800'`) for that entry's label text. Defaults to `fg` from the config.
- `description` — shown next to the label, dimmed (`Comment` highlight).
- `icon` — shown before the label (e.g. a Nerd Font glyph).

Fields must be named (`label = ...`, `action = ...`). Positional table entries (`{ 'label', fn }`) will not work.

```lua
{
  label = 'format buffer',
  action = function() vim.lsp.buf.format() end,
  icon = '',
  description = 'via LSP',
  color = '#7aa2f7',
}
```

`picker(title, commands, opts)` returns a function — call it from a keymap, a user command, wherever.

- `opts.border_color` — hex color to override the Telescope border/prompt title color while the picker is open. Restored on close.
- `opts.width` — fixed width (in columns) for the picker window. Defaults to the longest label's display width plus padding.

## Features

- Opens a Telescope dropdown from a list of commands.
- Runs a function or a vim command on selection.
- Separator rows: grayed out, skipped when navigating with arrows or `<C-n>`/`<C-p>`.
- Per-picker border color, restored automatically on close.
- Global label colors configurable via `setup()`.
