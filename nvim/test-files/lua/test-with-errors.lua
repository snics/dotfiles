-- =============================================================================
-- Lua Test File with Intentional Errors
-- Tests for selene and stylua
-- =============================================================================

-- Error: Global variable without declaration
undeclared_global = "This is a global"
another_global = 123

-- Error: Unused variable
local unused_var = "This is never used"
local another_unused = function() end

-- Error: Unused function
local function unused_function()
    print("This function is never called")
end

-- Error: Unused parameter
local function has_unused_param(used, unused, also_unused)
    print(used)
    -- unused and also_unused are not used
end

-- Error: Shadowing variable
local shadow = "outer"
local function test_shadow()
    local shadow = "inner"  -- Shadows outer shadow
    print(shadow)
end

-- Error: Mixed indentation (tabs and spaces)
local function mixed_indent()
	local tab_indent = 1
  local space_indent = 2  -- Spaces instead of tabs
    return tab_indent + space_indent
end

-- Error: Incorrect spacing
local function spacing_issues()
    local a=1  -- No spaces around =
    local b =2  -- Inconsistent spacing
    local c= 3  -- Inconsistent spacing
    return a+b*c  -- No spaces around operators
end

-- Error: Trailing whitespace
local trailing = "value"    
local more_trailing = 123   

-- Error: Missing local
function global_function()  -- Should be local
    print("This is global")
end

-- Error: Using deprecated functions
local str = "test"
local len = string.len(str)  -- Should use #str
local substr = string.sub(str, 1, 2)  -- Consider str:sub(1, 2)

-- Error: Comparing to nil explicitly
local function check_nil(value)
    if value == nil then  -- Should use 'if not value then'
        return false
    end
    if value ~= nil then  -- Should use 'if value then'
        return true
    end
end

-- Error: Redundant parentheses
local function redundant_parens()
    local a = (1 + 2)  -- Unnecessary parentheses
    local b = ((3 * 4))  -- Double unnecessary
    return (a + b)  -- Return doesn't need parentheses
end

-- Error: Empty if statement
local function empty_blocks()
    if true then
        -- Empty block
    end
    
    for i = 1, 10 do
        -- Empty loop
    end
    
    while false do
        -- Empty while
    end
end

-- Error: Unreachable code
local function unreachable()
    return 1
    print("This is unreachable")  -- After return
    local never_reached = 123
end

-- Error: Constant condition
local function constant_conditions()
    if true then  -- Always true
        print("Always executed")
    end
    
    if false then  -- Always false
        print("Never executed")
    end
    
    while true do  -- Infinite loop
        break
    end
end

-- Error: Magic numbers
local function magic_numbers()
    local timeout = 3600  -- What does 3600 mean?
    local max_retries = 5  -- Magic number
    local buffer_size = 8192  -- Another magic number
end

-- Error: Long line (exceeds typical line length limit)
local very_long_line = "This is an extremely long line that exceeds the typical 80 or 100 character limit that many Lua style guides recommend for better readability"

-- Error: Multiple statements on one line
local a = 1; local b = 2; local c = 3  -- Should be on separate lines

-- Error: Wrong comment style for documentation
-- This function does something  -- Should use --- for docs
local function documented_wrong()
    return true
end

-- Error: Missing return type consistency
local function inconsistent_returns(condition)
    if condition then
        return "string"
    else
        return 123  -- Different type
    end
end

-- Error: Table constructor spacing
local bad_table = {a=1,b=2,c=3}  -- No spaces
local inconsistent_table = {
    a = 1,
    b=2,  -- Inconsistent spacing
    c =3,  -- Inconsistent spacing
}

-- Error: Using table.getn (deprecated)
local t = {1, 2, 3}
local size = table.getn(t)  -- Deprecated, use #t

-- Error: String concatenation in loop
local function bad_concat()
    local result = ""
    for i = 1, 100 do
        result = result .. i  -- Inefficient, should use table.concat
    end
    return result
end

-- Error: Not using local for loop variable
for i = 1, 10 do  -- i should be implicitly local but showing bad practice
    print(i)
end

-- Error: Modifying table while iterating
local function modify_during_iteration()
    local t = {1, 2, 3, 4, 5}
    for i, v in ipairs(t) do
        if v == 3 then
            table.remove(t, i)  -- Modifying during iteration
        end
    end
end

-- Error: Using pairs when ipairs would be better
local function wrong_iterator()
    local array = {1, 2, 3, 4, 5}
    for k, v in pairs(array) do  -- Should use ipairs for arrays
        print(k, v)
    end
end

-- Error: Not checking table before indexing
local function unsafe_index()
    local t = nil
    print(t.field)  -- Will error if t is nil
end

-- Error: Global function in module
function GlobalModuleFunction()  -- Should be local or in module table
    return "global"
end

