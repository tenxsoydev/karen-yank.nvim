local M = {}

---@param number_reg_opts NumberRegOpts
function M.set_aus(number_reg_opts)
	if vim.o.clipboard ~= "unnamedplus" then
		vim.api.nvim_create_autocmd("TextYankPost", {
			callback = function()
				if number_reg_opts.deduplicate then
					require("karen-yank.handlers").handle_duplicates(number_reg_opts.transitory_reg)
				end
			end,
		})

		return
	end

	if number_reg_opts.enable then
		vim.api.nvim_create_autocmd("TextYankPost", {
			pattern = { "*", "+" },
			callback = function()
				vim.fn.setreg(0, vim.fn.getreg "+")

				if number_reg_opts.deduplicate then
					require("karen-yank.handlers").handle_duplicates(number_reg_opts.transitory_reg)
				end
			end,
		})
	end
end

return M
