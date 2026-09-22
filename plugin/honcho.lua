if vim.g.loaded_honcho then
	return
end
vim.g.loaded_honcho = true

local notify = require("honcho.notify").notify

local has_telescope = pcall(require, "telescope")
if not has_telescope then
	notify(
		"Config Error",
		"[Honcho] Telescope is required for Honcho to work. Please install telescope.nvim.",
		vim.log.levels.ERROR
	)
	return
end

return require("honcho")
