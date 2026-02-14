-- ╔══════════════════════════════════════════════════════════════════╗
-- ║  Neovim 0.11.3 — init.lua                                     ║
-- ║  Diller: Rust · Python · TypeScript · HTML · CSS · SQL         ║
-- ║  Kaydet: ~/.config/nvim/init.lua                               ║
-- ╚══════════════════════════════════════════════════════════════════╝

---@diagnostic disable: undefined-field

-- ━━━━━━━━━━━━━━━━━━  TEMEL AYARLAR  ━━━━━━━━━━━━━━━━━━
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Python host: önce aktif VIRTUAL_ENV, yoksa Neovim için kalıcı venv
local function is_exec(p)
  return p and #p > 0 and vim.fn.executable(p) == 1
end

local venv = vim.env.VIRTUAL_ENV
local venv_py = venv and (venv .. "/bin/python") or nil

local nvim_py = vim.fn.expand("~/.local/share/nvim/py3/bin/python")

if is_exec(venv_py) then
  vim.g.python3_host_prog = venv_py
elseif is_exec(nvim_py) then
  vim.g.python3_host_prog = nvim_py
end

-- Kullanılmayan provider'ları kapat
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local opt = vim.opt
opt.number         = true
opt.relativenumber = true
opt.tabstop        = 2
opt.shiftwidth     = 2
opt.expandtab      = true
opt.smartindent    = true
opt.wrap           = false
opt.swapfile       = false
opt.backup         = false
opt.undofile       = true
opt.hlsearch       = false
opt.incsearch      = true
opt.termguicolors  = true
opt.scrolloff      = 8
opt.sidescrolloff  = 8
opt.signcolumn     = "yes"
opt.updatetime     = 50
opt.colorcolumn    = "100"
opt.mouse          = "a"
opt.clipboard      = "unnamedplus"
opt.completeopt    = "menu,menuone,noselect"
opt.splitright     = true
opt.splitbelow     = true
opt.cursorline     = true
opt.fillchars      = { eob = " " }
opt.showmode       = false   -- lualine zaten gösteriyor

-- SSH ise: OSC52 pano desteği (Neovim 0.11+)
if vim.env.SSH_TTY then
  local ok, osc52 = pcall(function() return vim.ui.clipboard.osc52 end)
  if ok and type(osc52) == "function" then
    vim.g.clipboard = osc52()
  end
end

-- ━━━━━━━━━━━━━━━━━━  YARDIMCILAR  ━━━━━━━━━━━━━━━━━━
local uv = vim.uv

-- Proje sanal ortamı (Python) tespiti
local function project_python()
  local env = vim.env.VIRTUAL_ENV
  if env and #env > 0 then
    local p = env .. "/bin/python"
    if vim.fn.executable(p) == 1 then return p end
  end
  local fname = vim.api.nvim_buf_get_name(0)
  local start = (fname ~= "" and vim.fs.dirname(fname)) or uv.cwd()
  for _, m in ipairs({ ".venv/bin/python", "venv/bin/python", "ENV/bin/python" }) do
    local found = vim.fs.find(m, { path = start, upward = true })[1]
    if found and vim.fn.executable(found) == 1 then return found end
  end
  return nil
end

-- ━━━━━━━━━━━━━━━  LAZY.NVIM BOOTSTRAP  ━━━━━━━━━━━━━━━
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath,
  })
end
opt.rtp:prepend(lazypath)

