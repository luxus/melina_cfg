{ config, pkgs, ... }: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    configure = {
      customRC = let
        cargo = "${config.passthru.rust}/bin/cargo";
        nix = "${config.nix.package}/bin/nix";
      in ''
        set clipboard+=unnamedplus
        set colorcolumn=10000
        set completeopt=menuone,noinsert,noselect
        set cursorline
        set expandtab
        set list
        set listchars=tab:-->,trail:+,extends:>,precedes:<,nbsp:·
        set mouse=a
        set nofoldenable
        set noshowmode
        set noswapfile
        set number
        set relativenumber
        set scrolloff=2
        set shiftwidth=4
        set shortmess=aoOtTIcF
        set showtabline=2
        set signcolumn=yes
        set smartindent
        set splitbelow
        set splitright
        set termguicolors
        set timeoutlen=400
        set title
        set updatetime=300

        let indent_blankline_buftype_exclude = ["terminal"]
        let indent_blankline_char = "⎸"
        let indent_blankline_filetype_exclude = ["help", "NvimTree"]
        let mapleader = " "
        let nvim_tree_auto_open = 1
        let nvim_tree_git_hl = 1
        let nvim_tree_gitignore = 1
        let nvim_tree_icons = #{ default: "" }
        let nvim_tree_ignore = [".git"]
        let nvim_tree_lsp_diagnostics = 1
        let nvim_tree_quit_on_open = 1
        let nvim_tree_width_allow_resize = 1
        let nvim_tree_window_picker_exclude = #{ buftype: ["terminal"] }
        let vim_markdown_conceal = 0
        let vim_markdown_conceal_code_blocks = 0

        let s:pairs = {
        \ '"': '"',
        \ "(": ")",
        \ "[": "]",
        \ "`": "`",
        \ "{": "}",
        \ }

        function s:close()
          if &buftype == "terminal"
            bdelete!
          else
            confirm bdelete
          end
        endf

        function s:cr_nix()
          let line = getline(".")
          let pos = col(".")
          if get(s:pairs, line[pos - 2], 1) == line[pos - 1]
            return s:indent_pair("")
          elseif line[pos - 3 : pos - 2] == "'''" && line[pos - 4] != "'"
            return s:indent_pair("'''")
          else
            return "\<cr>"
          end
        endf

        function s:indent_pair(r)
          let indent = repeat(" ", indent(line(".")))
          return printf("\<cr> \<c-u>\<cr> \<c-u>%s%s\<up>%s\<tab>", indent, a:r, indent)
        endf

        function s:init()
          let name = bufname(1)
          if isdirectory(name)
            exec "cd" name
            bdelete 1
          end
        endf

        function s:in_pair()
          let line = getline(".")
          let pos = col(".")
          return (get(s:pairs, line[pos - 2], 1) == line[pos - 1])
        endf

        function s:in_word()
          let line = getline(".")
          let pos = col(".") - 1
          return (pos != len(line) && line[pos] =~ '\w')
        endf

        function s:play(...)
          let file = system("${pkgs.coreutils}/bin/mktemp" .. (a:0 ? " --suffix ." . a:1 : ""))
          exec "edit" file
          exec "autocmd BufDelete <buffer> silent !${pkgs.coreutils}/bin/rm" file
        endf

        function s:quote(c)
          let x = col(".")
          let y = line(".")
          let line = getline(".")

          if x == 1
            let i = y
            while i > 1
              let i -= 1
              let len = strlen(getline(i))
              if len != 0
                let l = synID(i, len, 1)
                break
              end
            endw
          end
          if !exists("l")
            let l = synID(y, x - 1, 1)
          end

          if x > strlen(line)
            let i = y
            while i < nvim_buf_line_count(0) 
              let i += 1
              if !empty(getline(i))
                let r = synID(i, 1, 1)
                break
              end
            endw
          end
          if !exists("r")
            let r = synID(y, x, 1)
          end

          if synIDattr(l, "name") =~? "string\\|interpolationdelimiter"
          \ && synIDattr(r, "name") =~? "string\\|interpolationdelimiter"
            return line[x - 1] == a:c ? "\<right>" : a:c
          else
            return a:c . a:c . "\<left>"
          end
        endf

        no <c-_> <cmd>let @/ = ""<cr>
        no <c-q> <cmd>confirm quitall<cr>
        no <c-s> <cmd>write<cr>
        no <c-w> <cmd>call <sid>close()<cr>

        nn <c-a> <home>
        nn <c-e> <end>
        nn <c-h> <c-w>h
        nn <c-j> <c-w>j
        nn <c-k> <c-w>k
        nn <c-l> <c-w>l
        nn <m-down> <cmd>move +1<cr>
        nn <m-h> <cmd>vertical resize -2<cr>
        nn <m-j> <cmd>resize -2<cr>
        nn <m-k> <cmd>resize +2<cr>
        nn <m-l> <cmd>vertical resize +2<cr>
        nn <m-tab> <cmd>BufferLinePick<cr>
        nn <m-up> <cmd>move -2<cr>
        nn <s-tab> <cmd>BufferLineCyclePrev<cr>
        nn <space>c<space> :!cargo<space>
        nn <space>cU <cmd>!${cargo} upgrade<cr>
        nn <space>cb <cmd>T ${cargo} build<cr>i
        nn <space>cd <cmd>T ${cargo} doc --open<cr>i
        nn <space>cf <cmd>!${cargo} fmt<cr>
        nn <space>cp <cmd>!${pkgs.cargo-play}/bin/cargo-play %<cr>
        nn <space>cr <cmd>T ${cargo} run<cr>i
        nn <space>ct <cmd>T ${cargo} test<cr>i
        nn <space>cu <cmd>!${cargo} update<cr>
        nn <space>g/ <cmd>Rg!<cr>
        nn <space>g<space> :Git<space>
        nn <space>gB <cmd>Git blame<cr>
        nn <space>gR <cmd>lua require("gitsigns").reset_buffer()<cr>
        nn <space>ga <cmd>Git add -p<cr>
        nn <space>gb <cmd>lua require("gitsigns").blame_line()<cr>
        nn <space>gc <cmd>Git commit<cr>
        nn <space>gh <cmd>lua require("gitsigns").preview_hunk()<cr>
        nn <space>gi <cmd>Git<cr>
        nn <space>gl <cmd>Commits!<cr>
        nn <space>go <cmd>GFiles!<cr>
        nn <space>gp <cmd>Git push<cr>
        nn <space>gr <cmd>lua require("gitsigns").reset_hunk()<cr>
        nn <space>gs <cmd>lua require("gitsigns").stage_hunk()<cr>
        nn <space>gu <cmd>lua require("gitsigns").undo_stage_hunk()<cr>
        nn <space>n<space> :!nix<space>
        nn <space>nb <cmd>T ${nix} build<cr>i
        nn <space>nf <cmd>!${pkgs.fd}/bin/fd -H '.nix$' -x ${pkgs.nixfmt}/bin/nixfmt<cr>
        nn <space>ni <cmd>T ${nix} repl ${config.nix.registry.nixpkgs.flake}<cr>i
        nn <space>nr <cmd>T ${nix} run<cr>i
        nn <space>nt <cmd>T ${nix} flake check<cr>i
        nn <space>nu <cmd>!${nix} flake update<cr>
        nn <space>t <cmd>T ${pkgs.fish}/bin/fish<cr>i
        nn <tab> <cmd>BufferLineCycleNext<cr>
        nn R "_diwhp
        nn T <cmd>NvimTreeToggle<cr>
        nn X "_X
        nn [h <cmd>lua require("gitsigns.actions").prev_hunk()<cr>
        nn ]h <cmd>lua require("gitsigns.actions").next_hunk()<cr>
        nn x "_x

        vn < <gv
        vn <c-a> <home>
        vn <c-e> <end>
        vn <silent> <m-down> :move '>+1<cr>gv
        vn <silent> <m-up> :move -2<cr>gv
        vn > >gv

        ino <c-a> <esc>I
        ino <c-e> <end>
        ino <c-h> <esc>l"_dbi
        ino <c-j> <esc>o
        ino <c-k> <esc>O
        ino <c-q> <cmd>confirm quitall<cr>
        ino <c-s> <cmd>write<cr>
        ino <c-w> <cmd>confirm bdelete<cr><esc>
        ino <expr> <bs> <sid>in_pair() ? "<bs><del>" : "<bs>"
        ino <expr> <cr> compe#confirm(<sid>in_pair() ? <sid>indent_pair("") : "<cr>")
        ino <expr> <s-tab> pumvisible() ? "<c-p>" : "<s-tab>"
        ino <expr> <tab> pumvisible() ? "<c-n>" : "<tab>"
        ino <m-,> <cmd>call setline(".", getline(".") . ",")<cr>
        ino <m-;> <cmd>call setline(".", getline(".") . ";")<cr>
        ino <m-down> <cmd>move +1<cr>
        ino <m-h> <s-left>
        ino <m-j> <down>
        ino <m-k> <up>
        ino <m-l> <esc>ea
        ino <m-up> <cmd>move -2<cr>

        for [l, r] in items(s:pairs)
          if l == r
            exec printf("ino <expr> %s <sid>quote('%s')", l, l)
          else
            exec printf("ino <expr> %s <sid>in_word() ? '%s' : '%s%s<left>'", l, l, l, r)
            exec printf("ino <expr> %s getline('.')[col('.') - 1] == '%s' ? '<right>' : '%s'", r, r, r)
          end
        endfor

        tno <expr> <esc> stridx(b:term_title, "#FZF") == -1 ? "<c-\><c-n>" : "<esc>"

        autocmd FileType nix ino <buffer> <expr> <cr> compe#confirm(<sid>cr_nix())

        autocmd FileType rust nn <buffer> J <cmd>RustJoinLines<cr>
        autocmd FileType rust nn <buffer> gm <cmd>RustExpandMacro<cr>

        autocmd FileType yaml setlocal shiftwidth=2

        autocmd VimEnter * silent exec "!${pkgs.util-linux}/bin/kill -s SIGWINCH" getpid() | call s:init()

        command -nargs=? P call s:play(<f-args>)
        command -nargs=+ T botright 12split term://<args>

        ${pkgs.callPackage ./colorscheme.nix { }}

        lua <<EOF
          local lspconfig = require("lspconfig")
          local null_ls = require("null-ls")
          local nb = null_ls.builtins

          local cap = vim.lsp.protocol.make_client_capabilities()
          cap.textDocument.completion.completionItem.snippetSupport = true
          cap.textDocument.completion.completionItem.resovleSupport = {
            properties = {"additionalTextEdits"},
          }

          local function on_attach(_, buf)
            local map = {
              K = "buf.hover",
              ["<space>d"] = "Trouble lsp_document_diagnostics",
              ["<space>e"] = "Trouble lsp_workspace_diagnostics",
              ["<space>f"] = "lua vim.lsp.buf.formatting()",
              ["<space>r"] = "Trouble lsp_references",
              ["[d"] = "lua vim.lsp.diagnostic.goto_prev()",
              ["]d"] = "lua vim.lsp.diagnostic.goto_next()",
              ga = "lua vim.lsp.buf.code_action()",
              gd = "lua vim.lsp.buf.definition()",
              ge = "lua vim.lsp.diagnostic.show_line_diagnostics()",
              gr = "lua vim.lsp.buf.rename()",
              gt = "lua vim.lsp.buf.type_definition()",
            }

            for k, v in pairs(map) do
              vim.api.nvim_buf_set_keymap(buf, "n", k, "<cmd>" .. v .. "<cr>", {noremap = true})
            end
          end

          require("bufferline").setup {
            highlights = {
              background = {guibg = "#1f2227"},
              buffer_visible = {guibg = "#1f2227"},
              close_button = {guibg = "#1f2227"},
              duplicate = {guibg = "#1f2227"},
              duplicate_visible = {guibg = "#1f2227"},
              error = {guibg = "#1f2227"},
              error_visible = {guibg = "#1f2227"},
              fill = {guibg = "#1f2227"},
              indicator_selected = {guifg = "#61afef"},
              modified = {guibg = "#1f2227"},
              modified_visible = {guibg = "#1f2227"},
              pick = {guibg = "#1f2227"},
              pick_visible = {guibg = "#1f2227"},
              separator = {
                guifg = "#1f2227",
                guibg = "#1f2227",
              },
              separator_visible = {
                guifg = "#1f2227",
                guibg = "#1f2227",
              },
              tab = {guibg = "#1f2227"},
              tab_close = {guibg = "#1f2227"},
              warning = {guibg = "#1f2227"},
              warning_selected = {guifg = "#e5c07b"},
              warning_visible = {guibg = "#1f2227"},
            },
            options = {
              custom_filter = function(n)
                return vim.fn.bufname(n) ~= "" and vim.api.nvim_buf_get_option(n, "buftype") ~= "terminal"
              end,
              diagnostics = "nvim_lsp",
              show_close_icon = false,
            },
          }

          require("colorizer").setup(nil, {css = true})

          require("compe").setup {
            source = {
              buffer = true,
              path = true,
              nvim_lsp = true,
            },
          }

          require("gitsigns").setup {
            keymaps = {},
            status_formatter = function(status)
              return " "
                .. (status.head == "" and "detached HEAD" or status.head)
                .. (status.added and status.added > 0 and "  " .. status.added or "")
                .. (status.changed and status.changed > 0 and "  " .. status.changed or "")
                .. (status.removed and status.removed > 0 and "  " .. status.removed or "")
            end,
          }

          require("lualine").setup {
            options = {
              component_separators = "",
              section_separators = "",
              disabled_filetypes = {"NvimTree"},
              theme = {
                normal = {
                  a = {fg = "#1f2227", bg = "#98c379", gui = "bold"},
                  b = {fg = "#abb2bf", bg = "#282c34"},
                  c = {fg = "#abb2bf", bg = "#1f2227"},
                },
                insert = {a = {fg = "#1f2227", bg = "#61afef", gui = "bold"}},
                visual = {a = {fg = "#1f2227", bg = "#c678dd", gui = "bold"}},
                replace = {a = {fg = "#1f2227", bg = "#e06c75", gui = "bold"}},
                inactive = {
                  a = {fg = "#5c6370", bg = "#1f2227", gui = "bold"},
                  b = {fg = "#5c6370", bg = "#1f2227"},
                  c = {fg = "#5c6370", bg = "#1f2227"},
                },
              },
            },
            sections = {
              lualine_b = {"b:gitsigns_status"},
              lualine_c = {"filename", {"diagnostics", sources = {"nvim_lsp"}}},
            },
          }

          lspconfig.rnix.setup {
            cmd = {"${pkgs.rnix-lsp}/bin/rnix-lsp"},
            on_attach = on_attach,
          }

          lspconfig.yamlls.setup {
            cmd = {"${pkgs.yaml-language-server}/bin/yaml-language-server", "--stdio"},
            on_attach = on_attach,
          }

          require("lspkind").init {with_text = false}

          null_ls.setup {
            on_attach = on_attach,
            sources = {
              nb.code_actions.gitsigns,
              nb.diagnostics.shellcheck.with {command = "${pkgs.shellcheck}/bin/shellcheck"},
              nb.formatting.prettier.with {command = "${pkgs.nodePackages.prettier}/bin/prettier"},
              nb.formatting.stylua.with {command = "${pkgs.stylua}/bin/stylua"},
            },
          }

          require("numb").setup()

          require("nvim-treesitter.configs").setup {
            highlight = {
              enable = true,
              disable = {"nix"},
            },
            textobjects = {
              lsp_interop = {
                enable = true,
                border = "single",
                peek_definition_code = {
                  gK = "@function.outer",
                },
              },
              move = {
                enable = true,
                goto_next_start = {
                  ["]]"] = "@class.outer",
                  ["]m"] = "@function.outer",
                },
                goto_next_end = {
                  ["]["] = "@class.outer",
                  ["]M"] = "@function.outer",
                },
                goto_previous_start = {
                  ["[["] = "@class.outer",
                  ["[m"] = "@function.outer",
                },
                goto_previous_end = {
                  ["[]"] = "@class.outer",
                  ["[M"] = "@function.outer",
                },
              },
              select = {
                enable = true,
                lookahead = true,
                keymaps = {
                  ab = "@block.outer",
                  ib = "@block.inner",
                  ac = "@class.outer",
                  ic = "@class.inner",
                  af = "@function.outer",
                  ["if"] = "@function.inner",
                  ai = "@conditional.outer",
                  ii = "@conditional.inner",
                  al = "@loop.outer",
                  il = "@loop.inner",
                },
              },
            },
          }

          require("rust-tools").setup {
            server = {
              capabilities = cap,
              cmd = {"${pkgs.rust-analyzer-nightly}/bin/rust-analyzer"},
              on_attach = function(c, buf)
                on_attach(c, buf)
                require("lsp_signature").on_attach {
                  handler_opts = {
                    border = "single",
                  },
                }
              end,
              settings = {
                ["rust-analyzer"] = {
                  assist = {
                    importPrefix = "by_crate",
                  },
                  checkOnSave = {
                    command = "clippy",
                  },
                },
              },
            },
            tools = {
              inlay_hints = {
                other_hints_prefix = "",
                show_parameter_hints = false,
              },
            },
          }

          require("trouble").setup()
        EOF
      '';
      packages.all.start = with pkgs.vimPlugins; [
        fzf-vim
        gitsigns-nvim
        indent-blankline-nvim
        lightspeed-nvim
        lsp_signature-nvim
        lspkind-nvim
        lualine-nvim
        luasnip
        null-ls-nvim
        numb-nvim
        nvim-bufferline-lua
        nvim-colorizer-lua
        nvim-compe
        nvim-lspconfig
        nvim-tree-lua
        (nvim-treesitter.withPlugins (_: pkgs.tree-sitter.allGrammars))
        nvim-treesitter-textobjects
        nvim-web-devicons
        plenary-nvim
        popup-nvim
        rust-tools-nvim
        trouble-nvim
        vim-commentary
        vim-fugitive
        vim-lastplace
        vim-markdown
        vim-nix
        vim-surround
        vim-visual-multi
      ];
    };
    viAlias = true;
    vimAlias = true;
    withRuby = false;
  };
}
