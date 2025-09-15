vim.opt.clipboard = "unnamedplus"

require("plugins")
-- require('java').setup()
-- require('lspconfig').jdtls.setup({})
require("cmp_config")
require('lualine').setup()
require("dap_config")

vim.keymap.set('n', "<Space>lg", ":LazyGit<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<Space>lf", ":ConformFormat<cr>", { desc = "Format File with conform" })
vim.keymap.set('n', "<Space>re", ":NvimTreeToggle<cr>", { noremap = true, silent = true })
vim.keymap.set('n', "<Space>gg", ":Telescope live_grep<cr>", { noremap = true, silent = true })
vim.keymap.set('n', "<Space>gj", ":Telescope find_files<cr>", { noremap = true, silent = true })
vim.keymap.set('n', "<Space>ba", ":AvanteToggle<cr>", { noremap = true, silent = true })
vim.keymap.set('n', "<Space>be", ":AvanteChatNew<cr>", { noremap = true, silent = true })
vim.keymap.set('n', "<Space>ca", vim.lsp.buf.code_action, { noremap = true, silent = true })
vim.keymap.set("n", "<space>e", function()
  vim.diagnostic.open_float(0, { scope = "line" })
end, { noremap = true, silent = true })

-- Debugger keymaps
vim.keymap.set('n', '<leader>b', "<cmd>lua require('dap').toggle_breakpoint()<CR>", { desc = 'Toggle Breakpoint' })
vim.keymap.set('n', '<leader>c', "<cmd>lua require('dap').continue()<CR>", { desc = 'Start/Continue' })
vim.keymap.set('n', '<leader>n', "<cmd>lua require('dap').step_over()<CR>", { desc = 'Step Over' })
vim.keymap.set('n', '<leader>i', "<cmd>lua require('dap').step_into()<CR>", { desc = 'Step Into' })
vim.keymap.set('n', '<leader>o', "<cmd>lua require('dap').step_out()<CR>", { desc = 'Step Out' })
vim.keymap.set('n', '<leader>ds', "<cmd>lua require('dap').repl.open()<CR>", { desc = 'Open Debug REPL' })
vim.keymap.set('n', '<leader>du', "<cmd>lua require('dapui').toggle()<CR>", { desc = 'Toggle Debugger UI' })


vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
vim.opt.softtabstop = 2

-- vim.o.background = "dark" -- or "light" for light mode
-- vim.cmd([[colorscheme gruvbox]])
-- vim.cmd [[colorscheme catppuccin]]

-- vim.cmd [[colorscheme onedark]]
require("cyber_dream_config").setup()
vim.cmd("colorscheme cyberdream")

vim.diagnostic.config({
  virtual_text = true,
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = false,
})
