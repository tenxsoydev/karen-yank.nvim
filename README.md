<!-- panvimdoc-ignore-start -->

# karen-yank 👩🏼‍🏫

Karen Yank<br>
<sup>– deletes, cuts and yanks your way</sup>

<!-- panvimdoc-ignore-end -->

## Objective

- Make use of registers more intentional while remaining intuitive for experienced and novice VIM users.

## Usage

After installation there is nothing to do besides enjoying cleaner registers.

Delete keys like <kbd>d</kbd>, <kbd>D</kbd>, <kbd>c</kbd> etc. will genuinely **delete** by default, and **cut** in a `<karen><delete key>` key-chord. The results is that deletions after yanks and cuts won't mess with <kbd>p</kbd> so it will only use the last cut text, the contents of your system clipboard, or a register specified before pasting.

Your yanks and cuts are also extended to use VIMs number registers while keeping them free of duplicates.

### Keymaps

By default, `karen` is mapped to <kbd>y</kbd>.

All predefined mappings stay true to VIMs defaults:

- a _motion_ like <kbd>ciw</kbd> will delete a word and start insert, while <kbd>yciw</kbd> will cut a word and start insert. <kbd>dd</kbd> deletes a line, <kbd>ydd</kbd> cuts a line etc.
- in _visual_ mode <kbd>yd</kbd> pressed in `timeoutlen` will cut. While just <kbd>y</kbd> will yank as usual after `timeoutlen` (or immediately when followed by something like a movement with <kbd>j</kbd>. So no impairments with fast typing)

To invert the functionality i.e., using `<karen>d` to delete into the black hole register, check the config section.

## Installation

E.g., using a plugin manager like [packer.nvim][10]

```lua
use "tenxsoydev/karen-yank.nvim"
```

Then load it like most of your other plugins

```lua
require("karen-yank").setup()
```

When using [lazy.nvim][15] you can just add this line to your `lazy.setup()`

```lua
{ "tenxsoydev/karen-yank.nvim", config = true },
```

## Config

Defaults:

```lua
require("karen-yank").setup {
  mappings = {
    -- karen controls the use of registers (and probably talks to the manager when things doesn't work as intended)
    -- map something like `<leader><leader>` if you use the plugin inverted
    karen = "y",
    -- true: delete into black hole by default and use registers with karen key
    -- false: use registers by default and delete into black hole with karen key
    invert = false,
    -- disable all if `true` or a table of keymaps [possible values: {"s"|"S"|"d"|"D"|"c"|"C"|"x"|"X"|"p"|"P"|"y"|"Y"}]
    -- "s"/"S" is not mapped by default, due to it's common utilization for plugins like surround or hop
    disable = { "s", "S" },
  },
  number_regs = {
    -- use number registers for yanks and cuts
    enable = true,
    deduplicate = {
      -- prevent populating multiple number registers with the same entries
      enable = true,
      -- will see `yD` pressed at the beginning of a line as a duplicate of `ydd` pressed in the same line
      ignore_whitespace = true,
    },
  },
}
```

### Custom mappings

Karen exposes four actions that can be used in expression mappings

<details>
<summary><code>local actions = require("karen-yank.actions")</code> <sub><sup>click to expand...</sup></sub></summary>

```lua
local actions = require("karen-yank.actions")

---@param vim_parent "d"|"D"|"c"|"C"|"x"|"X"|"s"|"S"
actions.cut(vim_parent)

---@param vim_parent "d"|"D"|"c"|"C"|"x"|"X"|"s"|"S"
actions.delete(vim_parent)

---@param kind "motion"|"line"|"trail"
---@param opts? { preserve_cursor: boolean, preserve_selection: boolean }
-- default opts = { preserve_cursor = true, preserve_selection = false }
actions.yank(kind, opts)

---@param direction "before"|"after"
---@param opts? { black_hole: boolean, preserve_selection: boolean }
-- default opts = { black_hole = true, preserve_selection = false }
actions.paste(direction, opts)

-- Example mappings (equivalent to defaults)
local map = vim.keymap.set
map("", "d", function() return actions.delete("d") end, { expr = true })
map("", "yd", function() return actions.cut("d") end, { expr = true })
map("", "D", function() return actions.delete("D") end, { expr = true })
map("", "yD", function() return actions.cut("D") end, { expr = true })
map("", "c", function() return actions.delete("c") end, { expr = true })
map("", "yc", function() return actions.cut("c") end, { expr = true })
-- ...
map("", "y", function() return actions.yank("motion") end, { expr = true })
map("", "yy", function() return actions.yank("line") end, { expr = true })
map("", "Y", function() return actions.yank("trail") end, { expr = true })
--
map("v", "p", function() return actions.paste(direction, { black_hole = true }) end, { expr = true })
map("v", "yp", function() return actions.paste(direction, { black_hole = false }) end, { expr = true })
```

</details>

## Additional Info

Karen is mainly designed to be used with nvim in conjunction with the system `clipboard=unnamedplus`. For other modes, not all functions of the plugin may work. If you notice unexpected behavior with the mode you are using, feel free to open an issue.

If the plugin offered some value to you, filling the ☆ of this repo with color warms the heart of your fellow developer.

## Why?

There are a dozen of plugins that deal with VIMs yanks and registers so why another one?

- karen-yank.nvim is rather a complementary helper than a competitor. E.g., other plugins to use it with:
  - [`registers.nvim`][20] for a general enhancement of interaction with registers
  - [`Telescope`][30]'s `registers` subcommand for fuzzy searching register contents
  - Any clipboard manager for your OS
- It was already finished: The UX this plugin provides was a part of my vim config since its pre-lua days.
  Wrapping it up in a plugin and making it public to other strangers like me was just a matter of making some of its functionalities configurable - _hoping not to have messed anything up along the way_.

[00]: https://github.com/tenxsoydev/karen-yank.nvim#karen-yank-
[05]: https://github.com/tenxsoydev/karen-yank.nvim#additional-info
[10]: https://github.com/wbthomason/packer.nvim
[15]: https://github.com/folke/lazy.nvim
[20]: https://github.com/tversteeg/registers.nvim
[30]: https://github.com/nvim-telescope/telescope.nvim
