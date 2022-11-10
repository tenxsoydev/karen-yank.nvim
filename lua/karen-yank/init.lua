local M = {}

---@param user_config? Config
function M.setup(user_config)
	local config = require("karen-yank.config").merge(user_config or {})
	require("karen-yank.keymaps").set_maps(config)
end

return M
