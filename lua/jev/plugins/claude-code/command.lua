local M = {}

---@class Selection
---@field from number Starting line number
---@field to number Ending line number

--- Build file context string with path and optional line range information
---@param selection Selection|nil Table with 'from' and 'to' keys for line range, or nil for entire file
---@return string|nil Context string or nil if no file is loaded
function M.build_context(selection)
	local file_path = vim.fn.expand("%:p")

	-- Return nil if no file is loaded (empty path or unnamed buffer)
	if file_path == "" or vim.fn.expand("%") == "" then
		return nil
	end

	local relative_path = vim.fn.fnamemodify(file_path, ":.")

	if selection and selection.from and selection.to then
		return string.format("@%s (%d-%d)", relative_path, selection.from, selection.to)
	else
		return string.format("@%s", relative_path)
	end
end

--- Build complete prompt by combining file context with user input
---@param user_prompt string The user's prompt text
---@param selection Selection|boolean|nil Visual selection range, true to include full file context, false/nil for no context
---@return string Complete prompt with optional context
function M.build_prompt(user_prompt, selection)
	-- Don't include context if selection is false or nil
	if selection == false or selection == nil then
		return user_prompt
	end

	-- If selection is true, include full file context
	-- If selection is a table, include context with line range
	local context = M.build_context(type(selection) == "table" and selection or nil)

	if context then
		return string.format("%s\n\n%s", context, user_prompt)
	end

	return user_prompt
end

return M
