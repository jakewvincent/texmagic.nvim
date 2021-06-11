local M = {}

M.findMagicComments = function()
    if vim.bo.filetype == "tex" then                            -- if current file is a tex file, ...
        local cur_file = vim.api.nvim_buf_get_name(0)           -- get name of current file
        local magic = {}                                        -- make table for storing magic comments
        local tex_program = "pdflatex"                          -- set default value for tex_program
        local tex_file = io.open(cur_file, "r")                 -- lua.open tex file in read mode
        local line = tex_file:read()                            -- grab first line
        while string.find(line, '%%%s*!%s*TEX') ~= nil do       -- as long as line has a magic tex comment, ...
            table.insert(magic, line)                           -- add it to magic table
            line = tex_file:read()                              -- get the next line
        end
        tex_file:close()                                        -- close the file
        for i = 1, #magic, 1 do
            if string.find(magic[i], "program") ~= nil then     -- if a cell in the table contains the word "program", ...
                local start = string.find(magic[i], "=") + 1    -- get the index of the = sign
                local tex_program = string.lower(               -- get the stuff after =, converting it to lowercase, ...
                    string.gsub(
                        string.sub(
                            magic[i], start
                        ), "%s+", ""                            -- and stripping whitespace
                    )
                )
            end
            return{tex_program = tex_program}                   -- return a table
        end
    else
        return{tex_program = "pdflatex"}                        -- otherwise, use return the same table but w/ the default value
    end
end

M.texProgram = function()
    --print(M.findMagicComments()["tex_program"])               -- test
    return(M.findMagicComments()["tex_program"])                -- return the tex program
end

return M
