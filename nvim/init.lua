-- Neovim 0.11.3 için init.lua (LSP + DAP + OSC52 + BasedPyright + Mason auto + Dracula Pro + Fidget + LazyDev + Noice)
-- Kaydet: ~/.config/nvim/init.lua

-- ================ Temel Ayarlar ================
vim.g.python3_host_prog = vim.fn.expand("$VIRTUAL_ENV") .. "/bin/python"
vim.opt.completeopt = "menu,menuone,noselect"
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.number = true
vim.opt.relativenumber = false
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.fillchars = { eob = " " }

-- Sağlayıcı maliyetlerini kapat
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- SSH ise: yerel pano için OSC52 (Neovim 0.11+)
if vim.env.SSH_TTY then
  local cb = vim.ui and vim.ui.clipboard
  if cb and type(cb.osc52) == "function" then
    vim.g.clipboard = cb.osc52()
  end
end

-- Leader
vim.g.mapleader = " "

-- ================ Lazy.nvim Bootstrap ================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
local uv = vim.uv
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git","--branch=stable",lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

-- ================ Yardımcılar ================
local function warn_if_no_node()
  if vim.fn.executable('node') == 0 then
    vim.schedule(function()
      vim.notify("NodeJS bulunamadı. HTML/CSS/TS LSP ve js-debug-adapter için gereklidir.", vim.log.levels.WARN)
    end)
  end
end

-- Proje sanal ortamı (Python) tespiti
local function project_python()
  local env = vim.env.VIRTUAL_ENV
  if env and #env > 0 then
    local p = env .. "/bin/python"
    if vim.fn.executable(p) == 1 then return p end
  end
  local fname = vim.api.nvim_buf_get_name(0)
  local start = (fname ~= "" and vim.fs.dirname(fname)) or uv.cwd()
  local markers = { ".venv/bin/python", "venv/bin/python", "ENV/bin/python" }
  for _, m in ipairs(markers) do
    local found = vim.fs.find(m, { path = start, upward = true })[1]
    if found and vim.fn.executable(found) == 1 then return found end
  end
  return nil
end

-- ================ Özel Dracula Pro (basit tema uygulama) ================
local function setup_dracula_pro()
  local colors = {
    bg='#22212c', fg='#f8f8f2', cursor='#f8f8f2', sel_bg='#454158',
    black='#22212c', black_b='#6272a4', red='#ff9580', red_b='#ffaa99',
    green='#8aff80', green_b='#a2ff99', yellow='#ffff80', yellow_b='#ffff99',
    blue='#9580ff', blue_b='#aa99ff', magenta='#ff80bf', magenta_b='#ff99cc',
    cyan='#80ffea', cyan_b='#99ffee', white='#f8f8f2', white_b='#ffffff'
  }
  vim.g.colors_name = "dracula-pro"
  vim.cmd('hi clear')
  if vim.fn.exists('syntax_on') == 1 then vim.cmd('syntax reset') end
  local hi = function(g,v) vim.api.nvim_set_hl(0,g,v) end
  hi("Normal",{fg=colors.fg,bg=colors.bg})
  hi("Cursor",{fg=colors.bg,bg=colors.cursor})
  hi("CursorLine",{bg=colors.sel_bg})
  hi("Visual",{bg=colors.sel_bg,fg=colors.fg})
  hi("Comment",{fg=colors.black_b})
  hi("Constant",{fg=colors.cyan})
  hi("String",{fg=colors.green})
  hi("Number",{fg=colors.yellow})
  hi("Boolean",{fg=colors.yellow})
  hi("Function",{fg=colors.blue})
  hi("Identifier",{fg=colors.red})
  hi("Statement",{fg=colors.red})
  hi("PreProc",{fg=colors.magenta})
  hi("Type",{fg=colors.yellow})
  hi("Special",{fg=colors.cyan})
  hi("Error",{fg=colors.red,bg=colors.black})
  hi("Todo",{fg=colors.white,bg=colors.yellow})
  hi("LineNr",{fg=colors.black_b,bg=colors.bg})
  hi("CursorLineNr",{fg=colors.yellow,bg=colors.sel_bg})
  hi("StatusLine",{fg=colors.fg,bg=colors.sel_bg,bold=true})
  hi("StatusLineNC",{fg=colors.black_b,bg=colors.bg})
  hi("VertSplit",{fg=colors.sel_bg,bg=colors.sel_bg})
  hi("Pmenu",{fg=colors.fg,bg=colors.sel_bg})
  hi("PmenuSel",{fg=colors.fg,bg=colors.blue})
  hi("MatchParen",{fg=colors.red,bg=colors.sel_bg})
  hi("DiagnosticError",{fg=colors.red})
  hi("DiagnosticWarn",{fg=colors.yellow})
  hi("DiagnosticInfo",{fg=colors.blue})
  hi("DiagnosticHint",{fg=colors.cyan})
