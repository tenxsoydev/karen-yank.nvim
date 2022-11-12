local M = {}

local handlers = require "karen-yank.handlers"

---@param num_reg_opts NumberRegOpts
function M.set_aus(num_reg_opts)
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			if
				not num_reg_opts.deduplicate
				or not num_reg_opts.deduplicate.enable
				or not (vim.v.register:match "%d+" or vim.v.register == "+" or vim.v.register == '"')
			then
				return
			end
			handlers.handle_duplicates(num_reg_opts.transitory_reg, num_reg_opts.deduplicate.no_whitespace)

			if vim.o.clipboard == "" then return end
			if vim.fn.getreg "+" ~= vim.fn.getreg "0" then handlers.sync_regs("+", "0") end
		end,
	})
end

return M
