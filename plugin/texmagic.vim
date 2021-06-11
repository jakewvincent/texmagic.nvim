if exists('g:loaded_texmagic') | finish | endif        " prevent loading this file twice

let s:save_cpo = &cpo                                   " save user coptions
set cpo&vim                                             " reset them to defaults

" define command to run plugin (or really, the magic comment finder)
command! TexmagicFind lua require('texmagic').findMagicComments()
command! TexmagicProgram lua require('texmagic').texProgram()

let &cpo = s:save_cpo                                   " restore user coptions
unlet s:save_cpo

let g:loaded_texmagic = 1
