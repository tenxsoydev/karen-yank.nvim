--[[
Source: https://github.com/tenxsoydev/karen-yank.nvim
License: MIT
]]

local M = {}

---@param user_config? Config
function M.setup(user_config)
	require("karen-yank.config").merge(user_config)
	require("karen-yank.keymaps").set_maps()
	require("karen-yank.autocmds").set_aus()
end

return M