end

-- ================ Eklentiler ================
require("lazy").setup({
  -- Tema
  { "dracula/vim", name = "dracula-pro", lazy = false, priority = 1000, config = setup_dracula_pro },

  -- Treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "rust","python","typescript","javascript","html","css","lua","vim","vimdoc",
          "toml","json","yaml","bash","regex","markdown","markdown_inline","query"
        },
        highlight = { enable = true, additional_vim_regex_highlighting = false },
        indent = { enable = true },
        auto_install = true,
      })
    end,
  },

  -- Simge ve ufak yardımcılar
  { "echasnovski/mini.nvim", version = false, config = function() require("mini.icons").setup() end },

  -- Mason (temel)
  { "williamboman/mason.nvim",
    config = function()
      require("mason").setup({ ui = { icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" } } })
      warn_if_no_node()
    end
  },

  -- mason-lspconfig (Sadece buranın ensure_installed'ı kullanılıyor)
  { "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "rust_analyzer","denols","basedpyright","ts_ls","html","cssls","lua_ls" },
        automatic_installation = true,
      })
    end
  },

  -- LSP
  { "neovim/nvim-lspconfig",
    dependencies = { "williamboman/mason.nvim", "williamboman/mason-lspconfig.nvim", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

      -- Ortak root tespiti yardımcısı
      local function root(patterns)
        return function(fname)
          local path = fname
          if not path or path == "" then path = vim.api.nvim_buf_get_name(0) end
          local found = vim.fs.find(patterns, { path = vim.fs.dirname(path), upward = true })[1]
          return found and vim.fs.dirname(found) or nil
        end
      end

      -- Rust
      lspconfig.rust_analyzer.setup({
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = true,
            check = { command = "clippy" },
            procMacro = { enable = true },
          },
        },
      })

      -- Python (BasedPyright)
      lspconfig.basedpyright.setup({
        capabilities = capabilities,
        settings = { basedpyright = { analysis = {
          typeCheckingMode = "standard",
          autoImportCompletions = true, autoSearchPaths = true, diagnosticMode = "workspace",
        } } },
      })

      -- Deno
      lspconfig.denols.setup({
        capabilities = capabilities,
        root_dir = root({ "deno.json", "deno.jsonc" }),
        init_options = { lint = true, unstable = true },
      })

      -- TS/JS (Node projeleri) — Deno köklerinde devre dışı
      lspconfig.ts_ls.setup({
        capabilities = capabilities,
        root_dir = function(fname)
          -- Deno projesi ise ts_ls devreye girmesin
          local deno_root = root({ "deno.json", "deno.jsonc" })(fname)
          if deno_root then return nil end
          return root({ "package.json", "tsconfig.json", "jsconfig.json" })(fname)
        end,
        single_file_support = false,
        settings = {
          typescript = { inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          }},
          javascript = { inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          }},
        },
      })

      -- HTML/CSS/Lua
      lspconfig.html.setup({ capabilities = capabilities, filetypes = { "html","templ" } })
      lspconfig.cssls.setup({ capabilities = capabilities, settings = {
        css = { validate = true, lint = { unknownAtRules = "ignore" } },
        scss = { validate = true, lint = { unknownAtRules = "ignore" } },
      }})

      local util = require("lspconfig.util")
      lspconfig.lua_ls.setup({
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = { library = vim.api.nvim_get_runtime_file("", true), checkThirdParty = false },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
        root_dir = function(fname)
          return util.root_pattern(".luarc.json", ".luarc.jsonc", ".stylua.toml", "stylua.toml", ".git")(fname)
              or (fname and vim.fs.dirname(fname))
              or (vim.uv and vim.uv.cwd() or vim.loop.cwd())
        end,
      }) 
    end
  },

  -- nvim-cmp + LuaSnip
  { "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp","hrsh7th/cmp-buffer","hrsh7th/cmp-path","hrsh7th/cmp-cmdline",
      { "L3MON4D3/LuaSnip", build = "make install_jsregexp", version = "v2.*" },
      "saadparwaiz1/cmp_luasnip","rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        window = { completion = cmp.config.window.bordered(), documentation = cmp.config.window.bordered() },
        preselect = cmp.PreselectMode.None, 
        completion = { completeopt = "menu,menuone,noselect" },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()  -- normal Enter (yeni satır)
            end
          end, { "i", "s" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i","s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i","s" }),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "luasnip" }, { name = "crates" } },
          { { name = "buffer" }, { name = "path" } }
        ),
        formatting = { format = function(entry, item)
          item.kind = string.format("%s", item.kind)
          item.menu = ({ nvim_lsp="[LSP]", luasnip="[Snip]", buffer="[Buf]", path="[Path]", crates="[Crates]" })[entry.source.name]
          return item
        end},
      })
      cmp.setup.cmdline({ "/","?" }, { mapping = cmp.mapping.preset.cmdline(), sources = { { name = "buffer" } } })
      cmp.setup.cmdline(":", { mapping = cmp.mapping.preset.cmdline(), sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }) })
    end
  },

  -- Nvim-tree
  { "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      vim.g.loaded_netrw, vim.g.loaded_netrwPlugin = 1, 1
      require("nvim-tree").setup({ view = { width = 30, side = "left" }, renderer = { group_empty = true } })
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { silent = true })
    end
  },

  -- Lualine (Dracula Pro uyumlu)
  { "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local theme = {
        normal = { a={bg='#9580ff',fg='#22212c',gui='bold'}, b={bg='#454158',fg='#f8f8f2'}, c={bg='#22212c',fg='#6272a4'} },
        insert = { a={bg='#8aff80',fg='#22212c',gui='bold'}, b={bg='#454158',fg='#f8f8f2'}, c={bg='#22212c',fg='#6272a4'} },
        visual = { a={bg='#ff80bf',fg='#22212c',gui='bold'}, b={bg='#454158',fg='#f8f8f2'}, c={bg='#22212c',fg='#6272a4'} },
        replace= { a={bg='#ff9580',fg='#22212c',gui='bold'}, b={bg='#454158',fg='#f8f8f2'}, c={bg='#22212c',fg='#6272a4'} },
        command= { a={bg='#ffff80',fg='#22212c',gui='bold'}, b={bg='#454158',fg='#f8f8f2'}, c={bg='#22212c',fg='#6272a4'} },
        inactive={ a={bg='#454158',fg='#6272a4'}, b={bg='#454158',fg='#6272a4'}, c={bg='#22212c',fg='#6272a4'} },
      }
      require("lualine").setup({
        options = { theme = theme, component_separators = { left = "", right = "" }, section_separators = { left = "", right = "" } },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { "filename" },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end
  },

  -- Telescope + FZF
  { "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
    config = function()
      local telescope = require("telescope")
      local builtin = require("telescope.builtin")
      telescope.setup({ defaults = { file_ignore_patterns = { "node_modules", ".git/" } }, extensions = { fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" } } })
      telescope.load_extension("fzf")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, {})
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, {})
      vim.keymap.set("n", "<leader>fb", builtin.buffers, {})
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, {})
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, {})
    end
  },

  -- Git
  { "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({
        signs = { add={text="│"}, change={text="│"}, delete={text="_"}, topdelete={text="‾"}, changedelete={text="~"}, untracked={text="┆"} },
        current_line_blame = false,
      })
    end
  },

  -- Autopairs
  { "windwp/nvim-autopairs", event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true })
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      local cmp = require("cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end
  },

  -- Yorum
  { "numToStr/Comment.nvim", config = function() require("Comment").setup() end },

  -- Renk gösterimi
  { "NvChad/nvim-colorizer.lua", config = function() require("colorizer").setup() end },

  -- crates.nvim
  { "saecki/crates.nvim", tag = "stable", event = { "BufRead Cargo.toml" }, dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({ completion = { cmp = { enabled = true } }, lsp = { enabled = true } })
    end
  },

  -- Indent kılavuzları
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", config = function() require("ibl").setup({ indent = { char = "│" }, scope = { enabled = true, show_start = true, show_end = false } }) end },

  -- Which-key
  { "folke/which-key.nvim", event = "VeryLazy",
    init = function() vim.o.timeout = true; vim.o.timeoutlen = 300 end,
    config = function()
      local wk = require("which-key")
      wk.setup({})
      if type(wk.add) == "function" then
        wk.add({
          { "<leader>e",  desc = "Dosya gezgini Aç/Kapa", mode = "n" },
          { "<leader>f",  group = "Bul / Telescope" },
          { "<leader>ff", desc = "Dosya bul",                 mode = "n" },
          { "<leader>fg", desc = "Metin ara (live grep)",     mode = "n" },
          { "<leader>fb", desc = "Açık buffer'lar",           mode = "n" },
          { "<leader>fh", desc = "Yardım etiketleri",         mode = "n" },
          { "<leader>fd", desc = "Tanılama listesi",          mode = "n" },
          { "g",          group = "Git/Goto" },
          { "gD",         desc = "Declaration'a git",         mode = "n" },
          { "gd",         desc = "Definition'a git",          mode = "n" },
          { "gi",         desc = "Implementation'a git",      mode = "n" },
          { "gr",         desc = "Referansları göster",       mode = "n" },
          { "K",          desc = "Hover (sembol bilgisi)",    mode = "n" },
          { "<leader>w",  group = "Workspace" },
          { "<leader>wa", desc = "Klasör ekle",               mode = "n" },
          { "<leader>wr", desc = "Klasör kaldır",             mode = "n" },
          { "<leader>wl", desc = "Klasörleri listele",        mode = "n" },
          { "<leader>D",  desc = "Tür tanımı",                mode = "n" },
          { "<leader>rn", desc = "Yeniden adlandır",          mode = "n" },
          { "<leader>ca", desc = "Kod eylemi",                mode = { "n","v" } },
          { "<leader>cf", desc = "Biçimlendir",               mode = "n" }, -- <leader>f çatışmasın
          { "<leader>ih", desc = "Inlay hints Aç/Kapa",       mode = "n" },
        })
      end
    end
  },

  -- ====== EK OPSİYONLAR ======
  -- LSP ilerleme
  { "j-hui/fidget.nvim", opts = {} },

  -- Lua geliştirme (vim.uv ipuçları vs.)
  { "folke/lazydev.nvim", ft = "lua", opts = { library = { { path = "luvit-meta/library", words = { "vim%.uv" } } } } },
  { "Bilal2453/luvit-meta", lazy = true },

  -- Bildirim ve gelişmiş komut/mesaj UI
  { "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({ stages = "fade", timeout = 2000, render = "compact" })
      vim.notify = notify
    end
  },
  { "folke/noice.nvim",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        cmdline = { enabled = true, view = "cmdline" },
        messages = { enabled = true },
        lsp = {
          progress = { enabled = false }, -- fidget gösteriyor
          hover = { enabled = true },
          signature = { enabled = true },
          documentation = { view = "hover" },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"] = true,
            ["cmp.entry.get_documentation"] = true,
          },
        },
        presets = { bottom_search = true, command_palette = true, long_message_to_split = true, lsp_doc_border = true },
      })
    end
  },

  -- ===================== DAP (Debug) =====================
  { "mfussenegger/nvim-dap" },
  { "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" }, config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"] = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"] = function() dapui.close() end
    end
  },
  { "theHamsta/nvim-dap-virtual-text", config = function() require("nvim-dap-virtual-text").setup() end },
  { "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy", "js-debug-adapter" },
        automatic_installation = true,
      })
    end
  },
  { "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
    config = function()
      local ok = pcall(require, "dap-vscode-js")
      if not ok then return end
      local dapjs = require("dap-vscode-js")
      local mason_pkg = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"
      if vim.fn.isdirectory(mason_pkg) == 0 then
        vim.notify("Mason: 'js-debug-adapter' kurulu değil. :MasonInstall js-debug-adapter", vim.log.levels.WARN)
        return
      end
      dapjs.setup({
        debugger_path = mason_pkg,
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
      })
      local dap = require("dap")
      for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[language] = {
          {
            type = "pwa-node",
            request = "launch",
            name = "Node: Launch {file}",
            program = "${file}",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "node",
            skipFiles = { "<node_internals>/**" },
          },
          {
            type = "pwa-node",
            request = "attach",
            name = "Node: Attach 9229",
            processId = require("dap.utils").pick_process,
            port = 9229,
            cwd = "${workspaceFolder}",
          },
          {
            type = "pwa-node",
            request = "launch",
            name = "Deno: Run {file}",
            program = "${file}",
            cwd = "${workspaceFolder}",
            runtimeExecutable = "deno",
            runtimeArgs = { "run", "--inspect-wait", "--allow-all", "${file}" },
            attachSimplePort = 9229,
          },
        }
      end
    end
  },
  { "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim" },
    config = function()
      local ok = pcall(require, "dap-python"); if not ok then return end
      local dappy = require("dap-python")
      local py = project_python()
      if not py then
        local mason_py = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
        if vim.fn.executable(mason_py) == 1 then py = mason_py end
      end
      if not py then py = "python3" end
      if py == "python3" then
        vim.notify("Python debug için: proje .venv veya Mason 'debugpy' yok. :MasonInstall debugpy ya da projenizin venv'ine 'pip install debugpy'.", vim.log.levels.WARN)
      end
      pcall(function() dappy.setup(py) end)
    end
  },
})

