local M = {}

---@param num_reg_opts NumberRegOpts
function M.set_aus(num_reg_opts)
	local handlers = require "karen-yank.handlers"

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			if vim.fn.getreg(0) ~= vim.fn.getreg '"' then handlers.sync_regs(0, '"') end
			if not num_reg_opts.enable then return end
			if not num_reg_opts.deduplicate or not num_reg_opts.deduplicate.enable then return end
			handlers.handle_duplicates(num_reg_opts.transitory_reg, num_reg_opts.deduplicate.no_whitespace)
		end,
	})
end

return M
