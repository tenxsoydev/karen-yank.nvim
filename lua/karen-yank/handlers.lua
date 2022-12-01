local M = {}

---@param set_reg string|number
---@param get_reg string|number
function M.sync_regs(set_reg, get_reg) vim.fn.setreg(set_reg, vim.fn.getreg(get_reg)) end

---@param fn fun()
function M.lazy(fn) vim.defer_fn(vim.schedule_wrap(fn), 10) end

---@param num_reg_opts NumberRegOpts
local function handle_num_regs(num_reg_opts)
	-- do not not touch number register if a named register is targeted
	if vim.api.nvim_command_output("ec v:register"):match "%w" or not num_reg_opts.enable then return end

	-- store last register in case yanking a duplicate removes it
	if vim.fn.getreg(9) ~= vim.fn.getreg(num_reg_opts.transitory_reg.reg) then
		M.sync_regs(num_reg_opts.transitory_reg.reg, 9)
	end

	-- move entries in number registers up
	local x = 9
	while x > 0 do
		M.sync_regs(x, x - 1)
		x = x - 1
	end
end

---@param transitory_reg TransitoryRegOpts
---@param ignore_whitespace boolean
function M.handle_duplicates(transitory_reg, ignore_whitespace)
	-- get current registers
	local regs = {}
	for i = 0, 9 do
		regs[#regs + 1] = vim.fn.getreg(i)
	end

	-- remove duplicates
	local seen = {}
	for i, reg in ipairs(regs) do
		if ignore_whitespace then reg = reg:gsub("%s+", "") end
		if seen[reg] then
			table.remove(regs, i)
		else
			seen[reg] = true
		end
	end

	-- set uniquified registers
	for i, reg in ipairs(regs) do
		vim.fn.setreg(i - 1, reg)
	end

	-- restore last register if neccessary
	if vim.fn.getreg(8) ~= "" and (vim.fn.getreg(9) == "" or vim.fn.getreg(9) == vim.fn.getreg(8)) then
		M.sync_regs(9, transitory_reg.reg)
	end
end

---@param key string
function M.handle_delete(key)
	-- do not use black_hole if a named register is targeted. E.g., '"add'
	if vim.v.register:match "%w" then return key end
	return '"_' .. key
end

---@param key string
---@param num_reg_opts NumberRegOpts
function M.handle_cut(key, num_reg_opts)
	handle_num_regs(num_reg_opts)
	return '"0' .. key
end

---@param key string
---@param yank_opts YankOpts
---@param num_reg_opts NumberRegOpts
function M.handle_yank(key, yank_opts, num_reg_opts)
	handle_num_regs(num_reg_opts)
	-- make capital Y behave
	if key == "Y" then key = "y$" end

	local mode = vim.api.nvim_get_mode()["mode"]
	if mode == "n" then return key end

	if yank_opts.preserve_selection then
		key = key .. "gv"
		return key
	end

	if yank_opts.preserve_cursor then
		if mode == "v" then key = key .. "gvv" end
		if mode == "V" then key = key .. "gvvv" end
	end

	return key
end

---@param key string
---@param paste_opts PasteOpts
function M.handle_paste(key, paste_opts)
	-- yank selection to the transitory register to restore it to the system clipbaord after pasting
	key = '"yygv' .. key

	if paste_opts.preserve_selection then key = key .. "`[v`]" end

	-- set system clipboard to previous selection
	M.lazy(function() M.sync_regs("+", "y") end)
	return key
end

return M
