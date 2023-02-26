local M = {}

local transitory_reg = ""
local config = require("karen-yank.config").get()

---@param set_reg string|number
---@param get_reg string|number
function M.sync_regs(set_reg, get_reg) vim.fn.setreg(set_reg, vim.fn.getreg(get_reg)) end

function M.handle_num_regs()
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

return M
