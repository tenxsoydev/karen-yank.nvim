local M = {}

---@param user_config Config
function M.setup(user_config)
	user_config = user_config or {}
	local config = require("karen-yank.config").merge(user_config)
	require("karen-yank.keymaps").set_maps(config)

	if config.number_regs.enable and config.number_regs.deduplicate then
		vim.api.nvim_create_autocmd("TextYankPost", {
			callback = function() require("karen-yank.handlers").handle_duplicates(config.number_regs.transitory_reg) end,
		})
	end
end

return M
