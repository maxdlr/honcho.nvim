if vim.g.loaded_honcho then
	return
end
vim.g.loaded_honcho = true

local notify = require("honcho.notify").notify

local has_snacks = pcall(require, "snacks")
if not has_snacks then
	notify(
		"Config Error",
		"[Honcho] snacks.nvim is required for Honcho to work. Please install folke/snacks.nvim.",
		vim.log.levels.ERROR
	)
	return
end

return require("honcho")
