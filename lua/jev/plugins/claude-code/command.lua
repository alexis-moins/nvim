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
		return string.format("In file @%s (lines %d-%d)", relative_path, selection.from, selection.to)
	else
		return string.format("In file @%s", relative_path)
	end
end

--- Build complete prompt by combining file context with user input
---@param user_prompt string The user's prompt text
---@param selection Selection|nil Visual selection range, or nil for no context
---@return string Complete prompt with optional context
function M.build_prompt(user_prompt, selection)
	-- Only include context if user made a visual selection
	if selection then
		local context = M.build_context(selection)

		if context then
			return string.format("%s\n\n%s", context, user_prompt)
		end
	end

	return user_prompt
end

return M
