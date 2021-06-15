" TeXmagic.nvim (Magic comment finder for Neovim)
" Copyright (C) 2021 Jake W. Vincent <https://github.com/jakewvincent>
"
" This program is free software: you can redistribute it and/or modify
" it under the terms of the GNU General Public License as published by
" the Free Software Foundation, either version 3 of the License, or
" (at your option) any later version.
"
" This program is distributed in the hope that it will be useful,
" but WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
" GNU General Public License for more details.
"
" You should have received a copy of the GNU General Public License
" along with this program.  If not, see <https://www.gnu.org/licenses/>.

if exists('g:loaded_texmagic') | finish | endif        " prevent loading this file twice

let s:save_cpo = &cpo                                   " save user coptions
set cpo&vim                                             " reset them to defaults

" define command to run plugin (or really, the magic comment finder)
command! TeXMagicShowComments lua print(table.concat(require('texmagic').findMagicComments(vim.api.nvim_buf_get_name(0))))

" Returns a boolean indicating whether or not magic comments were found
command! TeXMagicCommentsFound lua print(require('texmagic').magic_comments_found)

" Returns a boolean indicating whether or not the setup function was run
command! TeXMagicSetupStatus lua print(require('texmagic').setup_run)

" Returns a description of the selected TeX build engine (if any)
command! TeXMagicSelectedProgram lua print(require('texmagic').magic_selected_program)

" Returns a boolean indicating whether a user config was found
command! TeXMagicConfigFound lua print(require('texmagic').config_provided)

let &cpo = s:save_cpo                                   " restore user coptions
unlet s:save_cpo

let g:loaded_texmagic = 1