-- ━━━━━━━━━━━━━━  DRACULA PRO TEMA  ━━━━━━━━━━━━━━━━━━
local function setup_dracula_pro()
  local c = {
    bg       = "#22212c", fg      = "#f8f8f2", sel     = "#454158",
    comment  = "#6272a4", red     = "#ff9580", green   = "#8aff80",
    yellow   = "#ffff80", blue    = "#9580ff", magenta = "#ff80bf",
    cyan     = "#80ffea", white_b = "#ffffff",
  }
  vim.g.colors_name = "dracula-pro"
  vim.cmd("hi clear")
  if vim.fn.exists("syntax_on") == 1 then vim.cmd("syntax reset") end

  local hi = function(g, v) vim.api.nvim_set_hl(0, g, v) end

  -- Temel UI
  hi("Normal",       { fg = c.fg,      bg = c.bg })
  hi("NormalFloat",  { fg = c.fg,      bg = c.bg })
  hi("FloatBorder",  { fg = c.blue,    bg = c.bg })
  hi("Cursor",       { fg = c.bg,      bg = c.fg })
  hi("CursorLine",   { bg = c.sel })
  hi("CursorLineNr", { fg = c.yellow,  bg = c.sel })
  hi("Visual",       { bg = c.sel })
  hi("LineNr",       { fg = c.comment, bg = c.bg })
  hi("SignColumn",   { bg = c.bg })
  hi("StatusLine",   { fg = c.fg,      bg = c.sel,     bold = true })
  hi("StatusLineNC", { fg = c.comment, bg = c.bg })
  hi("VertSplit",    { fg = c.sel,     bg = c.sel })
  hi("WinSeparator", { fg = c.sel })
  hi("Pmenu",        { fg = c.fg,      bg = c.sel })
  hi("PmenuSel",     { fg = c.fg,      bg = c.blue })
  hi("MatchParen",   { fg = c.red,     bg = c.sel })

  -- Sözdizimi
  hi("Comment",    { fg = c.comment, italic = true })
  hi("Constant",   { fg = c.cyan })
  hi("String",     { fg = c.green })
  hi("Number",     { fg = c.yellow })
  hi("Boolean",    { fg = c.yellow })
  hi("Function",   { fg = c.blue })
  hi("Identifier", { fg = c.red })
  hi("Statement",  { fg = c.red })
  hi("PreProc",    { fg = c.magenta })
  hi("Type",       { fg = c.yellow })
  hi("Special",    { fg = c.cyan })
  hi("Error",      { fg = c.red,    bg = c.bg })
  hi("Todo",       { fg = c.bg,     bg = c.yellow, bold = true })

  -- Treesitter
  hi("@variable",       { fg = c.fg })
  hi("@function",       { fg = c.blue })
  hi("@keyword",        { fg = c.red })
  hi("@string",         { fg = c.green })
  hi("@type",           { fg = c.yellow })
  hi("@constant",       { fg = c.cyan })
  hi("@comment",        { fg = c.comment, italic = true })
  hi("@punctuation",    { fg = c.fg })
  hi("@operator",       { fg = c.magenta })
  hi("@property",       { fg = c.fg })
  hi("@parameter",      { fg = c.fg, italic = true })
  hi("@tag",            { fg = c.red })
  hi("@tag.attribute",  { fg = c.blue })
  hi("@tag.delimiter",  { fg = c.fg })

  -- Tanılama
  hi("DiagnosticError", { fg = c.red })
  hi("DiagnosticWarn",  { fg = c.yellow })
  hi("DiagnosticInfo",  { fg = c.blue })
  hi("DiagnosticHint",  { fg = c.cyan })
  hi("DiagnosticUnderlineError", { undercurl = true, sp = c.red })
  hi("DiagnosticUnderlineWarn",  { undercurl = true, sp = c.yellow })
  hi("DiagnosticUnderlineInfo",  { undercurl = true, sp = c.blue })
  hi("DiagnosticUnderlineHint",  { undercurl = true, sp = c.cyan })

  -- Telescope
  hi("TelescopeBorder",        { fg = c.blue,    bg = c.bg })
  hi("TelescopePromptBorder",  { fg = c.blue,    bg = c.bg })
  hi("TelescopeResultsBorder", { fg = c.blue,    bg = c.bg })
  hi("TelescopePreviewBorder", { fg = c.blue,    bg = c.bg })
  hi("TelescopeTitle",         { fg = c.magenta, bold = true })

  -- Git Signs
  hi("GitSignsAdd",    { fg = c.green })
  hi("GitSignsChange", { fg = c.yellow })
  hi("GitSignsDelete", { fg = c.red })

  -- Indent guides
  hi("IblIndent", { fg = "#333245" })
  hi("IblScope",  { fg = c.blue })
