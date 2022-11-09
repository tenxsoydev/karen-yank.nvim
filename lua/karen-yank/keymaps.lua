local M = {}

local handlers = require "karen-yank.handlers"
local map = vim.keymap.set
local reg_keys = {
	deleting = {
		d = "Delete Text",
		D = "Delete Rest of Line",
		c = "Change Text",
		C = "Change Rest of Line",
		x = "Delete Next Character",
		X = "Delete Previous Character",
		s = "Substitute Text",
		S = "Substitute Rest of Line",
	},
	pasting = {
		p = "Paste After Cursor",
		P = "Paste Before Cursor",
	},
	yanking = {
		y = "Yank Motion",
		yy = "Yank Rest of Line",
		Y = "Yank Line",
	},
}

---@param config Config
function M.set_maps(config)
	local unused_keys = {}
	for _, key in ipairs(config.mappings.unused) do
		unused_keys[key] = true
	end

	for key, desc in pairs(reg_keys.deleting) do
		if unused_keys[key] then
			goto continue
		end

		if not config.on_yank.black_hole_default then
			map({ "n", "v" }, config.mappings.karen .. key, '"_' .. key, { desc = desc })
			goto continue
		end

		map({ "n", "v" }, key, function() return handlers.handle_delete(key) end, { expr = true, desc = desc })
		map({ "n", "v" }, config.mappings.karen .. key, key, { desc = "Yank and " .. desc })

		::continue::
	end

	for key, desc in pairs(reg_keys.pasting) do
		if config.on_paste.black_hole_default then
			desc = desc .. " and Yank Selection Into Register"
			map(
				"v",
				config.mappings.karen .. key,
				function() return handlers.handle_paste(key, config.on_paste, config.number_regs) end,
				{ expr = true, desc = desc }
			)
		end

		map(
			"v",
			key,
			function() return handlers.handle_paste(key, config.on_paste, config.number_regs) end,
			{ expr = true, desc = desc }
		)
	end

	for key, desc in pairs(reg_keys.yanking) do
		if key == "Y" then key = "y$" end
		map(
			"",
			key,
			function() return handlers.handle_yank(key, config.on_yank, config.number_regs) end,
			{ expr = true, desc = desc }
		)
	end
end

return M
