-- 04/04/2025
-- Baby's first lua

local M = {}
function M.test()
    local buffer = 0 -- means current buffer
    local cursor = vim.api.nvim_win_get_cursor(buffer)
    local row,col = unpack(cursor)

    -- Only run on the init line
    -- Provide error...?
    local line = vim.api.nvim_get_current_line()
    if not M.is_init(line) then
        return
    end

    local items = M.generate_lines(line)
    for _,item in ipairs(items) do
        vim.api.nvim_buf_set_lines(
            buffer,
            row, -- starting line
            row, -- ending line
            false, -- false means lines append, not overwrite
            {item}
        )
        row = row + 1
    end
end

function M.is_init(line)
    local trimmed = line:gsub("^%s*","") -- trims ^ start %s whitespace * any
    local check = "def __init__(self"
    if trimmed:sub(1,#check) == check then
        return true
    end
    return false
end

function M.get_indent_level(init_line)
    local pattern = "^(%s*)def __init__%(" -- &( escapes paren
    local whitespace = init_line:match(pattern) or ""
    local indent = math.floor(#whitespace/4)
    return indent
end

-- Returns table of each argument turned into self.var assignments
function M.generate_lines(init_line)
    local args = M.get_args(init_line)
    if not args then
        return nil
    end

    local indents = M.get_indent_level(init_line)
    local tabs = string.rep("\t",indents+1)
    args = M.split(args,",")
    table.remove(args,1) -- this removes the first self argument

    local new_lines = {}
    for i,arg in ipairs(args) do
        local new_line = tabs .. "self." .. arg .. " = " .. arg
        table.insert(new_lines,new_line)
    end

    return new_lines
end

-- Returns the comma seperated values inside paren
function M.get_args(line)
    local args = string.match(line,"%b()")
    if args then
        -- Slicing to remove L/R paren
        return args:sub(2,-2)
    else
        return nil
    end
end

-- Using this as a string splitter
function M.split(str,delimiter)
    local items = {}
    local pattern = "([^" .. delimiter .. "]+)"
    local matches = string.gmatch(str,pattern)
    for item in matches do
        table.insert(items,item)
    end
    return items
end


-- This register the user command
vim.api.nvim_create_user_command(
        "Init",-- Command name
        function() M.test() end, -- Function to run
        {} -- options for the command
    )

return M

