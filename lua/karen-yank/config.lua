local M = {}

---@class Config
---@field number_regs NumberRegOpts
---@field mappings MappingOpts

---@class NumberRegOpts
---@field enable boolean
---@field deduplicate { enable: boolean, ignore_whitespace: boolean }

---@class MappingOpts
---@field karen string
---@field invert boolean
---@field disable Key[]|true

---@alias Key "s"|"S"|"d"|"D"|"c"|"C"|"x"|"X"|"p"|"P"|"y"|"Y"

---@type Config
local defaults = {
	number_regs = {
		enable = true,
		deduplicate = {
			enable = true,
			ignore_whitespace = true,
		},
	},
	mappings = {
		karen = "y",
		invert = false,
		disable = { "s", "S" },
	},
}

---@type Config
local used = defaults

---@param user_config? Config
function M.apply(user_config) used = vim.tbl_deep_extend("keep", user_config or {}, defaults) end

---@param kind? "defaults" @add to return default instead of currently used config
---@return Config
function M.get(kind)
	if kind == "defaults" then return defaults end
	return used
end

return M
