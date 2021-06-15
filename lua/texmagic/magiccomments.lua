-- TeXmagic.nvim (Magic comment finder for Neovim)
-- Copyright (C) 2021 Jake W. Vincent <https://github.com/jakewvincent>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.
local M = {}

--------------------------
-- Magic comment finder --
--------------------------
M.findMagicComments = function(path)

    -- Try to open the provided file
    local file = io.open(path, "r")

    -- If it exists, read the first line and store it in a table if there
    -- are any magic comments. If there are, check the next line and repeat.
    if file ~= nil then
        local line = file:read()
        local magic = {}                                        -- make table for storing magic comments
        if line ~= nil then
            while string.find(line, '%%%s*!%s*TEX') ~= nil do   -- as long as line has a magic tex comment, ...
                table.insert(magic, line)                       -- add it to magic table
                line = file:read()                              -- get the next line
                if line == nil then                             -- if it was nil, chg 'line' to an empty string
                    line = ""
                end
            end
        end
        file:close()                                            -- close the file
        return(magic)                                           -- return a table of the magic comments
    else
        return({})
    end
end

------------------------
-- TeX program finder --
------------------------
M.findTexProgram = function(magic)

    -- If there were no magic comments, return nil
    if #magic == 0 then
        return(nil)

    -- Otherwise, scour the magic comments for the string "program" and return it/nil if not found
    else
        local tex_program
        for i = 1, #magic, 1 do
            if string.find(magic[i], "program") ~= nil then     -- if a cell in the table contains the word "program", ...
                local start = string.find(magic[i], "=") + 1    -- get the index of the = sign
                tex_program = string.lower(                     -- get the stuff after =, converting it to lowercase, ...
                    string.gsub(
                        string.sub(
                            magic[i], start
                        ), "%s+", ""                            -- and stripping whitespace
                    )
                )
            end
        end
        return(tex_program)
    end

end

-----------------------------------
-- Define default build settings --
-----------------------------------
M.config_defaults = {
    engines = {
        pdflatex = {
            executable = "latexmk",
            args = {
                "-pdflatex",
                "-interaction=nonstopmode",
                "-synctex=1",
                "-pv",
                "%f"
            },
            isContinuous = false
        },
        xelatex = {
            executable = "latexmk",
            args = {
                "-xelatex",
                "-pdfxe",
                "-interaction=nonstopmode",
                "-synctex=1",
                "-pv",
                "%f"
            },
            isContinuous = false
        },
        dvipspdf = {
            executable = "latexmk",
            args = {
                "-dvi",
                "-ps",
                "-pdfps",
                "-interaction=nonstopmode",
                "-synctex=1",
                "-pv",
                "%f"
            }
        }
    }
}

-------------------------------------
-- Variables for diagnosing issues --
-------------------------------------
M.setup_run = false
M.magic_comments_found = false
M.magic_selected_program = "No program selected."
M.config_provided = nil

-----------------------------------------------
-- Setup function (user calls from init.lua) --
-----------------------------------------------
M.setup = function(user_config)
    -- Mark that setup was run
    M.setup_run = true

    -- Get the current buffer name
    local buffer = vim.api.nvim_buf_get_name(0)

    -- Extract its extension
    local ext = buffer:match("^.+%.(.+)$")

    -- If it's a tex file, do some stuff
    if ext == "tex" then

        if #M.findMagicComments(buffer) > 0 then

            -- Keep "found" status in variable for user to check
            M.magic_comments_found = true

            -- Get user's magic comment specifying program/engine
            local TEX_program = M.findTexProgram(M.findMagicComments(buffer))

            -- If there was no program comment in the magic comments,
            -- value the variable as an empty string.
            if TEX_program == nil then TEX_program = "" end

            -- Check if a user config has been provided
            for key, value in pairs(user_config) do
                if value then
                    M.config_provided = true
                else
                    M.config_provided = false
                end
            end

            -- If one was provided, check it for the requested program; then check
            -- the defaults; then fall back on pdflatex if needed.
            if M.config_provided and user_config.engines[TEX_program] ~= nil then
                -- Remember where the selected program came from
                M.magic_selected_program = "Program '"..TEX_program.."' selected from user-provided build engines."
                -- If a config has been provided, see if it contains the requested program
                TeXMagicBuildConfig = user_config.engines[TEX_program]
            elseif M.config_provided and M.config_defaults.engines[TEX_program] ~= nil then
                -- Remember where the selected program came from
                M.magic_selected_program = "Program '"..TEX_program.."' selected from default build engines."
                -- If not in user config, see if the defaults contains the requested program
                TeXMagicBuildConfig = M.config_defaults.engines[TEX_program]
            elseif M.config_provided then
                -- Remember where the program came from
                M.magic_selected_program = "Program '"..TEX_program.."' not found in user-provided or default build engines. Fell back on 'pdflatex'."
                -- Otherwise, just use pdflatex
                TeXMagicBuildConfig = M.config_defaults.engines.pdflatex
            end

        else

            -- Keep "not found" status in variable for user to check
            M.magic_comments_found = false

        end
    end
end

return M
