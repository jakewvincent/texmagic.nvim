# TeXmagic.nvim

## Introduction

This is a very simple [Neovim](https://neovim.io) plugin that identifies magic comments written atop a LaTeX document (as below), pulls the critical information, and makes it available for reference in settings passed to a TeX compiling system. Currently, it only pulls TeX program magic comments.

```
%! TEX program = xelatex
```

## Use
Install using your preferred package manager. If you're using [paq-nvim](https://github.com/savq/paq-nvim), for instance:

```lua
require('paq-nvim').paq{'jakewvincent/texmagic.nvim'}
```

The plugin provides a function `texProgram()` which returns a string. In the case that the opened file has a `.tex` extension and has a magic comment, the `texProgram()` returns the program name in lowercase with whitespace removed. One way you might use `texProgram()` in your `init.lua` is to define a local variable that you pass to the configuration for whatever compiler system you're using. I'm using [latexmk](https://mg.readthedocs.io/latexmk.html) via [texlab](https://github.com/neovim/nvim-lspconfig/blob/master/CONFIG.md#texlab), so my magic comment will work as an argument that texlab will pass to latexmk.

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
                -- note tex_program variable below is concatenated w/ '-'
                args = {"-"..tex_program, "-interaction=nonstopmode", "-synctex=1", "-outdir=.", "-auxdir=.build", "-pv", "%f"};
                isContinuous = false;
            };
            auxDirectory = ".build";
            forwardSearch = {
                executable = "evince";
                args = { "-f" };
            }
        }
    }
}
```

## Links
* Helpful defaults for Neovim's built-in LSP client: [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
* LaTeX LSP server: [Texlab](https://github.com/latex-lsp/texlab)
* [Config for texlab](https://github.com/neovim/nvim-lspconfig/blob/)