end

-- ━━━━━━━━━━━━━━━━━━  EKLENTİLER  ━━━━━━━━━━━━━━━━━━━━
require("lazy").setup({

  -- ── Tema ──────────────────────────────────────────
  {
    "dracula/vim",
    name = "dracula-pro",
    lazy = false,
    priority = 1000,
    config = setup_dracula_pro,
  },

  -- ── Treesitter (YENİ main branch API) ─────────────
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    build = ":TSUpdate",
    lazy = false,
    config = function()
      require("nvim-treesitter").setup({
        ensure_installed = {
          -- Proje dilleri
          "rust", "python", "typescript", "tsx", "javascript", "html", "css", "sql",
          -- Genel / config
          "lua", "vim", "vimdoc", "toml", "json", "yaml",
          -- Noice.nvim için gerekli
          "bash", "regex", "markdown", "markdown_inline", "query",
        },
      })
      -- Tüm dosya türlerinde highlight + indent etkinleştir
      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("TreesitterStart", { clear = true }),
        pattern = "*",
        callback = function(ev)
          pcall(vim.treesitter.start, ev.buf)
          vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- ── Simgeler ──────────────────────────────────────
  { "nvim-tree/nvim-web-devicons", lazy = true },
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function() require("mini.icons").setup() end,
  },

  -- ── Mason v2 (paket yöneticisi) ──────────────────
  {
    "mason-org/mason.nvim",
    opts = {
      ui = {
        icons = { package_installed = "✓", package_pending = "➜", package_uninstalled = "✗" },
      },
    },
  },

  -- ── Mason-LSPConfig v2 ───────────────────────────
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = {
        "rust_analyzer",  -- Rust
        "basedpyright",   -- Python
        "ts_ls",          -- TypeScript / JavaScript
        "html",           -- HTML
        "cssls",          -- CSS
        "lua_ls",         -- Lua (Neovim config)
        "sqls",           -- SQL
      },
      automatic_enable = true,
    },
  },

  -- ── nvim-lspconfig (sunucu ayarları) ─────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = { "mason-org/mason.nvim", "mason-org/mason-lspconfig.nvim" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- ─ Rust ─
      vim.lsp.config("rust_analyzer", {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            cargo = { allFeatures = true },
            checkOnSave = true,
            check = { command = "clippy" },
            procMacro = { enable = true },
            inlayHints = { enable = true },
          },
        },
      })

      -- ─ Python (BasedPyright) ─
      vim.lsp.config("basedpyright", {
        capabilities = capabilities,
        before_init = function(_, config)
          local py = project_python()
          if py then
            config.settings = config.settings or {}
            config.settings.python = { pythonPath = py }
          end
        end,
        settings = {
          basedpyright = {
            analysis = {
              typeCheckingMode = "standard",
              autoImportCompletions = true,
              autoSearchPaths = true,
              diagnosticMode = "workspace",
            },
          },
        },
      })

      -- ─ TypeScript / JavaScript ─
      vim.lsp.config("ts_ls", {
        capabilities = capabilities,
        root_markers = { "package.json", "tsconfig.json", "jsconfig.json" },
        single_file_support = false,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      })

      -- ─ HTML ─
      vim.lsp.config("html", {
        capabilities = capabilities,
        filetypes = { "html", "templ" },
      })

      -- ─ CSS ─
      vim.lsp.config("cssls", {
        capabilities = capabilities,
        settings = {
          css  = { validate = true, lint = { unknownAtRules = "ignore" } },
          scss = { validate = true, lint = { unknownAtRules = "ignore" } },
          less = { validate = true, lint = { unknownAtRules = "ignore" } },
        },
      })

      -- ─ Lua ─
      vim.lsp.config("lua_ls", {
        capabilities = capabilities,
        settings = {
          Lua = {
            runtime = { version = "LuaJIT" },
            diagnostics = { globals = { "vim" } },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              checkThirdParty = false,
            },
            telemetry = { enable = false },
            hint = { enable = true },
          },
        },
      })

      -- ─ SQL ─
      vim.lsp.config("sqls", {
        capabilities = capabilities,
      })
    end,
  },

  -- ── nvim-cmp + LuaSnip ──────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      { "L3MON4D3/LuaSnip", build = "make install_jsregexp", version = "v2.*" },
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        preselect = cmp.PreselectMode.None,
        completion = { completeopt = "menu,menuone,noselect" },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"]     = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]     = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]     = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping(function(fallback)
            if cmp.visible() and cmp.get_selected_entry() then
              cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = false })
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources(
          { { name = "nvim_lsp" }, { name = "luasnip" }, { name = "crates" } },
          { { name = "buffer" }, { name = "path" } }
        ),
        formatting = {
          format = function(entry, item)
            local icons = {
              Text = "󰉿", Method = "󰆧", Function = "󰊕", Constructor = "",
              Field = "󰜢", Variable = "󰀫", Class = "󰠱", Interface = "",
              Module = "", Property = "󰜢", Unit = "󰑭", Value = "󰎠",
              Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
              File = "󰈙", Reference = "󰈇", Folder = "󰉋", EnumMember = "",
              Constant = "󰏿", Struct = "󰙅", Event = "", Operator = "󰆕",
              TypeParameter = "",
            }
            item.kind = string.format("%s %s", icons[item.kind] or "", item.kind)
            item.menu = ({
              nvim_lsp = "[LSP]", luasnip = "[Snip]", buffer = "[Buf]",
              path = "[Path]", crates = "[Crate]",
            })[entry.source.name]
            return item
          end,
        },
      })

      cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = { { name = "buffer" } },
      })
      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
      })
    end,
  },

  -- ── Nvim-tree ────────────────────────────────────
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("nvim-tree").setup({
        view = { width = 30, side = "left" },
        renderer = { group_empty = true, icons = { show = { git = true } } },
        filters = { dotfiles = false },
        git = { enable = true },
      })
    end,
  },

  -- ── Lualine ──────────────────────────────────────
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local theme = {
        normal   = { a = { bg = "#9580ff", fg = "#22212c", gui = "bold" }, b = { bg = "#454158", fg = "#f8f8f2" }, c = { bg = "#22212c", fg = "#6272a4" } },
        insert   = { a = { bg = "#8aff80", fg = "#22212c", gui = "bold" }, b = { bg = "#454158", fg = "#f8f8f2" }, c = { bg = "#22212c", fg = "#6272a4" } },
        visual   = { a = { bg = "#ff80bf", fg = "#22212c", gui = "bold" }, b = { bg = "#454158", fg = "#f8f8f2" }, c = { bg = "#22212c", fg = "#6272a4" } },
        replace  = { a = { bg = "#ff9580", fg = "#22212c", gui = "bold" }, b = { bg = "#454158", fg = "#f8f8f2" }, c = { bg = "#22212c", fg = "#6272a4" } },
        command  = { a = { bg = "#ffff80", fg = "#22212c", gui = "bold" }, b = { bg = "#454158", fg = "#f8f8f2" }, c = { bg = "#22212c", fg = "#6272a4" } },
        inactive = { a = { bg = "#454158", fg = "#6272a4" }, b = { bg = "#454158", fg = "#6272a4" }, c = { bg = "#22212c", fg = "#6272a4" } },
      }
      require("lualine").setup({
        options = {
          theme = theme,
          component_separators = { left = "", right = "" },
          section_separators   = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff", "diagnostics" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  -- ── Telescope ────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.8",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    config = function()
      local telescope = require("telescope")
      telescope.setup({
        defaults = {
          file_ignore_patterns = { "node_modules", ".git/", "__pycache__", "target/" },
          layout_strategy = "horizontal",
          layout_config = { prompt_position = "top" },
          sorting_strategy = "ascending",
        },
        extensions = {
          fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case" },
        },
      })
      telescope.load_extension("fzf")
    end,
  },

  -- ── Git ──────────────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPre",
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "│" },
          change       = { text = "│" },
          delete       = { text = "_" },
          topdelete    = { text = "‾" },
          changedelete = { text = "~" },
          untracked    = { text = "┆" },
        },
        current_line_blame = false,
      })
    end,
  },

  -- ── Autopairs ────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true })
      require("cmp").event:on("confirm_done", require("nvim-autopairs.completion.cmp").on_confirm_done())
    end,
  },

  -- ── Yorum ────────────────────────────────────────
  { "numToStr/Comment.nvim", event = "BufReadPost", config = function() require("Comment").setup() end },

  -- ── Renk gösterimi ───────────────────────────────
  { "NvChad/nvim-colorizer.lua", event = "BufReadPost", config = function() require("colorizer").setup() end },

  -- ── crates.nvim (Cargo.toml desteği) ─────────────
  {
    "saecki/crates.nvim",
    tag = "stable",
    event = "BufRead Cargo.toml",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("crates").setup({ completion = { cmp = { enabled = true } }, lsp = { enabled = true } })
    end,
  },

  -- ── Indent kılavuzları ───────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufReadPost",
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope = { enabled = true, show_start = true, show_end = false },
      })
    end,
  },

  -- ── Fidget (LSP ilerleme) ────────────────────────
  {
    "j-hui/fidget.nvim",
    event = "LspAttach",
    opts = {
      notification = {
        window = { winblend = 0, align = "bottom", avoid = { "NvimTree" } },
      },
    },
  },

  -- ── Lua geliştirme (vim.uv tür ipuçları) ────────
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },

  -- ── Bildirim sistemi ─────────────────────────────
  {
    "rcarriga/nvim-notify",
    config = function()
      local notify = require("notify")
      notify.setup({ stages = "fade", timeout = 2000, render = "compact" })
      vim.notify = notify
    end,
  },

  -- ── Noice (gelişmiş UI) ──────────────────────────
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({
        cmdline  = { enabled = true, view = "cmdline" },
        messages = { enabled = true },
        lsp = {
          progress      = { enabled = false },
          hover         = { enabled = true },
          signature     = { enabled = true },
          documentation = { view = "hover" },
          override = {
            ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
            ["vim.lsp.util.stylize_markdown"]                = true,
            ["cmp.entry.get_documentation"]                  = true,
          },
        },
        presets = {
          bottom_search         = true,
          command_palette       = true,
          long_message_to_split = true,
          lsp_doc_border        = true,
        },
      })
    end,
  },

  -- ── Which-key ────────────────────────────────────
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 400
    end,
    config = function()
      local wk = require("which-key")
      wk.setup({ delay = 300 })
      wk.add({
        { "<leader>f",  group = "Bul (Telescope)" },
        { "<leader>g",  group = "Git" },
        { "<leader>l",  group = "LSP" },
        { "<leader>d",  group = "Debug (DAP)" },
        { "<leader>w",  group = "Pencere" },
        { "<leader>b",  group = "Buffer" },
        { "<leader>t",  group = "Aç / Kapa" },
      })
    end,
  },

  -- ── DAP (Debug) ──────────────────────────────────
  { "mfussenegger/nvim-dap" },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup()
      dap.listeners.after.event_initialized["dapui_config"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dapui_config"]  = function() dapui.close() end
      dap.listeners.before.event_exited["dapui_config"]      = function() dapui.close() end
    end,
  },
  { "theHamsta/nvim-dap-virtual-text", config = function() require("nvim-dap-virtual-text").setup() end },
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "mason-org/mason.nvim", "mfussenegger/nvim-dap" },
    config = function()
      require("mason-nvim-dap").setup({
        ensure_installed = { "codelldb", "debugpy", "js-debug-adapter" },
        automatic_installation = true,
      })
    end,
  },
  {
    "mxsdev/nvim-dap-vscode-js",
    dependencies = { "mfussenegger/nvim-dap", "mason-org/mason.nvim" },
    config = function()
      local ok = pcall(require, "dap-vscode-js")
      if not ok then return end
      local mason_pkg = vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter"
      if vim.fn.isdirectory(mason_pkg) == 0 then return end
      require("dap-vscode-js").setup({
        debugger_path = mason_pkg,
        adapters = { "pwa-node", "pwa-chrome", "pwa-msedge", "node-terminal", "pwa-extensionHost" },
      })
      local dap = require("dap")
      for _, lang in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
        dap.configurations[lang] = {
          { type = "pwa-node", request = "launch", name = "Node: Dosyayı çalıştır", program = "${file}", cwd = "${workspaceFolder}" },
          { type = "pwa-node", request = "attach", name = "Node: 9229'a bağlan", processId = require("dap.utils").pick_process, port = 9229, cwd = "${workspaceFolder}" },
        }
      end
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    dependencies = { "mfussenegger/nvim-dap", "mason-org/mason.nvim" },
    config = function()
      local ok = pcall(require, "dap-python")
      if not ok then return end
      local py = project_python()
      if not py then
        local mason_py = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python"
        if vim.fn.executable(mason_py) == 1 then py = mason_py end
      end
      pcall(function() require("dap-python").setup(py or "python3") end)
    end,
  },

}, {  -- lazy.nvim genel ayarları
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
})

