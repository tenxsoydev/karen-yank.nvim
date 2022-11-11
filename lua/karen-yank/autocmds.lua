local M = {}

---@param num_reg_opts NumberRegOpts
function M.set_aus(num_reg_opts)
	if vim.o.clipboard ~= "unnamedplus" then
		vim.api.nvim_create_autocmd("TextYankPost", {
			callback = function()
				if num_reg_opts.deduplicate then
					require("karen-yank.handlers").handle_duplicates(num_reg_opts.transitory_reg)
				end
			end,
		})

		return
	end

	if num_reg_opts.enable then
		vim.api.nvim_create_autocmd("TextYankPost", {
			pattern = { "*", "+" },
			callback = function()
				require("karen-yank.handlers").sync_regs(0, "+")
				if num_reg_opts.deduplicate then
					require("karen-yank.handlers").handle_duplicates(num_reg_opts.transitory_reg)
				end
			end,
		})
	end
end

return M
