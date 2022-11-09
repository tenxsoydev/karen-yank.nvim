# karen-yank 👩🏼‍🏫

Karen Yank<br>
<sup>– cuts, deletes and copies your way</sup>

## Main idea

- Enhance Neovims behavior related to `delete` and `yank` mappings without new mental overhead
- Make the usage of registers more intentional

## Usage

With the plugin's default configuration, deletions will only populate registers when intended. E.g., `d` will **delete** (into the balck hole register `"_`) by default and **cut** in a `yd` key chord. Therefore, `p` will use only the last cut text or specified registers.

The rest stays true to VIMs defaults:

- a _motion_ like `ciw` will delete a word and start insert, while `yciw` will cut a word and start insert. `dd` deletes a line, `ydd` cuts a line etc.
- in _visual_ mode `yd` pressed in \*`timeoutlen` will cut. While just `y` will yank as usual after `timeoutlen` (or immediately when followed by something like a movement with `j`. So no impairments with fast typing)

To inverse the functionality i.e., using `<karen>d` to delete into the black hole register, check the config section.

<details>
<summary><sub><code>*timeoutlen</code>…</sub></summary>

<blockquote><sub>"Time in milliseconds to wait for a mapped sequence to complete" (default 1000ms) – vim-docs.</sub></blockquote> 
<sub>In musical terms, we could say that this is the time interval in which a sequence of notes in an arpeggio needs to be played in order to be recognized as a chord.</sub>

<sub>A value like `350` is imho appropriate. Values that are too short can cause unintended behavior and interference with some keyboards. In my experience, some key sequences, e.g., on programmable keyboards with Tap-Hold layer keys may not get tracked with a timeoutlen < 200. This is no realted to the use of this plugin. Check `:h timeoutlen` to set it up to your preference.</sub>
</details>

## Installation

E.g., using a plugin a plugin manager like [packer.nvim][10]

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
	on_yank = {
		number_regs = {
			-- Use number registers for yanks
			enable = true,
			-- Prevent populating multiple number registers with the same entries
			deduplicate = true,
		},
		-- True: delete into "_ by default; use regular registers with karen key
		-- False: use regular registers by default; delete into "_ with karen key
		black_hole_default = true,
		-- Preserve cursor position on yank
		preserve_cursor = true,
		preserve_seleciton = false,
	},
	on_paste = {
		-- True: paste-over-selection will delete replaced text without moving it into a register - Vim default.
		-- False: paste-over-selection will move the replaced text into a register
		black_hole_default = true,
		preserve_seleciton = false,
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

## Justification

There are dozen of plugins that deal with VIMs yanks and registers so why another one?

- This plugin is rather a complementary helper than a competitor. E.g., other plugins to use it with:
  - [`registers.nvim`][20] for a general enhancement of interaction with registers
  - [`Telescope`][30]'s `registers` subcommand for fuzzy searching register contents
- It was already finished: The UX this plugin provides was a part of my vim config since its pre-lua days.
  Wrapping it up in a plugin and making it public for other strangers like me was just a matter of making some of its functionalities configurable - _hoping not to have messed anything up along the way_.

[10]: https://github.com/wbthomason/packer.nvim
[20]: https://github.com/tversteeg/registers.nvim
[30]: https://github.com/nvim-telescope/telescope.nvim