-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
-- ━━━━━━━━━━━━━━  KAPSAMLI TUŞLAMA (KEYMAP)  ━━━━━━━━━━━━━━
-- ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

local map = function(mode, lhs, rhs, desc)
  vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- ── Genel ───────────────────────────────────────────
map("n", "<Esc>",      "<cmd>noh<CR>",   "Aramayı temizle")
map("n", "<leader>q",  "<cmd>qa<CR>",    "Tümünü kapat")
map("n", "<leader>Q",  "<cmd>qa!<CR>",   "Kaydetmeden kapat")
map("n", "<leader>s",  "<cmd>w<CR>",     "Kaydet")
map("n", "<leader>S",  "<cmd>wa<CR>",    "Tümünü kaydet")

-- ── Pencere yönetimi ────────────────────────────────
map("n", "<leader>wv", "<cmd>vsplit<CR>",  "Dikey böl")
map("n", "<leader>wh", "<cmd>split<CR>",   "Yatay böl")
map("n", "<leader>wc", "<cmd>close<CR>",   "Pencereyi kapat")
map("n", "<leader>wo", "<cmd>only<CR>",    "Diğer pencereleri kapat")
map("n", "<leader>w=", "<C-w>=",           "Pencereleri eşitle")
-- Ctrl + yön ile pencereler arası gezinti
map("n", "<C-h>", "<C-w>h", "← Pencere")
map("n", "<C-j>", "<C-w>j", "↓ Pencere")
map("n", "<C-k>", "<C-w>k", "↑ Pencere")
map("n", "<C-l>", "<C-w>l", "→ Pencere")
-- Pencere boyutlandırma
map("n", "<C-Up>",    "<cmd>resize +2<CR>",          "Pencere ↑ büyüt")
map("n", "<C-Down>",  "<cmd>resize -2<CR>",          "Pencere ↓ küçült")
map("n", "<C-Left>",  "<cmd>vertical resize -2<CR>", "Pencere ← küçült")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Pencere → büyüt")

