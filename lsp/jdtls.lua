local mason_pkg_path = vim.fn.stdpath("data") .. "/mason/packages/jdtls"
local lombok_jar = mason_pkg_path .. "/lombok.jar"

-- Unlike other LSP servers, jdtls persists its index/build state to disk per workspace,
-- so each project needs its own "-data" dir to avoid sharing a stale/mixed cache.
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project_name

return {
  cmd = {
    "jdtls",
    "--jvm-arg=-javaagent:" .. lombok_jar, -- resolve Lombok-generated code (@Getter, @Builder, etc.)
    "-data",
    workspace_dir,
  },
  filetypes = { "java" },
  root_markers = {
    "pom.xml",
    "build.gradle",
    "build.gradle.kts",
    "settings.gradle",
    "settings.gradle.kts",
    ".git",
  },
  settings = {
    java = {
      configuration = {
        updateBuildConfiguration = "interactive",
      },
      maven = {
        downloadSources = true,
      },
      eclipse = {
        downloadSources = true,
      },
      signatureHelp = { enabled = true },
      format = { enabled = true },
      inlayHints = {
        parameterNames = { enabled = "all" },
      },
    },
  },
}
