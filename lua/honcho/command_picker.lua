local config = require("honcho.config")

local M = {}

local DEFAULT_FG_COLOR = config.options.defaults.color.fg
local DEFAULT_BG_COLOR = config.options.defaults.color.bg

local BORDER_HL_GROUPS =
	{ "TelescopePromptBorder", "TelescopeResultsBorder", "TelescopePreviewBorder", "TelescopePromptTitle" }

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local themes = require("telescope.themes")
local telescope_config = require("telescope.config")

--- Sentinel action value marking a command entry as a non-selectable separator.
--- Use it as the `action` field, e.g. `{ '───────────', Command_picker_separator }`.
M.separator = false

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

--- Creates a Telescope dropdown picker from a list of commands.
--- @param title string Picker prompt title
--- @param commands HonchoCommandDefinition[] List of {label, action, color} pairs.
--- @param opts? {border_color?: string} border_color: optional hex color (e.g. "#7aa2f7") for the
function M.picker(title, commands, opts)
	opts = opts or {}
	return function()
		local restore_border_hl
		if opts.border_color then
			-- Save current border highlight definitions, override them for this picker,
			-- and queue a restore for when the picker closes.
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

		pickers
			.new(
				themes.get_dropdown({
					winblend = 5,
					layout_config = {
						prompt_position = "top",
						width = function(_, max_columns, _)
							return math.max(40, math.floor(max_columns * 0.13))
						end,
						height = #commands + 4,
					},
				}),
				{
					prompt_title = title,

					finder = finders.new_table({
						results = commands,
						entry_maker = function(e)
							local is_separator = e.action == M.separator

							local hl_group = get_color_hl(
								"CommandPickerColor",
								e.color or (is_separator and config.options.defaults.color.neutral or DEFAULT_FG_COLOR)
							)

							return {
								value = e,
								ordinal = is_separator and "" or e.label,
								display = function(entry)
									return entry.value.label, { { { 0, #entry.value.label }, hl_group } }
								end,
							}
						end,
					}),

					sorter = telescope_config.values.generic_sorter({}),

					attach_mappings = function(bufnr, map)
						if restore_border_hl then
							vim.api.nvim_create_autocmd("BufWinLeave", {
								buffer = bufnr,
								once = true,
								callback = restore_border_hl,
							})
						end

						-- Skip over separator rows when moving the selection, so they can
						-- never be landed on (and therefore never look "selectable").
						local function skip_separators(move)
							return function()
								move(bufnr)
								local guard = 0
								while
									action_state.get_selected_entry().value.action == M.separator
									and guard < #commands
								do
									move(bufnr)
									guard = guard + 1
								end
							end
						end

						local move_next = skip_separators(actions.move_selection_next)
						local move_prev = skip_separators(actions.move_selection_previous)
						map({ "i", "n" }, "<Down>", move_next)
						map({ "i", "n" }, "<C-n>", move_next)
						map({ "i", "n" }, "<Up>", move_prev)
						map({ "i", "n" }, "<C-p>", move_prev)

						actions.select_default:replace(function()
							local action = action_state.get_selected_entry().value.action

							if action == M.separator then
								return
							end

							actions.close(bufnr)

							if type(action) == "function" then
								action()
							else
								vim.cmd(action)
							end
						end)
						return true
					end,
				}
			)
			:find()
	end
end

return M