-- ── Buffer yönetimi ─────────────────────────────────
map("n", "<leader>bn", "<cmd>bnext<CR>",     "Sonraki buffer")
map("n", "<leader>bp", "<cmd>bprevious<CR>", "Önceki buffer")
map("n", "<leader>bd", "<cmd>bdelete<CR>",   "Buffer kapat")
map("n", "<S-l>",      "<cmd>bnext<CR>",     "Sonraki buffer")
map("n", "<S-h>",      "<cmd>bprevious<CR>", "Önceki buffer")

-- ── Satır taşıma (Alt + j/k) ───────────────────────
map("n", "<A-j>", "<cmd>m .+1<CR>==",  "Satırı aşağı taşı")
map("n", "<A-k>", "<cmd>m .-2<CR>==",  "Satırı yukarı taşı")
map("v", "<A-j>", ":m '>+1<CR>gv=gv",  "Seçimi aşağı taşı")
map("v", "<A-k>", ":m '<-2<CR>gv=gv",  "Seçimi yukarı taşı")

-- ── Girintileme (Visual modda tekrarlanabilir) ──────
map("v", "<", "<gv", "Girinti azalt")
map("v", ">", ">gv", "Girinti artır")

-- ── Dosya gezgini ───────────────────────────────────
map("n", "<leader>e",  "<cmd>NvimTreeToggle<CR>",   "Dosya gezgini")
map("n", "<leader>E",  "<cmd>NvimTreeFindFile<CR>", "Dosya gezgininde bul")

