# TeXMagic.nvim

## Introduction

This is a simple, lightweight [Neovim](https://neovim.io) plugin that facilitates LaTeX build engine selection via magic comments. It is designed with the [TexLab](https://https://github.com/latex-lsp/texlab) LSP server's build functionality in mind, which at the time of this plugin's inception had to be specified in `init.lua`/`init.vim` and could not be set on a by-project basis.

The plugin identifies magic comments at the very top of a LaTeX document (as below) and will specifically extract magic TeX *program* comments which specify the name of a particular build engine.

```
%! TEX program = xelatex
```
The plugin looks for the engine name in two places:

1. In a table of custom build engines that you provide in `init.lua`/`init.vim` (via the `setup()` function).
2. In the table of default build engines.

The plugin provides three default build engines: `pdflatex`, `xelatex`, and `dvipspdf`. All of these use `latexmk`, and they are only made available via the `setup` function. The user can also provide any number of custom build engines (see below).

### The need for this plugin
As a [Vimtex](https://github.com/lervag/vimtex) user who was migrating to Neovim 0.5.0 and wanted to try using the built-in LSP client and as much Lua as possible, I started using the TexLab LSP server, which provides build functionality. Unlike Vimtex, TexLab build settings have to be specified globally, which is unhelpful for folks who need different build engines for different projects. I wrote this plugin to allow magic comments to be used with TexLab's build facilities. This makes TexLab's build functionality about as useful as Vimtex's build functionality and prevents me from needing to use Vimtex, which reduces the amount of Vimscript that needs to be interpreted.

### FYI
* If the document started out with no magic comment, the default build engine (`pdflatex`) is selected. If you then write a magic comment, you'll need to close and reopen the file for it to be recognized.
* If you change the TeX program written in a magic comment, you'll need to reopen your file for the comment to be recognized.

## Use
Install using your preferred package manager. If you're using [paq-nvim](https://github.com/savq/paq-nvim), for instance:

```lua
require('paq-nvim').paq{'jakewvincent/texmagic.nvim'}
```

For the plugin's functionality to be available, you must call the setup function. Once it is called, a global variable called `TeXMagicBuildConfig` is made available that can be used to value e.g. TexLab's build key.


### Default build engines only

You can pass nothing to the setup function, in which case the default build engines are made available and can be selected if their name matches the program name specified in a magic comment.

```lua
-- Only default build engines made available (pdflatex, xelatex, dvipspdf)
require('texmagic').setup{}
```

### Custom build engines (and/or defaults)

The user can also specify different build engines. If these have the same name as any of the default build engines, TeXMagic will prioritize those over the defaults. **There must be a key named 'engines' in the table you provide.**

```lua
-- Run setup and also specify custom build engines
require('texmagic').setup{
    engines = {
        pdflatex = {    -- This has the same name as a default engine but will be preferred
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
        lualatex = {    -- This is not one of the defaults; it can now be called via magic comment
            executable = "latexmk"
            args = {
                "-pdflua",
                "-interaction=nonstopmode",
                "-synctex=1",
                "-pv",
                "%f"
            },
            isContinuous = false
        }
    }
}
```

### Pass the global build variable to build config

After calling the setup function, interface your build config (e.g. for TexLab) with TeXMagic using the global variable `TeXMagicBuildConfig`. If I'm using TexLab's build commands and want to allow the build engine to vary based on my magic comments, I'll use `TeXMagicBuildConfig` to value the `build` key in my TexLab config table (as follows).

```lua
require('lspconfig').texlab.setup{
    cmd = {"texlab"},
    filetypes = {"tex", "bib"},
    settings = {
        texlab = {
            rootDirectory = nil,
            --      ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓ ↓
            build = TeXMagicBuildConfig,
            --      ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑ ↑
            forwardSearch = {
                executable = "evince",
                args = {"-f"}
            }
        }
    }
}
```

## Improvements
- [X] Allow for build processes to be specified by the user and given a name that the magic comment can point to
- [ ] Make documentation
- [ ] Allow plugin to be restarted and TexLab's build settings to be reloaded without closing file

## Links
* Helpful defaults for Neovim's built-in LSP client: [nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
* LaTeX LSP server: [Texlab](https://github.com/latex-lsp/texlab)
* [Config for texlab](https://github.com/neovim/nvim-lspconfig/blob/)
