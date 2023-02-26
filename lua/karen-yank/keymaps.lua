local M = {}

local config = require("karen-yank.config").get()
local handlers = require("karen-yank.handlers")
local map = vim.keymap.set
local keys = {
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
		p = "Paste After",
		P = "Paste Before",
	},
	yank = {
		y = "Yank Text",
		yy = "Yank Line",
		Y = "Yank Rest of Line",
	},
}

function M.set_maps()
	local disabled_keys = {}
	for _, key in ipairs(config.mappings.unused) do
		disabled_keys[key] = true
	end

	for key, desc in pairs(keys.delete) do
		if disabled_keys[key] then goto continue end

		if not config.on_delete.black_hole_default then
			map({ "n", "v" }, config.mappings.karen .. key, '"_' .. key, { desc = desc })
			goto continue
		end

		map({ "n", "v" }, key, function() return handlers.handle_delete(key) end, { expr = true, desc = desc })
		map(
			{ "n", "v" },
			config.mappings.karen .. key,
			function() return handlers.handle_cut(key) end,
			{ expr = true, desc = desc .. " Into Register" }
		)

		::continue::
	end

	for key, desc in pairs(keys.paste) do
		if not config.on_paste.black_hole_default then return end

		map(
			"v",
			key,
			function() return handlers.handle_paste(key, true) end,
			{ desc = desc .. " and Delete Selection", expr = true }
		)
		map(
			"v",
			config.mappings.karen .. key,
			function() return handlers.handle_paste(key, false) end,
			{ expr = true, desc = desc .. " and Yank Selection Into Register" }
		)
	end

	for key, desc in pairs(keys.yank) do
		map("", key, function() return handlers.handle_yank(key) end, { expr = true, desc = desc })
	end
end

return M
