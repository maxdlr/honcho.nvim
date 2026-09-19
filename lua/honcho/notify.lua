local M = {}

---Sends a toast notification with a title reflecting the error/message category
---(e.g. "Honcho · Config Error") and the actual detail as the notification body.
---@param category string Short category shown in the title, e.g. "Config Error"
---@param message string
---@param level integer vim.log.levels.*
function M.notify(category, message, level)
	vim.notify(message, level, { title = "Honcho · " .. category })
end

return M
