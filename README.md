# TeXmagic.nvim

## Introduction

This is a very simple [Neovim](https://neovim.io) plugin that identifies magic comments written atop a LaTeX document (like the one below), pulls the critical information, and makes it available for reference in settings passed to a TeX compiling system. Currently, it only pulls TeX program magic comments.

```
%! TEX program = xelatex
```

### Context
As a [Vimtex](https://github.com/lervag/vimtex) user who was migrating to Neovim 0.5.0 and wanted to use the built-in LSP client, I started using the Texlab LSP server, which has facilities for calling build commands and such. Unlike Vimtex, though, Texlab won't read magic comments; build settings have to be specified globally, which is really unhelpful for folks who need to use more than one build process across different projects. I wrote this plugin to allow magic comments to be used with Texlab. In the Texlab config, the argument for the compiler program is swapped for a variable name that is defined according to the magic comment.

### FYI
* If the document started out with no magic comment, the default (`pdflatex`) is used.
* Changing the tex program via magic comment will require reopening your file (or sourcing your $MYVIMRC)

## Use
Install using your preferred package manager. If you're using [paq-nvim](https://github.com/savq/paq-nvim), for instance:

```lua
require('paq-nvim').paq{'jakewvincent/texmagic.nvim'}
```

The plugin provides a function `texProgram()` which returns a string. In the case that the opened file is not a TeX file or has no magic comment, `texProgram()` returns `pdflatex`. In the case that the opened file has a `.tex` extension and has a magic comment, the `texProgram()` returns the program name in lowercase with whitespace removed. One way you might use `texProgram()` in your `init.lua` is to define a local variable that you pass to the configuration for whatever compiler system you're using. I'm using [latexmk](https://mg.readthedocs.io/latexmk.html) via [texlab](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#texlab), so my magic comment will work as an argument that texlab will pass to latexmk.

```lua
local tex_program = require('texmagic').texProgram()    -- retrieve tex program name

-- LSP setup
---- Texlab setup
require'lspconfig'.texlab.setup{
    cmd = { "texlab" };
    filetypes = { "tex", "bib" };
    settings = {
        texlab = {
            rootDirectory = nil;
            build = {
                executable = "latexmk";
                --           ↓↓↓↓↓↓↓↓↓↓↓
                args = {"-"..tex_program, "-interaction=nonstopmode", "-synctex=1", "-outdir=.", "-auxdir=.", "-pv", "%f"};
                --           ↑↑↑↑↑↑↑↑↑↑↑
                isContinuous = false;
            };
            auxDirectory = ".";
            forwardSearch = {
                executable = "evince";
                args = { "-f" };
            }
        }
    }
}
```
## Improvements
- [ ] Allow for build processes to be specified by the user and given a name that the magic comment can point to
- [ ] Make documentation

## Links
* Helpful defaults for Neovim's built-in LSP client: [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
* LaTeX LSP server: [Texlab](https://github.com/latex-lsp/texlab)
* [Config for texlab](https://github.com/neovim/nvim-lspconfig/blob/)
