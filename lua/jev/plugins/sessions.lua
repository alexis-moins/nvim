local add = MiniDeps.add

--
-- mini.sessions
--
add("nvim-mini/mini.sessions")
require("mini.sessions").setup({
	autowrite = false,
	verbose = { read = true },
})

--- Wrapper around mini.sessions functions. Returns a function that
--- behaves differently based on the given scope.
---
---@param scope "local"|"write"|"read"|"delete"
---@return function
local function session(scope)
	return function()
		if scope == "local" then
            local session_name = MiniSessions.config.file
			MiniSessions.write(session_name)
		else
			MiniSessions.select(scope)
		end
	end
end

--
-- Mappings
--
keys.map("n", "<Leader>sl", session("local"), "Save/create a local session")
keys.map("n", "<Leader>sr", session("read"), "Load a session")
keys.map("n", "<Leader>ss", session("write"), "Save an existing session")

keys.map("n", "<Leader>sn", function()
	local session_name = vim.fn.input("Session name: ")
	MiniSessions.write(session_name)
end, "Create a new session")
