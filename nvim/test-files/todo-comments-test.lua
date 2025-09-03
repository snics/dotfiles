-- =============================================================================
-- Todo-Comments Test File für Neovim
-- Teste hier alle Todo-Comments Features nach der Telescope → Snacks Migration
-- =============================================================================

-- TODO: Dies ist ein normaler TODO-Kommentar
-- Der sollte von todo-comments erkannt werden

-- FIXME: Dies ist ein kritischer Bug der behoben werden muss
-- Diese Art von Kommentar sollte höhere Priorität haben

-- HACK: Dies ist ein temporärer Workaround
-- Sollte später durch eine bessere Lösung ersetzt werden

-- NOTE: Dies ist eine wichtige Anmerkung
-- Nützlich für Dokumentation und Hinweise

-- PERF: Performance-Optimierung erforderlich
-- Diese Funktion ist zu langsam und sollte optimiert werden

-- WARNING: Vorsicht bei dieser Funktion
-- Sie kann unerwartete Nebenwirkungen haben

-- TEST: Unit-Tests schreiben
-- Diese Funktion braucht noch Tests

-- FIX: Alternative zu FIXME
-- Auch dies sollte als Bug markiert werden

local M = {}

-- TODO(nico): Assignee in Klammern
-- Dies ist einem spezifischen Entwickler zugewiesen

-- TODO: Multi-line TODO
-- Diese TODO geht über
-- mehrere Zeilen und sollte
-- trotzdem erkannt werden

function M.example_function()
	-- FIXME: Diese Funktion ist kaputt
	local result = nil

	-- HACK: Temporärer Fix für Production
	if not result then
		result = "default"
	end

	-- TODO: Implementiere proper error handling
	-- NOTE: Siehe auch die Dokumentation unter docs/error-handling.md

	return result
end

-- PERF: Optimize this loop
function M.slow_function()
	local data = {}

	-- WARNING: This can cause memory issues with large datasets
	for i = 1, 1000000 do
		-- TODO: Use more efficient data structure
		table.insert(data, i * 2)
	end

	return data
end

-- Multiple TODOs in one function
function M.complex_function()
	-- TODO: Add input validation
	-- FIXME: Handle nil values properly
	-- HACK: Using global variable temporarily
	-- NOTE: This will be refactored in v2.0
	-- PERF: Consider caching results
	-- WARNING: Not thread-safe

	local cache = _G.temp_cache or {}

	-- TODO: Implement actual logic here
	return cache
end

-- Edge cases and special formats

-- TODO #123: Issue number reference
-- FIXME(high): Priority indication
-- HACK!: Urgent marker
-- NOTE @mention: Mention someone
-- TODO [2024-01-15]: Date reference

-- Nested TODOs in conditionals
function M.conditional_todos()
	local config = vim.fn.exists("g:my_plugin_config")

	if config == 1 then
		-- TODO: Load user configuration
		-- NOTE: Configuration format documented in README
	else
		-- FIXME: Default config is broken
		-- HACK: Hardcoded values for now
		return {
			enabled = true,
			-- WARNING: These defaults may not work for everyone
		}
	end
end

-- TODOs in different comment styles
--[[ 
    TODO: Block comment TODO
    This is a multi-line block comment
    with a TODO that should be detected
]]

--[[
    FIXME: Another block comment
    With multiple lines
    And multiple issues:
    - Issue 1
    - Issue 2
    - Issue 3
]]

--- TODO: LuaDoc style comment
--- This function needs documentation
--- @param value any
--- @return boolean
function M.needs_docs(value)
	-- FIXME: Implement actual logic
	return true
end

-- Language-specific TODOs mixed with code
local todo_in_string = "This string contains TODO but shouldn't be highlighted"
local fixme_var = "FIXME" -- FIXME: Bad variable name

-- TODO: This is a real TODO even though there's TODO in strings above

-- Special characters in TODOs
-- TODO: Implement feature (with parentheses)
-- FIXME: Fix bug [with brackets]
-- HACK: Temporary {with braces}
-- NOTE: Important! With exclamation!
-- WARNING: Dangerous? With question?

-- Unicode in TODOs
-- TODO: 实现这个功能 (Chinese)
-- FIXME: Исправить это (Russian)
-- NOTE: ⚠️ Mit Emoji
-- HACK: 🔧 Quick fix

-- Different indentation levels
function M.nested_function()
	if true then
		if true then
			if true then
				-- TODO: Deeply nested TODO
				-- FIXME: Should still be found
				local deep = true

				if deep then
					-- HACK: Even deeper
					-- NOTE: Maximum nesting test
				end
			end
		end
	end
end

-- TODOs at end of line
local var1 = "value" -- TODO: Inline TODO
local var2 = 42 -- FIXME: Inline FIXME
local var3 = {} -- HACK: Inline HACK

-- Empty TODOs (edge cases)
-- TODO:
-- FIXME:
-- NOTE:

-- TODOs with special Vim modeline
-- vim: TODO this should not interfere with vim modeline

-- Markdown-style TODOs in comments
-- - [ ] TODO: Checkbox style TODO
-- - [x] DONE: This is done (should not be highlighted)
-- * TODO: Bullet point TODO
-- 1. FIXME: Numbered list FIXME

-- Git conflict markers with TODOs (edge case)
-- <<<<<<< HEAD
-- TODO: This is in a conflict
-- =======
-- FIXME: This is the other side
-- >>>>>>> branch-name

-- Return module
-- TODO: Add more test cases as needed
return M

-- Final TODOs at end of file
-- TODO: End of file TODO
-- FIXME: Should still be detected
-- NOTE: Last note in file
