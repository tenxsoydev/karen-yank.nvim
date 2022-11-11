# karen-yank 👩🏼‍🏫

Karen Yank<br>
<sup>– cuts, deletes and copies your way</sup>

## Main idea

- Enhance Neovims behavior related to `delete` and `yank` mappings without new mental overhead
- Make the usage of registers more intentional

## Usage

With the plugin's default configuration, deletions will only populate registers / your clipboard when intended.

Delete keys like `d`, `D`, `c` etc. will **delete** (into the black hole register `"_`) and **cut** in a `<karen><delete key>` key-chord (e.g., `yd`). Therefore, `p` will use only the last cut text, the contents of your system clipboard, or a register specified before pasting.

The mappings stay true to VIMs defaults:

- a _motion_ like `ciw` will delete a word and start insert, while `yciw` will cut a word and start insert. `dd` deletes a line, `ydd` cuts a line etc.
- in _visual_ mode `yd` pressed in \*`timeoutlen` will cut. While just `y` will yank as usual after `timeoutlen` (or immediately when followed by something like a movement with `j`. So no impairments with fast typing)

To invert the functionality i.e., using `<karen>d` to delete into the black hole register, check the config section.

<details>

<summary><sub><code>*timeoutlen</code>…</sub></summary>

<blockquote><sub>"Time in milliseconds to wait for a mapped sequence to complete" (default 1000ms) – vim-docs.</sub></blockquote>

<sub> Adding my two cents to this VIM setting that go beyond the use of this plugin:
</sub>

<sub> From a musical point of view, one could say that this is the time interval in which a sequence of notes in an arpeggio needs to be played in order to be recognized as a chord.
</sub>

<sub> A value like `350` is suitable imo. It is usually sufficient to press the "initializing" keys of a sequence in this time frame. For this plugin this would be e.g. `yd`, then it will wait for the rest of the motion keys. Values that are too short can cause unintended behavior and interference with some keyboards. In my experience, some key sequences, e.g., on programmable keyboards with Tap-Hold layer keys may not get tracked with a timeoutlen < 200. Check `:h timeoutlen` to set it up to your preference with related settings.
</sub>

</details>

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
		-- True: paste-over-selection will delete replaced text without moving it into a register - Vim default.
		-- False: paste-over-selection will move the replaced text into a register
		black_hole_default = true,
		preserve_selection = false,
	},
	number_regs = {
		-- Use number registers for yanks and cuts
		enable = true,
		-- Prevent populating multiple number registers with the same entries
		deduplicate = {
			enable = true,
			-- Trim white space around texts. In deduplication of VIMs number registers this results in e.g.,
			-- `yD` pressed at the beginning of a line to be considered a duplicate of `dd` pressed in the same line
			no_whitespace = true,
		},
		-- For some conditions karen will use a transitory register
		transitory_reg = {
			-- Register to use
			reg = "y",
			-- Placeholder with which the register will be filled after use
			-- E.g. possible values are '""' to clear it or 'false' to leave the transient content
			placeholder = "👩🏼",
		},
	},
	mappings = {
		-- The key that controls usage of registers - will probably talk to the manager when things don't work as intended
		-- You can map e.g., "<leader><leader>" if you are using the plugin inverted(black_whole_default=false)
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
<summary><i>Plugin-related functionalities</i></summary>

Since there is no real API, the configuration strives to provide all the options on which a user could potentially fall short if he tries to customize the plugin's behavior.

There are many mappings and customizations related to the cut, yank, delete actions that can further expand the workflows in which Karen can be used.
However, creating an extended set of predefined commands and keyboard mappings was not considered appropriate, as they can be created in nvim's own configuration with maximum customizability.
To give three simple examples:

1. As `ddp` and `ddP` is sometimes used to move lines down / up.
   One could use `<A-j>` and `<A-k>` to move lines and ranges.

   ```lua
   local map = vim.keymap.set
   -- ...
   -- Move Lines: using `:` vs `<Cmd>` makes a difference
   map("i", "<A-j>", "<Esc>:m .+1<CR>==gi", { desc = "Move Line Down" })
   map("i", "<A-k>", "<Esc>:m .-2<CR>==gi", { desc = "Move Line Up" })
   map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move Line Down" })
   map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move Line Up" })
   map("v", "<A-j>", ":m '>+1<CR>gv-gv", { desc = "Move Lines Down" })
   map("v", "<A-k>", ":m '<-2<CR>gv-gv", { desc = "Move Lines Up" })
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

## Justification

There are dozen of plugins that deal with VIMs yanks and registers so why another one?

- karen-yank.nvim is rather a complementary helper than a competitor. E.g., other plugins to use it with:
  - [`registers.nvim`][20] for a general enhancement of interaction with registers
  - [`Telescope`][30]'s `registers` subcommand for fuzzy searching register contents
  - Any clipboard manager for your OS
- It was already finished: The UX this plugin provides was a part of my vim config since its pre-lua days.
  Wrapping it up in a plugin and making it public for other strangers like me was just a matter of making some of its functionalities configurable - _hoping not to have messed anything up along the way_.

[10]: https://github.com/wbthomason/packer.nvim
[20]: https://github.com/tversteeg/registers.nvim
[30]: https://github.com/nvim-telescope/telescope.nvim
