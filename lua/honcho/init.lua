local config = require("honcho.config")
local command_picker = require("honcho.command_picker")

local M = {}

M.honcho_picker = command_picker.picker
M.honcho_separator = command_picker.separator

---@param opts HonchoConfig?
function M.setup(opts)
	config.setup(opts)
end

return M
