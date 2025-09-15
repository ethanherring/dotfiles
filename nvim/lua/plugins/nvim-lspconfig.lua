return
{
  "neovim/nvim-lspconfig",
  dependencies = { "williamboman/mason-lspconfig.nvim" },
  config = function()
    local lspconfig       = require("lspconfig")
    local mason_lspconfig = require("mason-lspconfig")

    ---------------------------------------------------------------------------
    -- 1. generic on_attach + capabilities 
    ---------------------------------------------------------------------------
    local function on_attach(client, bufnr)
      local opts = { noremap = true, silent = true }
      local map  = vim.api.nvim_buf_set_keymap
      map(bufnr, "n", "gd", "<Cmd>lua vim.lsp.buf.definition()<CR>", opts)
      map(bufnr, "n", "K", "<Cmd>lua vim.lsp.buf.hover()<CR>", opts)
      map(bufnr, "n", "gi", "<Cmd>lua vim.lsp.buf.implementation()<CR>", opts)
      map(bufnr, "n", "<C-k>", "<Cmd>lua vim.lsp.buf.signature_help()<CR>", opts)
      map(bufnr, "n", "<Space>wa", "<Cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
      map(bufnr, "n", "<Space>wr", "<Cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
      map(bufnr, "n", "<Space>D", "<Cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
      map(bufnr, "n", "<Space>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", opts)
      map(bufnr, "n", "<Space>ca", "<Cmd>lua vim.lsp.buf.code_action()<CR>", opts)
      map(bufnr, "n", "gr", "<Cmd>lua vim.lsp.buf.references()<CR>", opts)
      map(bufnr, "n", "[d", "<Cmd>lua vim.diagnostic.goto_prev()<CR>", opts)
      map(bufnr, "n", "]d", "<Cmd>lua vim.diagnostic.goto_next()<CR>", opts)

      if client.name == "jdtls" then
        vim.keymap.set("n", "<leader>jC", function()
          vim.lsp.buf.execute_command({ command = "java.clean.workspace", arguments = { true } })
          print("JDTLS workspace cleaning initiated. You may be prompted to restart Neovim.")
        end, { desc = "Clean JDTLS Workspace" })
      end
    end

    local capabilities = vim.lsp.protocol.make_client_capabilities()

    ---------------------------------------------------------------------------
    -- 2. mason-lspconfig handlers
    ---------------------------------------------------------------------------
    mason_lspconfig.setup_handlers({

      -- (A) DEFAULT handler  ▸ every server EXCEPT jdtls
      function(server_name)
        if server_name == "jdtls" then return end -- let the special one run
        lspconfig[server_name].setup({
          on_attach    = on_attach,
          capabilities = capabilities,
        })
      end,

      -- (B) SPECIAL handler ▸ jdtls with Lombok
      ["jdtls"] = function()
        ----------------------------------------------------------------------
        -- Paths managed by mason
        ----------------------------------------------------------------------
        local mr = require("mason-registry")
        local jdtls_pkg = mr.get_package("jdtls")
        local jdtls_root = jdtls_pkg:get_install_path()
        local lombok_path = jdtls_root .. "/lombok.jar"
        local java_cmd = "/opt/homebrew/Cellar/openjdk@21/21.0.7/libexec/openjdk.jdk/Contents/Home/bin/java" -- IMPORTANT: Please verify this path

        ----------------------------------------------------------------------
        -- Download lombok.jar once (≈1 MiB) if it does not exist
        ----------------------------------------------------------------------
        if vim.fn.filereadable(lombok_path) == 0 then
          vim.fn.system({
            "curl",
            "-fsSL",
            "https://projectlombok.org/downloads/lombok.jar",
            "-o",
            lombok_path,
          })
        end

        -- Find the launcher jar
        local launcher = vim.fn.glob(jdtls_root .. "/plugins/org.eclipse.equinox.launcher_*.jar")
        if vim.fn.empty(launcher) > 0 then
          -- Fallback for different jdtls versions
          launcher = vim.fn.glob(jdtls_root .. "/../../plugins/org.eclipse.equinox.launcher_*.jar")
        end

        -- Determine config directory based on OS
        local config = jdtls_root .. "/config_mac"
        if vim.fn.has("win32") == 1 then
          config = jdtls_root .. "/config_win"
        elseif vim.fn.has("mac") ~= 1 then
          config = jdtls_root .. "/config_linux"
        end

        ----------------------------------------------------------------------
        -- Start jdtls with a direct Java call
        ----------------------------------------------------------------------
        local cmd = {
          java_cmd,
          "-javaagent:" .. lombok_path,
          "-Declipse.application=org.eclipse.jdt.ls.core.id1",
          "-Dosgi.bundles.defaultStartLevel=4",
          "-Declipse.product=org.eclipse.jdt.ls.core.product",
          "-Dlog.level=ALL",
          "-noverify",
          "-Xms1G",
          "--add-modules=ALL-SYSTEM",
          "--add-opens",
          "java.base/java.util=ALL-UNNAMED",
          "--add-opens",
          "java.base/java.lang=ALL-UNNAMED",
          "-jar",
          launcher,
          "-configuration",
          config,
        }

        lspconfig.jdtls.setup({
          cmd = cmd,
          on_attach = on_attach,
          capabilities = capabilities,

          -- project root detection
          root_dir = lspconfig.util.root_pattern("pom.xml"),

      --     root_dir = function(fname)
      --   -- Check for pom.xml in the current directory or a specific 'service' subdirectory
      --   local current_dir = vim.fn.path.dirname(fname)
      --   if util.path.is_dir(current_dir .. "/pom.xml") then
      --     return current_dir
      --   elseif util.path.is_dir(current_dir .. "/service/pom.xml") then
      --     return current_dir .. "/service"
      --   else
      --     -- Fallback to default root detection if not found in specific locations
      --     return util.find_git_ancestor(fname) or util.find_package_json_ancestor(fname)
      --   end
      -- end,

          settings = {
            java = {
              debug = {
                settings = {
                  enableRunDebugCodeLens = true,
                },
              },
              configuration = {
                runtimes = {
                  {
                    name = "JavaSE-1.8",
                    path = "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home",
                  },
                  {
                    name = "JavaSE-21",
                    path = "/opt/homebrew/Cellar/openjdk@21/21.0.7/libexec/openjdk.jdk/Contents/Home",
                    default = true,
                  },
                },
              },
            },
            -- profile = "EnterpriseStyle",
            -- url = "~./enterprise-checkstyle-rules.xml",
          },
        })
      end,
    })
  end,
}

