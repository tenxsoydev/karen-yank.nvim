local M = {}

local transitory_reg = ""
local config = require("karen-yank.config").get()

---@param set_reg string|number
---@param get_reg string|number
function M.sync_regs(set_reg, get_reg) vim.fn.setreg(set_reg, vim.fn.getreg(get_reg)) end

local function handle_num_regs()
	-- do not touch number registers if a named register is targeted
	if vim.v.register:match("%w") or not config.number_regs.enable then return end

	-- store last register in case yanking a duplicate removes it
	if vim.fn.getreg(9) ~= transitory_reg then transitory_reg = vim.fn.getreg(9) end

	-- move entries in number registers up
	local x = 9
	while x > 0 do
		M.sync_regs(x, x - 1)
		x = x - 1
	end
end

function M.handle_duplicates()
	-- get current registers
	local regs = {}
	for i = 0, 9 do
		regs[#regs + 1] = vim.fn.getreg(i)
	end

	-- remove duplicates
	local seen = {}
	for i, reg in ipairs(regs) do
		if config.number_regs.deduplicate.ignore_whitespace then reg = reg:gsub("%s+", "") end
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
		vim.fn.setreg(9, transitory_reg)
	end
end

---@param key string
function M.handle_delete(key)
	-- do not use black_hole if a named register is targeted. E.g., '"add'
	if vim.v.register:match("%w") then return key end
	return '"_' .. key
end

---@param key string
function M.handle_cut(key)
	handle_num_regs()

	key = '"0' .. key

	if vim.api.nvim_get_mode()["mode"] == "n" then return key end
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)

	return key
end

---@param key string
function M.handle_yank(key)
	handle_num_regs()
	-- make capital Y behave
	if key == "Y" then key = "y$" end

	local mode = vim.api.nvim_get_mode()["mode"]
	if mode == "n" then return key end

	if config.on_yank.preserve_selection then
		key = key .. "gv"
		return key
	end

	if config.on_yank.preserve_cursor then
		if mode == "v" then key = key .. "gvv" end
		if mode == "V" then key = key .. "gvvv" end
	end

	return key
end

---@param key string
---@param black_hole boolean
function M.handle_paste(key, black_hole)
	if config.on_paste.preserve_selection then key = key .. "`[v`]" end

	if not black_hole then
		vim.defer_fn(function() M.sync_regs("+", "-") end, 10)
		vim.defer_fn(function() M.sync_regs('"', "-") end, 10)
		return key
	end

	-- keep previous registers contents when pasting in visual mode
	local affected_regs = { "*", "+", '"', "-" }
	local stored_regs = {}

	-- backup potentially affected regs
	for _, reg in ipairs(affected_regs) do
		stored_regs[reg] = vim.fn.getreg(reg)
	end

	vim.defer_fn(function()
		-- restore potentially affected regs
		for _, reg in ipairs(affected_regs) do
			vim.fn.setreg(reg, stored_regs[reg])
		end
	end, 10)

	return key
end

return M
