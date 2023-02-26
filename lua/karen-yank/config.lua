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
---@field deduplicate { enable: boolean, ignore_whitespace: boolean }

---@class MappingOpts
---@field karen string
---@field unused DeleteKey[]

---@alias DeleteKey "d"|"D"|"c"|"C"|"x"|"X"|"s"|"S"

---@type Config
local defaults = {
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
			ignore_whitespace = true,
		},
	},
	mappings = {
		karen = "y",
		unused = { "s", "S" },
	},
}

---@type Config
local used = defaults

---@param user_config? Config
function M.merge(user_config) used = vim.tbl_deep_extend("keep", user_config or {}, defaults) end

---@param kind? "defaults" @add to return default instead of currently used config
---@return Config
function M.get(kind)
	if kind == "defaults" then return defaults end
	return used
end

return M
