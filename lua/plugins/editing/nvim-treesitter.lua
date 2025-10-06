-- A plugin for parser generator
-- 구문을 분석하여 하이라이팅과 다양한 코드 조작 기능 제공
return {
  "nvim-treesitter/nvim-treesitter",
  branhch = "master",
  -- branch = "main",  -- prepare for update
  event = { "BufReadPre", "BufNewFile" },
  -- whenever this plugin is updated, all language parsers will be updated
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-context",
    {
      -- nvim-treesitter 에서는 중첩 함수의 return 이후 indent가 이상적으로 동작하지 않음(들여쓰기 레벨이 초기화)
      -- check current indent method by this command: set indentexpr?
      "Vimjas/vim-python-pep8-indent",
      ft = "python",
    },
  },

  config = function()
    local treesitter = require("nvim-treesitter.configs")
    local context = require("treesitter-context")

    treesitter.setup({
      -- ensure these language parsers are installed
      ensure_installed = {
        "lua",
        "vimdoc",
        "query", -- treesitter query
        "markdown",
        "markdown_inline",
        "json",
        "yaml",
        "bash",
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx", -- includes jsx
        "rust",
        "vim", -- vimscript
        "dockerfile",
        "python",
        -- "c",
        -- "regex",
        -- "graphql",
        -- "svelte",
      },
      auto_install = true,
      sync_install = false,
      ignore_install = {},
      modules = {},
      highlight = {
        enable = true,
        disable = function(lang)
          -- disable python since treesitter issues
          -- will be fixed if nvim-treesitter is updated
          if lang == "python" then
            return true
          end
          return false
        end,
      },
      indent = {
        enable = true,
        disable = {
          "python", -- to use external python indent plugin
        },
      },
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
