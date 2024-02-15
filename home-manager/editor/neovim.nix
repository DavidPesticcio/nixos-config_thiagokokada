{ config, pkgs, lib, ... }:

let
  devCfg = config.home-manager.dev;
  cfg = config.home-manager.editor.neovim;
  toLuaBool = x: if x then "true" else "false";
in
{
  options.home-manager.editor.neovim = {
    enable = lib.mkEnableOption "Neovim config" // {
      default = config.home-manager.editor.enable;
    };
    # Do not forget to set 'Hack Nerd Mono Font' as the terminal font
    enableIcons = lib.mkEnableOption "icons" // {
      default = config.home-manager.desktop.enable || config.home-manager.darwin.enable;
    };
    enableLsp = lib.mkEnableOption "LSP" // {
      default = config.home-manager.dev.enable;
    };
    enableTreeSitter = lib.mkEnableOption "TreeSitter" // {
      default = config.home-manager.dev.enable;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fd
      ripgrep
    ]
    # For clipboard=unnamedplus
    ++ lib.optionals stdenv.isLinux [
      wl-clipboard
      xclip
    ]
    ++ lib.optionals cfg.enableIcons [
      config.home-manager.desktop.theme.fonts.symbols.package
    ];

    programs.neovim = {
      enable = true;
      defaultEditor = true;

      withRuby = false;
      withNodeJs = false;
      withPython3 = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraLuaConfig = /* lua */ ''
        -- general config

        -- reload unchanged files automatically
        vim.opt.autoread = true

        -- autoindent when starting a new line with 'o' or 'O'
        vim.opt.autoindent = true

        -- indent wrapped lines to match line start
        vim.opt.breakindent = true

        -- show line numbers
        vim.opt.number = true

        -- ignore case in search, except if using case
        vim.opt.ignorecase = true
        vim.opt.smartcase = true

        -- show search results while typing
        vim.opt.incsearch = true

        -- turn on omnicomplete
        vim.opt.omnifunc = "syntaxcomplete#Complete"

        -- live substitutions as you type
        vim.opt.inccommand = 'nosplit'

        -- copy and paste use the system clipboard
        vim.opt.clipboard:append { 'unnamedplus' }

        -- show vertical colum
        vim.opt.colorcolumn:append { 81, 121 }

        -- threat words-with-dash as a word
        vim.opt.iskeyword:append { '-' }

        -- avoid swapfile warning
        vim.opt.shortmess = 'A'

        -- persistent undo
        local undodir = vim.fn.expand('~/.config/nvim/undo')

        vim.opt.undofile = true
        vim.opt.undodir = undodir

        if vim.fn.isdirectory(undodir) ~= 0 then
          vim.fn.mkdir(undodir, "p", 0755)
        end

        -- disable "How to disable mouse" menu
        vim.cmd.aunmenu { [[PopUp.How-to\ disable\ mouse]] }
        vim.cmd.aunmenu { [[PopUp.-1-]] }

        -- window movement mappings
        vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]])
        vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]])
        vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]])
        vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]])
        vim.keymap.set('n', '<C-h>', '<C-w>h')
        vim.keymap.set('n', '<C-j>', '<C-w>j')
        vim.keymap.set('n', '<C-k>', '<C-w>k')
        vim.keymap.set('n', '<C-l>', '<C-w>l')
        vim.keymap.set({'i', 'v'}, '<C-h>', '<Esc><C-w>h')
        vim.keymap.set({'i', 'v'}, '<C-j>', '<Esc><C-w>j')
        vim.keymap.set({'i', 'v'}, '<C-k>', '<Esc><C-w>k')
        vim.keymap.set({'i', 'v'}, '<C-l>', '<Esc><C-w>l')

        -- make Esc enter Normal mode in Term
        vim.keymap.set('t', '<Esc>', [[<C-\><C-n>]])
        vim.keymap.set('t', '<M-[>', [[<C-\><C-n>]])
        vim.keymap.set('t', '<C-v><Esc>', [[<C-\><C-n>]])

        -- unsets the 'last search pattern'
        vim.keymap.set('n', '<C-g>', '<cmd>:noh<CR><CR>')

        -- completion
        vim.opt.completeopt = 'menu'
        vim.keymap.set('i', '<C-Space>', '<C-x><C-o>')
        vim.keymap.set({'i', 'c'}, '<C-j>', function()
          return vim.fn.pumvisible() ~= 0 and '<C-n>' or '<C-j>'
        end, { expr = true })
        vim.keymap.set({'i', 'c'}, '<C-k>', function()
          return vim.fn.pumvisible() ~= 0 and '<C-p>' or '<C-k>'
        end, { expr = true })
        -- the insert mode mapping for this one is done in vim-endwise
        vim.keymap.set('c', '<CR>', function()
          return vim.fn.pumvisible() ~= 0 and '<C-y>' or '<CR>'
        end, { expr = true })

        -- syntax highlight flake.lock files as json
        vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufRead' }, {
          pattern = 'flake.lock',
          command = 'set filetype=json',
        })

        -- keep comment leader when 'o' or 'O' is used in Normal mode
        vim.api.nvim_create_autocmd({ 'FileType' }, {
          pattern = '*',
          command = 'set formatoptions+=o',
        })
      '';

      # To install non-packaged plugins, use
      # pkgs.vimUtils.buildVimPlugin { }
      plugins = with pkgs; with vimPlugins; [
        {
          # FIXME: dummy plugin since there is no way currently to set a config
          # before the plugins are initialized
          # See: https://github.com/nix-community/home-manager/pull/2391
          plugin = pkgs.writeText "00-init-pre" "";
          config = /* vim */ ''
            " remap leader
            let g:mapleader = "\<Space>"
            let g:maplocalleader = ','
          '';
        }
        {
          plugin = vim-sneak;
          config = /* vim */ ''
            let g:sneak#label = 1
            map f <Plug>Sneak_f
            map F <Plug>Sneak_F
            map t <Plug>Sneak_t
            map T <Plug>Sneak_T
          '';
        }
        {
          plugin = vim-easy-align;
          config = /* vim */ ''
            " Start interactive EasyAlign in visual mode (e.g. vipga)
            xmap ga <Plug>(EasyAlign)

            " Start interactive EasyAlign for a motion/text object (e.g. gaip)
            nmap ga <Plug>(EasyAlign)
          '';
        }
        {
          plugin = pkgs.writeText "01-init-pre-lua" "";
          type = "lua";
          config = /* lua */ ''
            -- bytecompile lua modules
            vim.loader.enable()

            -- load .exrc, .nvimrc and .nvim.lua local files
            vim.o.exrc = true
          '';
        }
        {
          plugin = comment-nvim;
          type = "lua";
          config = /* lua */ ''
            require('Comment').setup {}
          '';
        }
        {
          plugin = gitsigns-nvim;
          type = "lua";
          config = /* lua */ ''
            require('gitsigns').setup {}
          '';
        }
        {
          plugin = lualine-nvim;
          type = "lua";
          # TODO: add support for trailing whitespace
          config = /* lua */ ''
            local enable_icons = ${toLuaBool cfg.enableIcons}

            require('lualine').setup {
              options = {
                icons_enabled = enable_icons,
              },
            }
          '';
        }
        {
          plugin = nvim-autopairs;
          type = "lua";
          config = /* lua */ ''
            local enable_ts = ${toLuaBool cfg.enableTreeSitter}

            require("nvim-autopairs").setup {
              check_ts = enable_ts
            }
          '';
        }
        {
          plugin = nvim-surround;
          type = "lua";
          config = /* lua */ ''
            require("nvim-surround").setup {}
          '';
        }
        {
          plugin = onedarkpro-nvim;
          type = "lua";
          config = /* lua */ ''
            vim.cmd.colorscheme("onedark")
          '';
        }
        {
          plugin = openingh-nvim;
          type = "lua";
          config = /* lua */ ''
            -- for repository page
            vim.keymap.set({'n', 'v'}, '<Leader>gr', ":OpenInGHRepo <CR>", { silent = true, desc = "Open in GitHub repo" })

            -- for current file page
            vim.keymap.set('n', '<Leader>gf', ":OpenInGHFile <CR>", { silent = true, desc = "Open in GitHub file" })
            vim.keymap.set('v', '<Leader>gf', ":OpenInGHFileLines <CR>", { silent = true, desc = "Open in GitHub lines" })
          '';
        }
        {
          plugin = project-nvim;
          type = "lua";
          config = /* lua */ ''
            require('project_nvim').setup {}
            vim.keymap.set(
              'n',
              '<Leader>p',
              ":Telescope projects<CR>",
              { desc = "Projects" }
            )
          '';
        }
        {
          plugin = remember-nvim;
          type = "lua";
          config = /* lua */ ''
            require('remember').setup {}
          '';
        }
        {
          plugin = telescope-nvim;
          type = "lua";
          config = /* lua */ ''
            local actions = require('telescope.actions')
            local telescope = require('telescope')
            telescope.setup {
              defaults = {
                mappings = {
                  i = {
                    ["<C-j>"] = actions.move_selection_next,
                    ["<C-k>"] = actions.move_selection_previous,
                  },
                },
                -- ivy-like theme
                layout_strategy = 'bottom_pane',
                layout_config = {
                  height = 0.4,
                },
                border = true,
                sorting_strategy = "ascending",
                preview = {
                  -- set timeout low enough that it never feels too slow
                  timeout = 50,
                },
                -- configure to use ripgrep
                vimgrep_arguments = {
                  "${lib.getExe pkgs.ripgrep}",
                  "--follow",        -- Follow symbolic links
                  "--hidden",        -- Search for hidden files
                  "--no-heading",    -- Don't group matches by each file
                  "--with-filename", -- Print the file path with the matched lines
                  "--line-number",   -- Show line numbers
                  "--column",        -- Show column numbers
                  "--smart-case",    -- Smart case search

                  -- Exclude some patterns from search
                  "--glob=!**/.git/*",
                  "--glob=!**/.idea/*",
                  "--glob=!**/.vscode/*",
                },
              },
              pickers = {
                find_files = {
                  hidden = true,
                  -- needed to exclude some files & dirs from general search
                  -- when not included or specified in .gitignore
                  find_command = {
                    "${lib.getExe pkgs.ripgrep}",
                    "--files",
                    "--hidden",
                    "--glob=!**/.git/*",
                    "--glob=!**/.idea/*",
                    "--glob=!**/.vscode/*",
                  },
                },
              },
              extensions = {
                undo = {
                  mappings = {
                    i = {
                      ["<cr>"] = require("telescope-undo.actions").restore,
                      ["<S-cr>"] = require("telescope-undo.actions").yank_deletions,
                      ["<C-cr>"] = require("telescope-undo.actions").yank_additions,
                      ["<C-y>"] = require("telescope-undo.actions").yank_deletions,
                      ["<C-r>"] = require("telescope-undo.actions").restore,
                    },
                    n = {
                      ["u"] = require("telescope-undo.actions").restore,
                      ["y"] = require("telescope-undo.actions").yank_additions,
                      ["Y"] = require("telescope-undo.actions").yank_deletions,
                    },
                  },
                },
              },
            }
            telescope.load_extension('fzf')
            telescope.load_extension('projects')
            telescope.load_extension('ui-select')
            telescope.load_extension('file_browser')
            telescope.load_extension('undo')

            local builtin = require('telescope.builtin')
            vim.keymap.set('n', '<Leader><Leader>', builtin.find_files, { desc = "Find files" })
            vim.keymap.set('n', '<Leader>/', builtin.live_grep, { desc = "Live grep" })
            vim.keymap.set({'n', 'v'}, '<Leader>*', builtin.grep_string, { desc = "Grep string" })
            vim.keymap.set('n', '-', function()
              telescope.extensions.file_browser.file_browser({
                path = "%:p:h",
                select_buffer = true,
                initial_mode = "normal",
                layout_config = { height = 100 },
              })
            end, { desc = "File browser" })
            vim.keymap.set('n', '<Leader>u', telescope.extensions.undo.undo , { desc = "Undo" })
          '';
        }
        {
          plugin = vim-endwise;
          type = "lua";
          config = /* lua */ ''
            vim.g.endwise_no_mappings = 1

            vim.keymap.set('i', '<CR>', function()
              return vim.fn.pumvisible() ~= 0 and '<C-y>' or vim.fn.EndwiseAppend(
                vim.api.nvim_replace_termcodes('<CR>', true, true, true)
              )
            end, { expr = true })
          '';
        }
        {
          plugin = vim-test;
          type = "lua";
          config = /* lua */ ''
            vim.g["test#strategy"] = "neovim"
            vim.g["test#neovim#start_normal"] = 1
            vim.g["test#neovim#term_position"] = "vert botright"

            vim.keymap.set('n', '<Leader>tt', ':TestNearest<CR>', { desc = "Test nearest" })
            vim.keymap.set('n', '<Leader>tT', ':TestFile<CR>', { desc = "Test file" })
            vim.keymap.set('n', '<Leader>ts', ':TestSuite<CR>', { desc = "Test suite" })
            vim.keymap.set('n', '<Leader>tl', ':TestLast<CR>', { desc = "Test last" })
            vim.keymap.set('n', '<Leader>tv', ':TestVisit<CR>', { desc = "Test visit" })
          '';
        }
        {
          plugin = which-key-nvim;
          type = "lua";
          config = /* lua */ ''
            vim.o.timeout = true
            vim.o.timeoutlen = 300
            require("which-key").setup {}
          '';
        }
        {
          plugin = whitespace-nvim;
          type = "lua";
          config = /* lua */ ''
            require('whitespace-nvim').setup {
              -- configuration options and their defaults

              -- `highlight` configures which highlight is used to display
              -- trailing whitespace
              highlight = 'DiffDelete',

              -- `ignored_filetypes` configures which filetypes to ignore when
              -- displaying trailing whitespace
              ignored_filetypes = { 'TelescopePrompt', 'Trouble', 'help' },

              -- `ignore_terminal` configures whether to ignore terminal buffers
              ignore_terminal = true,
            }

            -- remove trailing whitespace with a keybinding
            vim.keymap.set(
              'n',
              '<Leader>w',
              require('whitespace-nvim').trim,
              { desc = "Trim whitespace" }
            )
          '';
        }
        mkdir-nvim
        telescope-file-browser-nvim
        telescope-fzf-native-nvim
        telescope-ui-select-nvim
        telescope-undo-nvim
        vim-advanced-sorters
        vim-fugitive
        vim-sleuth
      ]
      ++ lib.optionals cfg.enableLsp [
        {
          plugin = nvim-lspconfig;
          type = "lua";
          config = /* lua */ ''
            -- Setup language servers.
            -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md
            local lspconfig = require('lspconfig')

            ${lib.optionalString devCfg.enable /* lua */ ''
              lspconfig.bashls.setup {}
              lspconfig.marksman.setup {}
            ''}
            ${lib.optionalString devCfg.nix.enable /* lua */ ''
              lspconfig.nil_ls.setup {
                settings = {
                  ['nil'] = {
                    formatting = {
                      command = { "nixpkgs-fmt" },
                    },
                    nix = {
                      flake = {
                        autoArchive = false,
                      },
                    },
                  },
                },
              }
            ''}
            ${lib.optionalString devCfg.clojure.enable /* lua */ ''
              lspconfig.clojure_lsp.setup {}
            ''}
            ${lib.optionalString devCfg.go.enable /* lua */ ''
              lspconfig.gopls.setup {}
            ''}
            ${lib.optionalString devCfg.python.enable /* lua */ ''
              lspconfig.pyright.setup {}
              lspconfig.ruff_lsp.setup {}
            ''}
            ${lib.optionalString devCfg.node.enable /* lua */''
              lspconfig.cssls.setup {}
              lspconfig.eslint.setup {}
              lspconfig.html.setup {}
              lspconfig.jsonls.setup {}
            ''}

            local builtin = require('telescope.builtin')

            -- Global mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            vim.keymap.set('n', '<space>ld', builtin.diagnostics, { desc = "LSP diagnostics" })

            -- Use LspAttach autocommand to only map the following keys
            -- after the language server attaches to the current buffer
            vim.api.nvim_create_autocmd('LspAttach', {
              group = vim.api.nvim_create_augroup('UserLspConfig', {}),
              callback = function(ev)
                -- Enable completion triggered by <c-x><c-o>
                vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

                -- Buffer local mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                vim.keymap.set('n', 'gD', builtin.lsp_references, { buffer = ev.buf, desc = "LSP references" })
                vim.keymap.set('n', 'gd', builtin.lsp_definitions, { buffer = ev.buf, desc = "LSP definitions" })
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = ev.buf, desc = "LSP symbol under" })
                vim.keymap.set('n', 'gi', builtin.lsp_implementations, { buffer = ev.buf, desc = "LSP implementations" })
                vim.keymap.set('n', '<Leader>ls', vim.lsp.buf.signature_help, { buffer = ev.buf, desc = "LSP signature help" })
                vim.keymap.set('n', '<Leader>lwa', vim.lsp.buf.add_workspace_folder, { buffer = ev.buf, desc = "LSP add workspace" })
                vim.keymap.set('n', '<Leader>lwr', vim.lsp.buf.remove_workspace_folder, { buffer = ev.buf, desc = "LSP remove workspace" })
                vim.keymap.set('n', '<Leader>lwl', function()
                  print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, { buffer = ev.buf, desc = "LSP list workspaces" })
                vim.keymap.set('n', '<Leader>lt', builtin.lsp_type_definitions, { buffer = ev.buf, desc = "LSP type definitions" })
                vim.keymap.set('n', '<Leader>lr', vim.lsp.buf.rename, { buffer = ev.buf, desc = "LSP rename" })
                vim.keymap.set({ 'n', 'v' }, '<Leader>la', vim.lsp.buf.code_action, { buffer = ev.buf, desc = "LSP code action" })
                vim.keymap.set('n', '<Leader>f', function()
                  vim.lsp.buf.format { async = true }
                end, { buffer = ev.buf, desc = "LSP format" })
              end,
            })
          '';
        }
      ]
      ++ lib.optionals cfg.enableTreeSitter [
        {
          plugin = nvim-treesitter.withAllGrammars;
          type = "lua";
          config = /* lua */ ''
            require('nvim-treesitter.configs').setup {
              highlight = {
                enable = true,
                -- disable slow treesitter highlight for large files
                disable = function(lang, buf)
                    local max_filesize = 100 * 1024 -- 100 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                    if ok and stats and stats.size > max_filesize then
                        return true
                    end
                end,
              },
              incremental_selection = {
                enable = true,
                keymaps = {
                  init_selection = "gnn", -- set to `false` to disable one of the mappings
                  node_incremental = "grn",
                  scope_incremental = "grc",
                  node_decremental = "grm",
                },
              },
              indent = {
                enable = true,
              },
              autotag = {
                enable = true,
              },
              textobjects = {
                select = {
                  enable = true,

                  -- Automatically jump forward to textobj, similar to targets.vim
                  lookahead = true,

                  keymaps = {
                    ["af"] = { query = "@function.outer", desc = "Select outer part of a function region" },
                    ["if"] = { query = "@function.inner", desc = "Select inner part of a function region" },
                    ["ac"] = { query = "@class.outer", desc = "Select outer part of a class region" },
                    ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                    ["as"] = { query = "@scope", query_group = "locals", desc = "Select language scope" },
                  },

                  -- You can choose the select mode (default is charwise 'v')
                  selection_modes = {
                    ['@parameter.outer'] = 'v', -- charwise
                    ['@function.outer'] = 'V', -- linewise
                    ['@class.outer'] = '<c-v>', -- blockwise
                  },

                  -- If you set this to `true` (default is `false`) then any textobject is
                  -- extended to include preceding or succeeding whitespace. Succeeding
                  -- whitespace has priority in order to act similarly to eg the built-in
                  -- `ap`.
                  include_surrounding_whitespace = false,
                },
                swap = {
                  enable = true,
                  swap_next = {
                    ["<leader>a"] = { query = "@parameter.inner", desc = "Swap parameter with next" },
                  },
                  swap_previous = {
                    ["<leader>A"] = { query = "@parameter.inner", desc = "Swap parameter with previous" },
                  },
                },
                move = {
                  enable = true,
                  set_jumps = true, -- whether to set jumps in the jumplist
                  goto_next_start = {
                    ["]m"] = { query = "@function.outer", desc = "Next function start" },
                    ["]]"] = { query = "@class.outer", desc = "Next class start" },
                  },
                  goto_next_end = {
                    ["]M"] = { query = "@function.outer", desc = "Next function end" },
                    ["]["] = { query = "@class.outer", desc = "Next class end" },
                  },
                  goto_previous_start = {
                    ["[m"] = { query = "@function.outer", desc = "Previous function start" },
                    ["[["] = { query = "@class.outer", desc = "Previous class start" },
                  },
                  goto_previous_end = {
                    ["[M"] = { query = "@function.outer", desc = "Previous function end" },
                    ["[]"] = { query = "@class.outer", desc = "Previous class end" },
                  },
                  -- Below will go to either the start or the end, whichever is closer.
                  goto_next = {
                    ["]d"] = "@conditional.outer",
                  },
                  goto_previous = {
                    ["[d"] = "@conditional.outer",
                  }
                },
              },
            }
          '';
        }
        {
          plugin = nvim-treesitter-textobjects;
          type = "lua";
          config = /* lua */ ''
            -- most config is in nvim-treesitter itself
            local ts_repeat_move = require("nvim-treesitter.textobjects.repeatable_move")

            -- vim way: ; goes to the direction you were moving.
            vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move)
            vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_opposite)
          '';
        }
        nvim-ts-autotag
      ]
      ++ lib.optionals cfg.enableIcons [
        nvim-web-devicons
      ];
    };

    xdg.desktopEntries.nvim = lib.mkIf config.home-manager.desktop.enable {
      name = "Neovim";
      genericName = "Text Editor";
      comment = "Edit text files";
      exec = "nvim %F";
      icon = "nvim";
      mimeType = [
        "application/x-shellscript"
        "text/english"
        "text/plain"
        "text/x-c"
        "text/x-c++"
        "text/x-c++hdr"
        "text/x-c++src"
        "text/x-chdr"
        "text/x-csrc"
        "text/x-java"
        "text/x-makefile"
        "text/x-moc"
        "text/x-pascal"
        "text/x-tcl"
        "text/x-tex"
      ];
      terminal = true;
      type = "Application";
      categories = [ "Utility" "TextEditor" ];
    };
  };
}
