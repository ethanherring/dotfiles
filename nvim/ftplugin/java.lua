local jdtls = require("jdtls")
local util = require("jdtls.util")

-- Find project root (pom.xml for Spring Boot is perfect)
local root_markers = { "pom.xml", "build.gradle", "mvnw", "gradlew", ".git" }
local root_dir = jdtls.setup.find_root(root_markers)
if root_dir == "" then
  -- Not in a Java project; do nothing
  return
end

-- Mason paths
local mason_registry = require("mason-registry")
local jdtls_pkg = mason_registry.get_package("jdtls")
local jdtls_path = jdtls_pkg:get_install_path()

-- Launcher/config per OS
local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
local config_dir = (function()
  if vim.fn.has("mac") == 1 then
    return jdtls_path .. "/config_mac"
  elseif vim.fn.has("win32") == 1 then
    return jdtls_path .. "/config_win"
  else
    return jdtls_path .. "/config_linux"
  end
end)()

-- Lombok
local lombok_jar = jdtls_path .. "/lombok.jar"
if vim.fn.filereadable(lombok_jar) == 0 then
  -- Download once if it doesn't exist
  vim.fn.system({
    "curl", "-fsSL", "https://projectlombok.org/downloads/lombok.jar", "-o", lombok_jar
  })
end

-- Workspace folder per project
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls-workspaces/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")
vim.fn.mkdir(workspace_dir, "p")

-- Java command (use your JDK 21 path, or leave as "java" if JAVA_HOME is set)
-- local java_cmd = "/opt/homebrew/Cellar/openjdk@21/21.0.7/libexec/openjdk.jdk/Contents/Home/bin/java"
local java_cmd = "java"

-- Debug/test bundles from mason
local bundles = {}

local function add_bundles_from(glob)
  local jars = vim.split(vim.fn.glob(glob), "\n")
  for _, jar in ipairs(jars) do
    if jar ~= "" then
      table.insert(bundles, jar)
    end
  end
end

-- java-debug-adapter (debugger)
local java_dbg = mason_registry.get_package("java-debug-adapter"):get_install_path()
add_bundles_from(java_dbg .. "/extension/server/com.microsoft.java.debug.plugin-*.jar")

-- java-test (test runner/debug of tests)
local java_test = mason_registry.get_package("java-test"):get_install_path()
add_bundles_from(java_test .. "/extension/server/*.jar")

-- Capabilities
local capabilities = vim.lsp.protocol.make_client_capabilities()

-- On_attach: LSP maps + DAP setup
local function on_attach(client, bufnr)
  -- Basic LSP keymaps
  local opts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
  vim.keymap.set("n", "<space>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<space>ca", vim.lsp.buf.code_action, opts)

  -- jdtls extras
  jdtls.setup_dap({ hotcodereplace = "auto" })
  jdtls.dap.setup_dap_main_class_configs() -- creates "Launch" configs per main class

  -- Optional: test helpers
  vim.keymap.set("n", "<leader>jt", jdtls.test_nearest_method, { desc = "Debug nearest test", buffer = bufnr })
  vim.keymap.set("n", "<leader>jT", jdtls.test_class, { desc = "Debug test class", buffer = bufnr })
  vim.keymap.set("n", "<leader>jo", jdtls.organize_imports, { desc = "Organize imports", buffer = bufnr })


  -- debug launch
  vim.keymap.set("n", "<leader>dc", function()
    require('dap').continue()
  end, { desc = "Start/Continue Debug", buffer = bufnr })
  
  vim.keymap.set("n", "<leader>dj", function()
    require('jdtls.dap').setup_dap_main_class_configs()
    require('dap').continue()
  end, { desc = "Debug Java Main Class", buffer = bufnr })
  
  vim.keymap.set("n", "<leader>dt", function()
    require('jdtls').test_nearest_method()
  end, { desc = "Debug Test Method", buffer = bufnr })
  
end

-- Runtimes (as in your original)
local settings = {
  java = {
    debug = { settings = { enableRunDebugCodeLens = true } },
    },
  }
-- local settings = {
--   java = {
--     debug = { settings = { enableRunDebugCodeLens = true } },
--     configuration = {
--       runtimes = {
--         {
--           name = "JavaSE-1.8",
--           path = "/Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home",
--         },
--         {
--           name = "JavaSE-21",
--           path = "/opt/homebrew/Cellar/openjdk@21/21.0.7/libexec/openjdk.jdk/Contents/Home",
--           default = true,
--         },
--       },
--     },
--   },
-- }

-- Build cmd
local cmd = {
  java_cmd,
  "-javaagent:" .. lombok_jar,
  "-Declipse.application=org.eclipse.jdt.ls.core.id1",
  "-Dosgi.bundles.defaultStartLevel=4",
  "-Declipse.product=org.eclipse.jdt.ls.core.product",
  "-Dlog.level=ALL",
  "-noverify",
  "-Xms1G",
  "--add-modules=ALL-SYSTEM",
  "--add-opens", "java.base/java.util=ALL-UNNAMED",
  "--add-opens", "java.base/java.lang=ALL-UNNAMED",
  "-jar", launcher_jar,
  "-configuration", config_dir,
  "-data", workspace_dir,
}

-- Start or attach
jdtls.start_or_attach({
  cmd = cmd,
  root_dir = root_dir,
  on_attach = on_attach,
  capabilities = capabilities,
  settings = settings,
  init_options = {
    bundles = bundles,
  },
})