-- Error: Wrong use of 'and' and 'or' for ternary
local function wrong_ternary(condition)
    -- This pattern fails when value is falsy
    local result = condition and false or true  -- Incorrect for false value
    return result
end

-- Error: Type checking with type() inefficiently
local function inefficient_type_check(value)
    if type(value) == "string" then
        return true
    elseif type(value) == "string" then  -- Duplicate condition
        return false
    end
end

-- Error: Manual table size calculation
local function manual_size()
    local t = {1, 2, 3, 4, 5}
    local size = 0
    for _ in pairs(t) do
        size = size + 1  -- Should use #t for arrays
    end
    return size
end

-- Error: Using rawget/rawset unnecessarily
local function unnecessary_raw()
    local t = {a = 1}
    local value = rawget(t, "a")  -- Regular indexing would work
    rawset(t, "b", 2)  -- Regular assignment would work
end

-- Error: Redundant else after return
local function redundant_else(value)
    if value > 0 then
        return "positive"
    else  -- Redundant else
        return "non-positive"
    end
end

-- Error: Complex expressions without parentheses
local function complex_expression()
    local result = 1 + 2 * 3 / 4 - 5 % 6  -- Unclear precedence
    return result
end

-- Error: Using loadstring (deprecated/dangerous)
local function dangerous_load()
    local code = "print('executed')"
    loadstring(code)()  -- Security risk, deprecated
end

-- Error: Missing error handling
local function no_error_handling()
    local file = io.open("nonexistent.txt", "r")  -- Might fail
    local content = file:read("*a")  -- Will error if file is nil
    file:close()
end

-- Error: Comparing different types
local function compare_different_types()
    local a = "5"
    local b = 5
    if a == b then  -- Comparing string to number
        print("Equal")
    end
end

-- Error: Using deprecated table.foreach
local function deprecated_foreach()
    local t = {a = 1, b = 2}
    table.foreach(t, print)  -- Deprecated
end

-- Error: Side effects in condition
local function side_effects_in_condition()
    local i = 0
    if (i = i + 1) > 0 then  -- Assignment in condition (also syntax error)
        print(i)
    end
end

-- Error: Missing do in while loop
--while true  -- Missing do
--    print("loop")
--end

-- Error: Using goto (might be restricted)
::label::
local function uses_goto()
    goto label  -- goto usage (might be discouraged)
end

-- Error: Unclosed string
-- local unclosed = "This string is not closed

-- Error: Invalid escape sequence
local invalid_escape = "Invalid \q escape"

-- Error: Mixed quotes
local mixed = "String with ' quotes"  -- Should be consistent

-- Error: Boolean comparison
local function boolean_compare()
    local flag = true
    if flag == true then  -- Should just use 'if flag then'
        print("True")
    end
end

-- Error: Using arg instead of ... 
local function old_varargs()
    local args = arg  -- Deprecated, use {...}
end

-- Error: Missing local in nested function
local function outer()
    function inner()  -- Should be local
        return "inner"
    end
end

-- Error: Semicolons (not needed in Lua)
local with_semicolon = 1;
local another_semicolon = 2;

-- Error: C-style comments (not valid in Lua)
// This is not a valid comment
/* This is also not valid */

-- Error: Wrong metamethod name
local mt = {
    __Index = function(t, k)  -- Should be __index (lowercase)
        return nil
    end
}

-- Error: Using self outside of method
local not_a_method = function()
    print(self.value)  -- self not available
end

-- Error: Forgetting to return table in module
local M = {}
M.function1 = function() end
M.function2 = function() end
-- Missing: return M

-- Error: Multiple returns inconsistently
local function multiple_returns()
    if math.random() > 0.5 then
        return 1, 2, 3
    else
        return 1  -- Different number of returns
    end
end

-- Error: Deep nesting
local function deeply_nested()
    if true then
        if true then
            if true then
                if true then
                    if true then
                        print("Too deep!")
                    end
                end
            end
        end
    end
end

-- Error: Dead code after break
local function dead_after_break()
    while true do
        break
        print("Never executed")  -- Dead code
    end
end

-- Error: Using unpack incorrectly
local function wrong_unpack()
    local t = {1, 2, 3}
    local a, b = unpack(t)  -- Missing third value, should handle
end

-- Error: Not localizing standard library functions (performance)
local function not_localized()
    for i = 1, 1000000 do
        math.sin(i)  -- Should localize math.sin
        math.cos(i)  -- Should localize math.cos
    end
end

-- Error: Unnecessary table creation
local function unnecessary_table()
    local function get_values()
        return {1, 2, 3}  -- Creates new table each time
    end
    
    for i = 1, 100 do
        local values = get_values()
    end
end

-- Error: Missing metatables consideration
local function modify_table()
    local t = {}
    t.newfield = 123  -- Might trigger __newindex if metatable exists
end

-- Error: File not ending with newline
print("End of file")  -- No newline after this
