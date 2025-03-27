-- [[
-- Treesitter: 파서 생성 도구이자 증분 파싱 라이브러리
-- 구문을 분석하여 하이라이팅과 다양한 코드 조작 기능 제공
-- ]]
return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  -- whenever this plugin is updated, all language parsers will be updated
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
  },

  config = function()
    local treesitter = require("nvim-treesitter.configs")

    treesitter.setup({
      -- ensure these language parsers are installed
      ensure_installed = {
        "json",
        "javascript",
        "typescript",
        "tsx",
        "yaml",
        "html",
        "css",
        "prisma",
        "markdown",
        "markdown_inline",
        "svelte",
        "graphql",
        "bash",
        "lua",
        "vim",
        "dockerfile",
        "gitignore",
        "query",
        "vimdoc",
        "c",
      },
      auto_install = true,
      sync_install = false,
      ignore_install = {},
      modules = {},

      -- enable syntax highlighting
      highlight = {
        enable = true,
      },
      indent = {
        enable = true,
      },

      -- 코드 구문 구조에 따라 선택 영역을 점진적으로 확장하거나 축소
      incremental_selection = {
        enable = false,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
    })
  end,
}
