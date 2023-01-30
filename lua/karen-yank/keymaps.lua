local M = {}

local handlers = require "karen-yank.handlers"
local map = vim.keymap.set
local reg_keys = {
	delete = {
		d = "Delete Text",
		D = "Delete Rest of Line",
		c = "Change Text",
		C = "Change Rest of Line",
		x = "Delete Next Character",
		X = "Delete Previous Character",
		s = "Substitute Text",
		S = "Substitute Rest of Line",
	},
	paste = {
		p = "Paste",
		P = "Paste",
	},
	yank = {
		y = "Yank Text",
		yy = "Yank Line",
		Y = "Yank Rest of Line",
	},
}

---@param keys string
local function feedkeys(keys) vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "v", false) end

---@param config Config
function M.set_maps(config)
	local unused_keys = {}
	for _, key in ipairs(config.mappings.unused) do
		unused_keys[key] = true
	end

	-- set keys for deletes / cuts
	for key, desc in pairs(reg_keys.delete) do
		if unused_keys[key] then goto continue end

		if not config.on_delete.black_hole_default then
			map({ "n", "v" }, config.mappings.karen .. key, '"_' .. key, { desc = desc })
			goto continue
		end

		map({ "n", "v" }, key, function() return handlers.handle_delete(key) end, { expr = true, desc = desc })
		map(
			{ "n", "v" },
			config.mappings.karen .. key,
			function() return handlers.handle_cut(key, config.number_regs) end,
			{ expr = true, desc = desc .. " Into Register" }
		)

		::continue::
	end

	-- set maps for pastes over selection
	for key, desc in pairs(reg_keys.paste) do
		if not config.on_paste.black_hole_default then return end

		map("v", key, function()
			local init_cursor_pos = vim.api.nvim_win_get_cursor(0)[2]
			if init_cursor_pos >= vim.fn.col "$" - 3 then return '"_dp' end
			feedkeys "o"
			vim.defer_fn(function()
				local new_cursor_pos = vim.api.nvim_win_get_cursor(0)[2]
				if init_cursor_pos < new_cursor_pos and new_cursor_pos >= vim.fn.col "$" - 3 then
					feedkeys '"_dp'
				else
					feedkeys '"_dP'
				end
			end, 1)
			return "<Ignore>"
		end, { desc = desc .. " and Delete Selection", expr = true })
		map(
			"v",
			config.mappings.karen .. key,
			function() return handlers.handle_paste("p", config.on_paste) end,
			{ expr = true, desc = desc .. " and Yank Selection Into Register" }
		)
	end

	-- set keys for yanks
	for key, desc in pairs(reg_keys.yank) do
		map(
			"",
			key,
			function() return handlers.handle_yank(key, config.on_yank, config.number_regs) end,
			{ expr = true, desc = desc }
		)
	end
end

return M
