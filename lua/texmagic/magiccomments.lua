local M = {}

local magic = {}                                                -- table for storing magic comments
local tex_program                                               -- TeX program variable

M.findMagicComments = function()
    local cur_file = vim.api.nvim_buf_get_name(0)               -- get name of current file
    if string.find(cur_file, '%.tex') ~= nil                    -- if current file has tex extension, ...
    then
        local tex_file = io.open(cur_file, "r")                 -- lua open tex file in read mode
        local line = tex_file:read()                            -- grab first line
        local i = 1                                             -- initialize counter variable
        while string.find(line, '%%%s*!%s*TEX') ~= nil do       -- as long as line has a magic tex comment, ...
            table.insert(magic, line)                           -- add it to table
            i = i + 1                                           -- increment counter
            line = tex_file:read()                              -- get the next line
        end
        tex_file:close()                                        -- close the file
--        print(table.concat(magic))                              -- [for testing]
    end
    -- set some variables based on the magic comments
    for i = 1, #magic, 1 do
        if string.find(magic[i], "program") ~= nil then
            local start = string.find(magic[i], "=") + 1
            tex_program = string.lower(string.gsub(string.sub(magic[i], start), "%s+", ""))
        end
    end
    return{tex_program = tex_program}
end

M.texProgram = function()
    --print(M.findMagicComments()["tex_program"])               -- test
    return(M.findMagicComments()["tex_program"])
end

return M
