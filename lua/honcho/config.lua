---@class HonchoConfigColor
---@field fg string
---@field bg string
---@field neutral string

---@class HonchoConfigDefaults
---@field color HonchoConfigColor

---@class HonchoConfig
---@field defaults HonchoConfigDefaults

local M = {}

---@type HonchoConfig
local defaults = {
	defaults = {
		color = {
			-- user theme default fg
			fg = "#ffffff",
			-- user theme default bg
			-- pull the current colorscheme's Normal background as a hex string
			bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal" }).bg or 0x000000),
			-- user theme default neutral
			neutral = "#555555",
		},
	},
}

---@type HonchoConfig
M.options = vim.deepcopy(defaults)

function M.setup(opts)
	M.options = vim.tbl_deep_extend("force", M.options, opts or {})
end

return M
