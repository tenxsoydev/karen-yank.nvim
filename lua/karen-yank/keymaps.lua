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

---@param config Config
function M.set_maps(config)
	local unused_keys = {}
	for _, key in ipairs(config.mappings.unused) do
		unused_keys[key] = true
	end

	-- set keys for deletes / cuts
	for key, desc in pairs(reg_keys.delete) do
		if unused_keys[key] then
			goto continue
		end

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
		if config.on_paste.black_hole_default then
			map("v", key, '"_dP', { desc = desc .. " and Delete Selection" })
			map(
				"v",
				config.mappings.karen .. key,
				function() return handlers.handle_paste("p", config.on_paste) end,
				{ expr = true, desc = desc .. " and Yank Selection Into Register" }
			)
		else
			map(
				"v",
				key,
				function() return handlers.handle_paste(key, config.on_paste) end,
				{ expr = true, desc = desc .. " and Delete Selection" }
			)
		end
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
