-- Install Lazy Vim if not Detected

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable relase
    lazypath,
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- { import = 'plugins.gruvbox-theme' },
  { import = 'plugins.cyber-dream' },
  { import = 'plugins.lua-line' },
  -- { import = 'plugins.nvim-dbee' },
  { import = 'plugins.git-gutter' },
  { import = 'plugins.avante' },
  { import = 'plugins.catppuccin' },
  -- { import = 'plugins.onedark' },
  { import = 'plugins.conform' },
  { import = 'plugins.lazygit' },
  { import = 'plugins.telescope' },
  {
    'hrsh7th/cmp-buffer',
    after = 'cmp_luasnip'
  },
  { "mfussenegger/nvim-jdtls" },
  -- { import = 'plugins.nvim-lspconfig' },
  {
    "hrsh7th/cmp-path",
  },
  {
    "hrsh7th/cmp-cmdline",
  },
  {
    "L3MON4D3/LuaSnip",
    after = { "nvim-cmp" }
  },
  {
    "saadparwaiz1/cmp_luasnip",
  },
  {
    "hrsh7th/cmp-nvim-lsp",
  },
  {
    "theprimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon"):setup()
    end,

    keys = {
      { "<Space>A", function() require("harpoon"):list():append() end,  desc = "harpoon file", },
      {
        "<Space>a",
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end,
        desc = "harpoon quick menu",
      },
      { "<Space>1", function() require("harpoon"):list():select(1) end, desc = "harpoon to file 1", },
      { "<Space>2", function() require("harpoon"):list():select(2) end, desc = "harpoon to file 2", },
      { "<Space>3", function() require("harpoon"):list():select(3) end, desc = "harpoon to file 3", },
      { "<Space>4", function() require("harpoon"):list():select(4) end, desc = "harpoon to file 4", },
      { "<Space>5", function() require("harpoon"):list():select(5) end, desc = "harpoon to file 5", },
      { "<Space>6", function() require("harpoon"):list():select(6) end, desc = "harpoon to file 6", }, },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = { "java", "c", "lua", "vim", "vimdoc", "query", "yaml", "markdown", "markdown_inline" }, -- Add languages you want to support
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },
      })
    end
  },
  -- nvim-tree.lua: File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    cmd = "NvimTreeToggle",
    dependencies = {
      "nvim-tree/nvim-web-devicons", -- for file icons
    },
    config = function()
      require("nvim-tree").setup({

        sort_by = "case_sensitive",

        view = {

          width = '30%',

          side = "left",

        },

        renderer = {

          icons = {

            glyphs = {
              default = "",
              symlink = "",
              folder = {
                arrow_open = "",
                arrow_closed = "",
                default = "",
                open = "",
                empty = "",
                empty_open = "",
                symlink = "",
                symlink_open = "",
              },
              git = {
                unstaged = "✗",
                staged = "✓",
                unmerged = "",
                renamed = "➜",
                untracked = "★",
                deleted = "",
                ignored = "◌",
              },
            },
          },
        },
        filters = {
          dotfiles = false,
          custom = { ".git", "node_modules", "__pycache__" },
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
        update_focused_file = {
          enable = true,
          update_cwd = true,
          ignore_list = {},
        },
        git = {
          enable = true,
          ignore = false,
          timeout = 500,
        },
        sync_root_with_cwd = true,
      })
    end,
  },
  -- nvim-web-devicons: For File Icons (optional but recommended)
  { import = 'plugins.nvim-web-devicons' },
  -- Mason: manages external editor tooling such as LSP servers, linters, and formatters
  {
    "williamboman/mason.nvim",
    version = "^1.0.0",
    opts = {
      ui = {
        border = "rounded",
      },
    },
    -- config = function(_, opts)
    --   require("mason").setup(opts)
      -- Manually trigger installation for any new packages
      -- if opts.ensure_installed and #opts.ensure_installed > 0 then
      --   vim.cmd("MasonInstall " .. table.concat(opts.ensure_installed, " "))
      -- end
    -- end,
  },
  -- {
  --   "jay-babu/mason-nvim-dap.nvim",
  --   dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
  --   opts = {
  --     handlers = {}, -- automatically sets up all supported DAPs
  --     ensure_installed = { "java-debug-adapter", "java-test" },
  --   },
  --   config = function(_, opts)
  --     require("mason-nvim-dap").setup(opts)
  --   end,
  -- },
  -- Mason LSPConfig: bridges mason and nvim-lspconfig for easier integration
  {
    "williamboman/mason-lspconfig.nvim",
    version = "^1.0.0",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = {
      ensure_installed = { "lua_ls", "pyright", "ts_ls", "gopls", "tailwindcss", "jdtls"  }, -- List of LSP servers to ensure are installed
      automatic_installation = true,
    },
    config = function(_, opts)
      require("mason-lspconfig").setup(opts)
    end,
  },
  {
    "mfussenegger/nvim-dap" 
  },
  {
    "rcarriga/nvim-dap-ui",
    dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
    config = function()
      require("dapui").setup()
    end,
  },
  {
    "theHamsta/nvim-dap-virtual-text",
    dependencies = { "mfussenegger/nvim-dap" },
    config = function()
      require("nvim-dap-virtual-text").setup()
    end,
  },
  
  -- Add Mason DAP integration
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = { "williamboman/mason.nvim", "mfussenegger/nvim-dap" },
    opts = {
      ensure_installed = { "java-debug-adapter", "java-test" },
      handlers = {},
    },
    config = function(_, opts)
      require("mason-nvim-dap").setup(opts)
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = false })
        end,
        desc = "Buffer Local Keymaps (which-key)",
      },
    },
  },
})
