local M = {}

local handlers = require "karen-yank.handlers"

---@param num_reg_opts NumberRegOpts
function M.set_aus(num_reg_opts)
	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			-- for now, keep deprecated 'num_reg_opts.deduplicate' setting, which was a simple bool before
			if
				not num_reg_opts.deduplicate
				or not num_reg_opts.deduplicate.enable
				or not (vim.v.register:match "%d+" or vim.v.register == "+" or vim.v.register == '"')
			then
				return
			end

			if vim.o.clipboard ~= "" and vim.fn.getreg "+" ~= vim.fn.getreg "0" then handlers.sync_regs("+", "0") end

			if vim.fn.getreg "1" == vim.fn.getreg "0" then
				for x = 0, 8 do
					handlers.sync_regs(x, x + 1)
				end
			end

			handlers.handle_duplicates(num_reg_opts.transitory_reg, num_reg_opts.deduplicate.ignore_whitespace)
			vim.fn.setreg(num_reg_opts.transitory_reg.reg, num_reg_opts.transitory_reg.placeholder)
		end,
	})
end

return M
