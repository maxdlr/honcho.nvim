local config = require("honcho.config")

local M = {}

local DEFAULT_FG_COLOR = config.options.defaults.color.fg

-- Snacks pickers don't remap FloatBorder/FloatTitle to their own groups, so
-- overriding these directly changes the picker's border/title color.
local BORDER_HL_GROUPS = { "FloatBorder", "FloatTitle" }

local color_hl_cache = {}

--- Gets (or lazily creates) a highlight group named `prefix<HEX>` that sets `hl_field` to `hex`.
--- @param prefix string Highlight group name prefix, e.g. "CommandPickerColor"
--- @param hex string Hex color, e.g. "#FF8800"
--- @param hl_field? string Highlight field to set, "fg" (default) or "bg"
--- @return string Highlight group name
local function get_color_hl(prefix, hex, hl_field)
	hl_field = hl_field or "fg"
	local cache_key = prefix .. ":" .. hex .. ":" .. hl_field
	local cached = color_hl_cache[cache_key]
	if cached then
		return cached
	end

	local hl_name = prefix .. hex:gsub("^#", "")
	vim.api.nvim_set_hl(0, hl_name, { [hl_field] = hex })
	color_hl_cache[cache_key] = hl_name
	return hl_name
end

---@class HonchoCommandDefinition
---@field label string Command label to display in the picker.
---@field action string|function|false Command action to execute when selected.
---@field color? string Hex color (e.g. "#FF8800") for the label text. Defaults to white.
---@field description? string Optional description shown alongside the label in the picker.
---@field icon? string Optional icon shown alongside the label in the picker.

--- Creates a Snacks picker dropdown from a list of commands.
--- @param title string Picker prompt title
--- @param commands HonchoCommandDefinition[] List of {label, action, color} pairs.
--- @param opts? {border_color?: string, width?: number} border_color: optional hex color (e.g. "#7aa2f7") for the
function M.picker(title, commands, opts)
	opts = opts or {}
	return function()
		local restore_border_hl
		if opts.border_color then
			local previous = {}
			for _, group in ipairs(BORDER_HL_GROUPS) do
				previous[group] = vim.api.nvim_get_hl(0, { name = group, link = false })
				vim.api.nvim_set_hl(0, group, { fg = opts.border_color })
			end
			restore_border_hl = function()
				for group, hl in pairs(previous) do
					vim.api.nvim_set_hl(0, group, hl)
				end
			end
		end

		local max_label_len = 0
		for _, cmd in ipairs(commands) do
			max_label_len = math.max(max_label_len, vim.fn.strdisplaywidth(cmd.label))
		end
		local width = opts.width or (max_label_len + 8)
		local height = #commands + 4

		local items = {}
		for i, cmd in ipairs(commands) do
			local is_separator = cmd.action == false
			items[#items + 1] = {
				idx = i,
				score = i,
				text = is_separator and "" or cmd.label,
				cmd = cmd,
				is_separator = is_separator,
			}
		end

		local picker

		-- Separator rows must never be landed on when navigating.
		local function skip_separators(move)
			return function(current_picker)
				move(current_picker)
				local guard = 0
				local item = current_picker:current()
				while item and item.is_separator and guard < #commands do
					move(current_picker)
					item = current_picker:current()
					guard = guard + 1
				end
			end
		end

		local move_next = skip_separators(function(p)
			p.list:move(1)
		end)
		local move_prev = skip_separators(function(p)
			p.list:move(-1)
		end)

		picker = Snacks.picker({
			title = title,
			items = items,
			layout = {
				preset = "select",
				layout = {
					width = width,
					min_width = width,
					height = height,
					min_height = height,
				},
			},
			format = function(item)
				local cmd = item.cmd
				local hl_group = get_color_hl(
					"CommandPickerColor",
					cmd.color or (item.is_separator and config.options.defaults.color.neutral or DEFAULT_FG_COLOR)
				)

				local row = {}
				if cmd.icon then
					table.insert(row, { cmd.icon .. " ", hl_group })
				end
				table.insert(row, { cmd.label, hl_group })
				if cmd.description then
					table.insert(row, { "  " .. cmd.description, "Comment" })
				end
				return row
			end,
			actions = {
				move_next = function(p)
					move_next(p)
				end,
				move_prev = function(p)
					move_prev(p)
				end,
			},
			win = {
				list = {
					wo = {
						linenumber = false,
					},
				},
				input = {
					keys = {
						["<Down>"] = { "move_next", mode = { "i", "n" } },
						["<C-n>"] = { "move_next", mode = { "i", "n" } },
						["<Up>"] = { "move_prev", mode = { "i", "n" } },
						["<C-p>"] = { "move_prev", mode = { "i", "n" } },
					},
				},
			},
			confirm = function(p, item)
				if item.is_separator then
					return
				end

				p:close()

				local action = item.cmd.action
				if type(action) == "function" then
					action()
				else
					vim.cmd(action)
				end
			end,
			on_close = restore_border_hl,
		})
	end
end

return M
