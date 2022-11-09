local M = {}

---@class Config
---@field number_regs NumberRegOpts
---@field on_yank YankOpts
---@field on_paste PasteOpts
---@field mappings MappingOpts

---@class YankOpts
---@field black_hole_default boolean
---@field preserve_cursor boolean
---@field preserve_selection boolean

---@class PasteOpts
---@field black_hole_default boolean
---@field preserve_selection boolean

---@class NumberRegOpts
---@field enable boolean
---@field deduplicate boolean
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
	on_yank = {
		black_hole_default = true,
		preserve_cursor = true,
		preserve_selection = false,
	},
	on_paste = {
		black_hole_default = true,
		preserve_selection = false,
	},
	number_regs = {
		enable = true,
		deduplicate = true,
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

---@param user_config Config
---@return Config
function M.merge(user_config) return vim.tbl_deep_extend("keep", user_config, default_config) end

return M
