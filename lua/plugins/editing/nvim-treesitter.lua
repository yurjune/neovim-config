-- A plugin for parser generator
-- 구문을 분석하여 하이라이팅과 다양한 코드 조작 기능 제공
return {
  "nvim-treesitter/nvim-treesitter",
  event = { "BufReadPre", "BufNewFile" },
  -- whenever this plugin is updated, all language parsers will be updated
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-context",
  },

  config = function()
    local treesitter = require("nvim-treesitter.configs")
    local context = require("treesitter-context")

    treesitter.setup({
      -- ensure these language parsers are installed
      ensure_installed = {
        "javascript",
        "typescript",
        "tsx",
        "json",
        "yaml",
        "html",
        "css",
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
        "rust",
        "regex",
      },
      auto_install = true,
      sync_install = false,
      ignore_install = {},
      modules = {},

      highlight = { enable = true }, -- enable syntax highlighting
      indent = { enable = true },
      fold = { enable = true },

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

    -- 현재 코드 줄의 컨텍스트를 sticky하게 표시합니다.
    context.setup({
      enable = true,
      max_lines = 2,
      trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
    })

    vim.keymap.set("n", "<leader>g1", function()
      context.go_to_context(1)
    end, { desc = "Go to first nearest context" })

    vim.keymap.set("n", "<leader>g2", function()
      context.go_to_context(2)
    end, { desc = "Go to second nearest context" })

    vim.keymap.set("n", "<leader>g3", function()
      context.go_to_context(3)
    end, { desc = "Go to third nearest context" })
  end,
}
