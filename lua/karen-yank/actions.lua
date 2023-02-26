local M = {}

---@alias DeleteKey "d"|"D"|"c"|"C"|"x"|"X"|"s"|"S"

local handlers = require("karen-yank.handlers")

---@param key DeleteKey @vim key parent
function M.delete(key)
	-- do not use black_hole if a named register is targeted. E.g., '"add'
	if vim.v.register:match("%w") then return key end
	return '"_' .. key
end

---@param key DeleteKey @vim key parent
function M.cut(key)
	handlers.handle_num_regs()

	key = '"0' .. key

	if vim.api.nvim_get_mode()["mode"] == "n" then return key end
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<ESC>", true, false, true), "n", false)

	return key
end

---@param kind "motion"|"line"|"trail"
---@param opts? { preserve_cursor: boolean, preserve_selection: boolean }
function M.yank(kind, opts)
	opts = opts or { preserve_cursor = true, preserve_selection = false }

	local key = "y"
	if kind == "line" then key = "yy" end
	if kind == "trail" then key = "y$" end

	handlers.handle_num_regs()

	local mode = vim.api.nvim_get_mode()["mode"]
	if mode == "n" then return key end

	if opts.preserve_selection then
		key = key .. "gv"
		return key
	end

	if opts.preserve_cursor then
		if mode == "v" then key = key .. "gvv" end
		if mode == "V" then key = key .. "gvvv" end
	end

	return key
end

---@param direction "before"|"after"
---@param opts? { black_hole: boolean, preserve_selection: boolean }
function M.paste(direction, opts)
	opts = opts or { black_hole = true, preserve_selection = false }

	local key = "p"
	if direction == "after" then key = "P" end

	if opts.preserve_selection then key = key .. "`[v`]" end

	if not opts.black_hole then
		vim.defer_fn(function() handlers.sync_regs("+", "-") end, 10)
		vim.defer_fn(function() handlers.sync_regs('"', "-") end, 10)
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
