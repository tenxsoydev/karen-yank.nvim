local M = {}

---@param num_reg_opts NumberRegOpts
function M.set_aus(num_reg_opts)
	local handlers = require "karen-yank.handlers"

	if vim.o.clipboard ~= "unnamedplus" then
		vim.api.nvim_create_autocmd("TextYankPost", {
			callback = function()
				if num_reg_opts.deduplicate then handlers.handle_duplicates(num_reg_opts.transitory_reg) end
			end,
		})

		return
	end

	if not num_reg_opts.enable then return end

	vim.api.nvim_create_autocmd("TextYankPost", {
		pattern = { "*", "+" },
		callback = function()
			handlers.sync_regs(0, "+")
			if num_reg_opts.deduplicate then handlers.handle_duplicates(num_reg_opts.transitory_reg) end
		end,
	})
end

return M