-- ================ LSP Kısayolları ================
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "<leader>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<leader>wl", function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end, opts)
    vim.keymap.set("n", "<leader>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    -- ÇATIŞMAYI ÖNLE: Format artık <leader>cf
    vim.keymap.set("n", "<leader>cf", function() vim.lsp.buf.format({ async = true }) end, opts)

    if vim.lsp.inlay_hint then
      local ih = vim.lsp.inlay_hint
      vim.keymap.set("n", "<leader>ih", function()
        local buf = ev.buf
        local enabled = ih.is_enabled and ih.is_enabled({ bufnr = buf })
        ih.enable(not enabled, { bufnr = buf })
      end, opts)
    end
  end,
})

-- ================ DAP Kısayolları ================
local dap_ok, dap = pcall(require, 'dap')
if dap_ok then
  vim.keymap.set('n', '<F5>',  function() dap.continue() end)
  vim.keymap.set('n', '<F10>', function() dap.step_over() end)
  vim.keymap.set('n', '<F11>', function() dap.step_into() end)
  vim.keymap.set('n', '<S-F11>', function() dap.step_out() end)
  vim.keymap.set('n', '<leader>b', function() dap.toggle_breakpoint() end)
  vim.keymap.set('n', '<leader>B', function() dap.set_breakpoint(vim.fn.input('Koşul: ')) end)
  vim.keymap.set('n', '<leader>dr', function() dap.repl.open() end)
  vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end)
end

-- ================ Teşhis (Diagnostics) ================
vim.diagnostic.config({
  virtual_text = true,
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.HINT]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
    },
  },
  underline = true,
  update_in_insert = false,
  severity_sort = true,
  float = { border = "rounded", source = "always" },
})