-- ── Telescope ───────────────────────────────────────
map("n", "<leader>ff", "<cmd>Telescope find_files<CR>",            "Dosya bul")
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>",             "Metin ara (grep)")
map("n", "<leader>fb", "<cmd>Telescope buffers<CR>",               "Açık buffer'lar")
map("n", "<leader>fh", "<cmd>Telescope help_tags<CR>",             "Yardım ara")
map("n", "<leader>fd", "<cmd>Telescope diagnostics<CR>",           "Tanılama listesi")
map("n", "<leader>fr", "<cmd>Telescope oldfiles<CR>",              "Son dosyalar")
map("n", "<leader>fw", "<cmd>Telescope grep_string<CR>",           "İmleç altı kelimeyi ara")
map("n", "<leader>fs", "<cmd>Telescope lsp_document_symbols<CR>",  "Dosya sembolleri")
map("n", "<leader>fS", "<cmd>Telescope lsp_workspace_symbols<CR>", "Workspace sembolleri")
map("n", "<leader>fc", "<cmd>Telescope commands<CR>",              "Komutlar")
map("n", "<leader>fk", "<cmd>Telescope keymaps<CR>",               "Tuş atamaları")

-- ── Git (Telescope + Gitsigns) ──────────────────────
map("n", "<leader>gc", "<cmd>Telescope git_commits<CR>",  "Git commit'leri")
map("n", "<leader>gb", "<cmd>Telescope git_branches<CR>", "Git branch'leri")
map("n", "<leader>gs", "<cmd>Telescope git_status<CR>",   "Git status")
map("n", "<leader>gp", "<cmd>Gitsigns preview_hunk<CR>",  "Hunk önizle")
map("n", "<leader>gR", "<cmd>Gitsigns reset_hunk<CR>",    "Hunk sıfırla")
map("n", "<leader>gB", "<cmd>Gitsigns reset_buffer<CR>",  "Buffer sıfırla")
map("n", "<leader>gl", "<cmd>Gitsigns blame_line<CR>",    "Satır blame")
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<CR>",      "Diff göster")
map("n", "]h",         "<cmd>Gitsigns next_hunk<CR>",     "Sonraki hunk")
map("n", "[h",         "<cmd>Gitsigns prev_hunk<CR>",     "Önceki hunk")

