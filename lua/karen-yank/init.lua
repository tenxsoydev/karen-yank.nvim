--[[
Source: https://github.com/tenxsoydev/karen-yank.nvim
License: GNU GPLv3
]]

local M = {}

---@param user_config? Config
function M.setup(user_config)
	local config = require("karen-yank.config").merge(user_config or {})
	require("karen-yank.keymaps").set_maps(config)
	require("karen-yank.autocmds").set_aus(config.number_regs)
end

return M
