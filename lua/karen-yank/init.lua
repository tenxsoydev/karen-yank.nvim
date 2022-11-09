local M = {}

---@param user_config Config
function M.setup(user_config)
	user_config = user_config or {}
	local config = require("karen-yank.config").merge(user_config)
	require("karen-yank.keymaps").set_maps(config)
end

return M
