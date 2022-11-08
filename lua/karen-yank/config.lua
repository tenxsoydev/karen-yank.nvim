local M = {}

---@class Config
---@field on_yank YankOpts
---@field on_paste PasteOpts
---@field mappings MappingOpts

---@class YankOpts
---@field number_regs NumberRegOpts
---@field black_hole_default boolean
---@field preserve_cursor boolean
---@field preserve_seleciton boolean

---@class NumberRegOpts
---@field enable boolean
---@field deduplicate boolean

---@class PasteOpts
---@field black_hole_default boolean
---@field preserve_seleciton boolean

---@class MappingOpts
---@field karen string
---@field unused DeleteKey[]

---@alias DeleteKey "d"|"D"|"c"|"C"|"x"|"X"|"s"|"S"

---@type Config
local default_config = {
	on_yank = {
		number_regs = {
			enable = true,
			deduplicate = true,
		},
		black_hole_default = true,
		preserve_cursor = true,
		preserve_seleciton = false,
	},
	on_paste = {
		black_hole_default = true,
		preserve_seleciton = false,
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
