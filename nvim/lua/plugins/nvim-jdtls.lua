return
{
  "mfussenegger/nvim-jdtls",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require('jdtls').start_or_attach({
      cmd = {
        "jdtls",                                                          -- Or the full path to your jdtls executable if it's not in PATH
        "--jvm-arg",
        "-javaagent:" .. vim.fn.expand("~/.local/share/java/lombok.jar"), -- Adjust path if needed
        -- Other JDTLS arguments if needed
      },
      root_dir = require("jdtls.setup").find_root({ "pom.xml", "build.gradle", ".git" }),
      -- Other JDTLS configuration, e.g., on_attach, capabilities...
    })
  end,
}
