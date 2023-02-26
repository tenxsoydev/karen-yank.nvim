--[[
Source: https://github.com/tenxsoydev/karen-yank.nvim
License: MIT
]]

local M = {}

---@param user_config? Config
function M.setup(user_config)
	require("karen-yank.config").apply(user_config)
	require("karen-yank.keymaps").set()
	require("karen-yank.autocmds").set()
end

return M
