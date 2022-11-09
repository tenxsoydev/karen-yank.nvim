local M = {}

local function handle_duplicates()
	local current_yank = vim.fn.getreg(0)
	for i = 1, 9 do
		local reg = vim.fn.getreg(i)
		if reg == current_yank then
			vim.fn.setreg(i, "")
			for x = i, 8 do
				vim.cmd(string.format("let @%s=@%s", x, x + 1))
			end
		end
	end
end

---@param num_reg_opts NumberRegOpts
local function handle_num_regs(num_reg_opts)
	if vim.api.nvim_command_output("ec v:register"):match "%w" or not num_reg_opts.enable then return end

	local x = 9
	while x > 0 do
		vim.cmd(string.format("let @%s=@%s", x, x - 1))
		x = x - 1
	end

	if num_reg_opts.deduplicate then vim.loop.new_timer():start(50, 0, vim.schedule_wrap(handle_duplicates)) end
end

---@param yank_opts YankOpts
function M.handle_yank(key_lhs, yank_opts)
	local key_rhs = key_lhs

	handle_num_regs(yank_opts.number_regs)

	local mode = vim.api.nvim_get_mode()["mode"]
	if mode == "n" then return key_rhs end

	if yank_opts.preserve_seleciton then
		key_rhs = key_rhs .. "gv"
		return key_rhs
	end

	if yank_opts.preserve_cursor then
		if mode == "v" then key_rhs = key_rhs .. "gvv" end
		if mode == "V" then key_rhs = key_rhs .. "gvvv" end
	end

	return key_rhs
end

---@param paste_opts PasteOpts
---@param num_reg_opts NumberRegOpts
function M.handle_paste(key_lhs, paste_opts, num_reg_opts)
	local key_rhs = key_lhs

	if not paste_opts.black_hole_default then handle_num_regs(num_reg_opts) end
	if num_reg_opts.enable then key_rhs = '"0ygv' .. key_rhs end
	if paste_opts.preserve_selection then key_rhs = key_rhs .. "`[v`]" end

	return key_rhs
end

return M