-- ── DAP (Debug) ─────────────────────────────────────
map("n", "<F5>",       function() require("dap").continue() end,          "DAP: Devam")
map("n", "<F10>",      function() require("dap").step_over() end,         "DAP: Step Over")
map("n", "<F11>",      function() require("dap").step_into() end,         "DAP: Step Into")
map("n", "<S-F11>",    function() require("dap").step_out() end,          "DAP: Step Out")
map("n", "<leader>db", function() require("dap").toggle_breakpoint() end,  "Breakpoint koy/kaldır")
map("n", "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Koşul: ")) end, "Koşullu breakpoint")
map("n", "<leader>dr", function() require("dap").repl.open() end,         "DAP REPL aç")
map("n", "<leader>du", function() require("dapui").toggle() end,          "DAP UI aç/kapa")
map("n", "<leader>dl", function() require("dap").run_last() end,          "Son debug'ı tekrarla")
map("n", "<leader>dx", function() require("dap").terminate() end,         "Debug'ı durdur")

-- ── Aç / Kapa (Toggle) ─────────────────────────────
map("n", "<leader>tn", "<cmd>set relativenumber!<CR>", "Göreceli satır no aç/kapa")
map("n", "<leader>tw", "<cmd>set wrap!<CR>",            "Satır kaydırma aç/kapa")
map("n", "<leader>ts", "<cmd>set spell!<CR>",           "Yazım denetimi aç/kapa")

