local M = {}

---@class Config
---@field on_delete DeleteOpts
---@field on_yank YankOpts
---@field on_paste PasteOpts
---@field number_regs NumberRegOpts
---@field mappings MappingOpts

---@class DeleteOpts
---@field black_hole_default boolean

---@class YankOpts
---@field preserve_cursor boolean
---@field preserve_selection boolean

---@class PasteOpts
---@field black_hole_default boolean
---@field preserve_selection boolean

---@class NumberRegOpts
---@field enable boolean
---@field deduplicate { enable: boolean, no_whitespace: boolean }
---@field transitory_reg TransitoryRegOpts

---@class TransitoryRegOpts
---@field reg string '[a-z]'
---@field placeholder string|false

---@class MappingOpts
---@field karen string
---@field unused DeleteKey[]

---@alias DeleteKey "d"|"D"|"c"|"C"|"x"|"X"|"s"|"S"

---@type Config
local default_config = {
	on_delete = {
		black_hole_default = true,
	},
	on_yank = {
		preserve_cursor = true,
		preserve_selection = false,
	},
	on_paste = {
		black_hole_default = true,
		preserve_selection = false,
	},
	number_regs = {
		enable = true,
		deduplicate = {
			enable = true,
			no_whitespace = true,
		},
		transitory_reg = {
			reg = "y",
			placeholder = "👩🏼",
		},
	},
	mappings = {
		karen = "y",
		unused = { "s", "S" },
	},
}

---@param user_config Config|table
---@return Config
function M.merge(user_config) return vim.tbl_deep_extend("keep", user_config, default_config) end

return M
