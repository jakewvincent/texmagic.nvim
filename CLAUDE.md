# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

TeXMagic.nvim is a Neovim plugin that selects LaTeX build engines based on magic comments (`%! TEX program = xelatex`) at the top of `.tex` files. It's designed to integrate with the TexLab LSP server via nvim-lspconfig, enabling per-project build engine configuration.

## Development

There is no build system, test suite, or linter configured. The plugin is pure Lua + VimScript and is tested manually in Neovim. To test changes, load the plugin in Neovim (e.g. via a plugin manager pointing to the local path) and open a `.tex` file with magic comments.

Diagnostic commands available in Neovim: `:TeXMagicShowComments`, `:TeXMagicCommentsFound`, `:TeXMagicSetupStatus`, `:TeXMagicSelectedProgram`, `:TeXMagicConfigFound`, `:TeXMagicLoaded`.

## Architecture

All core logic lives in `lua/texmagic/magiccomments.lua`. The module `lua/texmagic/init.lua` simply re-exports it.

### magiccomments.lua — the entire plugin logic

- `M.findMagicComments(path)` — reads a file from disk via `io.open`, collects consecutive lines from the top matching the pattern `%! TEX ...`, returns them as a table.
- `M.findTexProgram(magic)` — scans magic comment strings for `program`, extracts the value after `=`, returns it lowercased with whitespace stripped.
- `M.config_defaults` — table of three default `latexmk` engines: `pdflatex`, `xelatex`, `dvipspdf`.
- `M.setup(user_config)` — entry point called by the user. Checks if current buffer is a `.tex` file, parses its magic comments, resolves the build engine (user engines → defaults → pdflatex fallback), and exposes the result as both `M.buildConfig` (preferred) and the legacy global `_G.TeXMagicBuildConfig`.

### plugin/texmagic.vim

VimScript plugin loader with a `g:loaded_texmagic` guard. Defines the user-facing `:TeXMagic*` diagnostic commands.

### Integration pattern

Users call `require('texmagic').setup({engines = {...}})` in their Neovim config, then pass `require('texmagic').buildConfig` (or legacy `_G.TeXMagicBuildConfig`) to `require('lspconfig').texlab.setup{settings = {texlab = {build = require('texmagic').buildConfig}}}`.

## Key Constraints

- Magic comments are only read at setup time (file open). Changing a magic comment requires reopening the file or re-running setup.
- The plugin reads files from disk via `io.open`, not from Neovim buffers.
- License: GPL-3.0. Source files include the license header.
