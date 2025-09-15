return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = {
    {
      -- Customize the keymap as you prefer
      "<Space>cf",
      function()
        require("conform").format({ async = true, lsp_fallback = true })
      end,
      mode = "",
      desc = "Format buffer",
    },
  },
  opts = {

    formatters_by_ft = {
      -- Add formatters for specific file types here
      lua = { "stylua" },
      python = { "black" },
      javascript = { "prettier" },
      json = { "prettier" },
      -- java = { "google-java-format" },
      java = {
        "checkstyle", -- Use checkstyle as the formatter
        -- Optional: Pass arguments to checkstyle, including the path to the Checkstyle config file
        -- Note: You might need to adjust the arguments based on your Checkstyle setup
        args = {
          "--config-file",
          "~./enterprise-checkstyle-rules.xml" -- Replace with the actual path
        }
      },
    },

    format_on_save = {
      timeout_ms = 500,
      lsp_fallback = true,
    },
  },
}
