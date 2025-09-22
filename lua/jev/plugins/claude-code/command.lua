-- command.lua - command handling and prompt building

local M = {}

-- Build file context string with path and optional line range information
function M.build_context(opts)
	local file_path = vim.fn.expand("%:p")
	local relative_path = vim.fn.fnamemodify(file_path, ":.")

	if opts.range > 0 then
		return string.format("File @%s (lines %d-%d)", relative_path, opts.line1, opts.line2)
	else
		return string.format("File @%s", relative_path)
	end
end

-- Build complete prompt by combining file context with user input
function M.build_prompt(opts)
	if opts.args == "" then
		return nil
	end

	local context = M.build_context(opts)
	return string.format("%s\n\n%s", context, opts.args)
end

return M