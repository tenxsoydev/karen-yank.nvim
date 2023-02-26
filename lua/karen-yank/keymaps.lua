local M = {}

local config = require("karen-yank.config").get()
local actions = require("karen-yank.actions")
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

function M.set()
	if type(config.mappings.disable) == "boolean" and config.mappings.disable then return end

	local disabled_keys = {}
	---@diagnostic disable-next-line: param-type-mismatch
	for _, key in ipairs(config.mappings.disable) do
		disabled_keys[key] = true
	end

	for key, desc in pairs(keys.delete) do
		if disabled_keys[key] then goto continue end

		if config.mappings.invert then
			map({ "n", "v" }, config.mappings.karen .. key, actions.delete(key), { desc = desc })
			goto continue
		end

		map({ "n", "v" }, key, function() return actions.delete(key) end, { expr = true, desc = desc })
		map(
			{ "n", "v" },
			config.mappings.karen .. key,
			function() return actions.cut(key) end,
			{ expr = true, desc = desc .. " Into Register" }
		)

		::continue::
	end

	for key, desc in pairs(keys.paste) do
		if disabled_keys[key] then goto continue end

		---@type "before"|"after"
		local direction = "after"
		if key == "P" then direction = "before" end

		map(
			"v",
			key,
			function() return actions.paste(direction, { black_hole = true }) end,
			{ desc = desc .. " and Delete Selection", expr = true }
		)
		map(
			"v",
			config.mappings.karen .. key,
			function() return actions.paste(direction, { black_hole = false }) end,
			{ expr = true, desc = desc .. " and Yank Selection Into Register" }
		)

		::continue::
	end

	for key, desc in pairs(keys.yank) do
		if disabled_keys[key] then goto continue end

		---@type "motion"|"line"|"trail"
		local kind = "motion"
		if key == "yy" then
			kind = "line"
		elseif key == "Y" then
			kind = "trail"
		end

		map("", key, function() return actions.yank(kind) end, { expr = true, desc = desc })

		::continue::
	end
end

return M
