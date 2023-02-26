local M = {}

local handlers = require "karen-yank.handlers"

---@param num_reg_opts NumberRegOpts
function M.set_aus(num_reg_opts)
	if not num_reg_opts.enable then return end

	vim.api.nvim_create_autocmd("TextYankPost", {
		callback = function()
			-- use only relevant registers
			if not (vim.v.register:match "%d+" or vim.v.register == "+" or vim.v.register == '"') then return end

			-- check if clipboard and 0 register are in sync
			if vim.o.clipboard:match "unnamed" and vim.fn.getreg "+" ~= vim.fn.getreg "0" then
				handlers.sync_regs("+", "0")
				if vim.fn.getreg '"' ~= vim.fn.getreg "0" then handlers.sync_regs('"', "0") end
			end

			-- remove duplicate 0 and 1 in case of double `ydd` on the same line
			vim.defer_fn(function()
				if vim.fn.getreg "1" == vim.fn.getreg "0" then
					for x = 0, 8 do
						handlers.sync_regs(x, x + 1)
					end
				end
			end, 50)

			if not num_reg_opts.deduplicate.enable then return end
			handlers.handle_duplicates(num_reg_opts.deduplicate.ignore_whitespace)
		end,
	})
end

return M
