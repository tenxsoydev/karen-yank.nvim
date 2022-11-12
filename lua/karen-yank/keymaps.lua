local M = {}

local handlers = require "karen-yank.handlers"
local map = vim.keymap.set
local reg_keys = {
	delete = { "d", "D", "c", "C", "x", "X", "s", "S" },
	paste = { "p", "P" },
	yank = { "y", "Y", "yy" },
}

---@param config Config
function M.set_maps(config)
	-- set keys for deletes / cuts
	local unused_keys = {}
	for _, key in ipairs(config.mappings.unused) do
		unused_keys[key] = true
	end

	for _, key in pairs(reg_keys.delete) do
		if unused_keys[key] then
			goto continue
		end

		if not config.on_delete.black_hole_default then
			map({ "n", "v" }, config.mappings.karen .. key, '"_' .. key)
			goto continue
		end

		map({ "n", "v" }, key, function() return handlers.handle_delete(key) end, { expr = true })
		map(
			{ "n", "v" },
			config.mappings.karen .. key,
			function() return handlers.handle_cut(key, config.number_regs) end,
			{ expr = true }
		)

		::continue::
	end

	-- set maps for pastes over selection
	for _, key in pairs(reg_keys.paste) do
		if config.on_paste.black_hole_default then map("v", config.mappings.karen .. key, key) end

		map(
			"v",
			key,
			function() return handlers.handle_paste(key, config.on_paste, config.number_regs) end,
			{ expr = true }
		)
	end

	-- set keys for yanks
	for _, key in pairs(reg_keys.yank) do
		map(
			"",
			key,
			function() return handlers.handle_yank(key, config.on_yank, config.number_regs) end,
			{ expr = true }
		)
	end
end

return M
