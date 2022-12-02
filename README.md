# karen-yank 👩🏼‍🏫

Karen Yank<br>
<sup>– cuts, deletes and copies your way</sup>

## Main idea

- Enhance Neovims behavior related to `delete` and `yank` mappings.
- Make the use of registers more intentional while remaining intuitive for both experienced and new VIM users.

## Usage

With [karen-yank.nvim][00] delete keys like <kbd>d</kbd>, <kbd>D</kbd>, <kbd>c</kbd> etc. will genuinely **delete** by default (into the black hole register `"_`), and **cut** in a `<karen><delete key>` key-chord (e.g., <kbd>yd</kbd>). This results in <kbd>p</kbd> using only the last cut text, the contents of your system clipboard, or a register specified before pasting.

Your yanks and cuts are also extended to use VIMs number registers while keeping them free of duplicates

### Keymaps

The mappings stay true to VIMs defaults:

- a _motion_ like <kbd>ciw</kbd> will delete a word and start insert, while <kbd>yciw</kbd> will cut a word and start insert. <kbd>dd</kbd> deletes a line, <kbd>ydd</kbd> cuts a line etc.
- in _visual_ mode <kbd>yd</kbd> pressed in <sup>\*</sup>`timeoutlen` will cut. While just <kbd>y</kbd> will yank as usual after `timeoutlen` (or immediately when followed by something like a movement with <kbd>j</kbd>. So no impairments with fast typing)

<sub>To invert the functionality i.e., using `<karen>d` to delete into the black hole register, check the config section.</sub>

## Installation

E.g., using a plugin manager like [packer.nvim][10]

```lua
use "tenxsoydev/karen-yank.nvim"
```

Then load it like most of your other plugins

```lua
require("karen-yank").setup()
```

## Config

Defaults:

```lua
require("karen-yank").setup {
  on_delete = {
    -- True: delete into "_ by default; use regular registers with karen key
    -- False: use regular registers by default; delete into "_ with karen key
    black_hole_default = true,
  },
  on_yank = {
    -- Preserve cursor position on yank
    preserve_cursor = true,
    preserve_selection = false,
  },
  on_paste = {
    -- True: paste-over-selection will delete replaced text without moving it into a register
    -- False: paste-over-selection will move the replaced text into a register
    black_hole_default = true,
    preserve_selection = false,
  },
  number_regs = {
    -- Use number registers for yanks and cuts
    enable = true,
    deduplicate = {
      -- Prevent populating multiple number registers with the same entries
      enable = true,
      -- Causes e.g. yD pressed at the beginning of a line to be considered a duplicate of ydd pressed in the same line
      ignore_whitespace = true,
    },
    -- For some conditions karen will use a transitory register
    transitory_reg = {
      -- Register to use
      reg = "y",
      -- Placeholder with which the register will be filled after use
      placeholder = "👩🏼",
    },
  },
  mappings = {
    -- The key that controls the use of registers (and probably talks to the manager when things doesn't work as intended)
    -- You can map e.g., "<leader><leader>" if you use the plugin inverted(black_whole_default=false)
    karen = "y",
    -- Unused keys possible values: { "d", "D", "c", "C", "x", "X", "s", "S" },
    -- "S" / "s" are often utilized for plugins like surround or hop. Therefore, they are not used by default
    unused = { "s", "S" },
  },
}

```

## Additional Info

Karen is mainly designed to be used with nvim in conjunction with the system clipboard ("unnamedplus"). For other modes, not all functions of the plugin may work. But please do not hesitate to reach out if you experience unexpected behavior with the mode you are using.

<details>
<summary>Plugin-related functionalities</summary>

Since there is no real API, the configuration strives to provide all the options on which a user could potentially fall short if he tries to customize the plugin's behavior.

Of course, there are other mappings and adjustments related to the cut, yank, delete actions that can further expand the workflows in which Karen can be used.
However, creating an extended set of predefined commands and keyboard mappings was not considered appropriate, as they can be created in nvim's own configuration with maximum customizability. To give three simple examples:

1. As `ddp` and `ddP` is sometimes used to move lines down / up.
   One could use `<A-j>` and `<A-k>` to move lines and ranges.

   ```lua
   local map = vim.keymap.set
   -- ...
   -- Move Lines (using `:` vs `<Cmd>` makes a difference)
   map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move Line Down" })
   map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move Line Up" })
   map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move Line Down" })
   map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move Line Up" })
   map("v", "<A-j>", ":m '>+1<CR>gv-gv", { desc = "Move Lines Down" })
   map("v", "<A-k>", ":m '<-2<CR>gv-gv", { desc = "Move Lines Up" })
   -- Duplicate Lines
   map("n", "<A-S-j>", '"dyy"dp', { desc = "Duplicate Line Down" })
   map("n", "<A-S-k>", '"dyy"dP', { desc = "Duplicate Line Up" })
   map("v", "<A-S-j>", "\"dy']\"dp`]'[V']", { desc = "Duplicate Lines Down" })
   map("v", "<A-S-k>", "\"dy\"dP'[V']", { desc = "Duplicate Lines Up" })
   ```

2. Highlight on yank

   ```lua
   vim.api.nvim_create_autocmd(
   	"TextYankPost",
   	{ callback = function() vim.highlight.on_yank { higroup = "IncSearch", timeout = 150 } end }
   )
   ```

3. A command to clear registers could look like

   ```lua
   vim.api.nvim_create_user_command("WipeRegisters", function()
   	vim.cmd "for i in range(34,122) | silent! call setreg(nr2char(i), []) | endfor"
   	vim.cmd "wshada!"
   end, { desc = "Clear All Registers" })
   ```

</details>

<details>

<summary><code>*timeoutlen</code>…</summary>

<blockquote><sub>"Time in milliseconds to wait for a mapped sequence to complete" (default 1000ms) – <a href="https://neovim.io/doc/user/options.html#'timeoutlen'">vim-docs.</a></sub></blockquote>

<sub>The way this setting works can also be described from a musical point of view. Then one could say that this is the time interval in which a sequence of notes in an arpeggio must be played in order to be recognized as a chord.
</sub>

<sub> A value like `350` is suitable imo. It is usually sufficient to press the "initializing" keys of a sequence in this time frame. For this plugin this would be e.g., `yd` in normal mode. Then it will wait for the rest of the motion. Values that are too short can cause unintended behavior and interference with some keyboards. In my experience, some key sequences, e.g., on programmable keyboards with Tap-Hold layer keys may not get tracked with a timeoutlen < 200. Check `:h timeoutlen` to set it up to your preference with related settings.
</sub>

</details>

## Justification

There are a dozen of plugins that deal with VIMs yanks and registers so why another one?

- karen-yank.nvim is rather a complementary helper than a competitor. E.g., other plugins to use it with:
  - [`registers.nvim`][20] for a general enhancement of interaction with registers
  - [`Telescope`][30]'s `registers` subcommand for fuzzy searching register contents
  - Any clipboard manager for your OS
- It was already finished: Most of the UX this plugin provides was a part of my vim config since its pre-lua days.
  Wrapping it up in a plugin and making it public for other strangers like me was just a matter of making some of its functionalities configurable - _hoping not to have messed anything up along the way_.

[00]: https://github.com/tenxsoydev/karen-yank.nvim#karen-yank-
[05]: https://github.com/tenxsoydev/karen-yank.nvim#additional-info
[10]: https://github.com/wbthomason/packer.nvim
[20]: https://github.com/tversteeg/registers.nvim
[30]: https://github.com/nvim-telescope/telescope.nvim
