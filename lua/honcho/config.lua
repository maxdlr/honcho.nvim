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
			-- get user current background color from vim.api.nvim_get_hl_by_name
			bg = string.format("#%06x", vim.api.nvim_get_hl(0, { name = "Normal", rgb = true })),
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