-- ━━━━━━━━━━━━━━  LSP KISAYOLLARI (LspAttach)  ━━━━━━━━━━━━━━

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    local buf = ev.buf
    local m = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
    end

    -- Goto — Neovim 0.11 varsayılanlarıyla uyumlu (grr, grn, gra)
    m("n", "gd",  vim.lsp.buf.definition,      "Tanıma git")
    m("n", "gD",  vim.lsp.buf.declaration,      "Bildirime git")
    m("n", "gi",  vim.lsp.buf.implementation,   "Uygulamaya git")
    m("n", "gt",  vim.lsp.buf.type_definition,  "Tür tanımına git")
    m("n", "grr", vim.lsp.buf.references,       "Referansları göster")
    m("n", "grn", vim.lsp.buf.rename,           "Yeniden adlandır")
    m({ "n", "v" }, "gra", vim.lsp.buf.code_action, "Kod eylemi")

    -- Bilgi
    m("n", "K",     vim.lsp.buf.hover,          "Hover bilgisi")
    m("n", "<C-k>", vim.lsp.buf.signature_help, "İmza yardımı")
    m("i", "<C-k>", vim.lsp.buf.signature_help, "İmza yardımı (insert)")

    -- LSP workspace
    m("n", "<leader>la", vim.lsp.buf.add_workspace_folder,    "Workspace klasörü ekle")
    m("n", "<leader>lr", vim.lsp.buf.remove_workspace_folder, "Workspace klasörü kaldır")
    m("n", "<leader>ll", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, "Workspace klasörlerini listele")

    -- Format
    m("n", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Biçimlendir")
    m("v", "<leader>lf", function() vim.lsp.buf.format({ async = true }) end, "Seçimi biçimlendir")

    -- Tanılama
    m("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end,  "Sonraki tanılama")
    m("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, "Önceki tanılama")
    m("n", "<leader>ld", vim.diagnostic.open_float, "Tanılama detayı")
    m("n", "<leader>lq", vim.diagnostic.setloclist,  "Tanılamayı quickfix'e aktar")

    -- Inlay hints
    if vim.lsp.inlay_hint and vim.lsp.inlay_hint.enable then
      m("n", "<leader>lh", function()
        local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = buf })
        vim.lsp.inlay_hint.enable(not enabled, { bufnr = buf })
      end, "Inlay hints aç/kapa")
    end
  end,
})

-- ━━━━━━━━━━━━━━  TEŞHİS (DIAGNOSTICS)  ━━━━━━━━━━━━━━

vim.diagnostic.config({
  virtual_text     = { spacing = 4, prefix = "●" },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = " ",
      [vim.diagnostic.severity.WARN]  = " ",
      [vim.diagnostic.severity.HINT]  = " ",
      [vim.diagnostic.severity.INFO]  = " ",
    },
  },
  underline        = true,
  update_in_insert = false,
  severity_sort    = true,
  float            = { border = "rounded", source = true },
})

-- ━━━━━━━━━━━━━━  EK AYARLAR  ━━━━━━━━━━━━━━━━━━━━━━

-- Kopyalanan metni bir an vurgula
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("HighlightYank", {}),
  callback = function() vim.hl.on_yank({ timeout = 200 }) end,
})

-- Son konuma geri dön
vim.api.nvim_create_autocmd("BufReadPost", {
  group = vim.api.nvim_create_augroup("RestoreCursor", {}),
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    local lcount = vim.api.nvim_buf_line_count(ev.buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})
