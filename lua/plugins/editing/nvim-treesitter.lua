-- A plugin for parser generator
-- 구문을 분석하여 하이라이팅과 다양한 코드 조작 기능 제공
vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter",
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/nvim-treesitter/nvim-treesitter-context",
  "https://github.com/windwp/nvim-ts-autotag",
  "https://github.com/Vimjas/vim-python-pep8-indent",
})
vim.cmd.packadd("nvim-treesitter")
vim.cmd.packadd("nvim-treesitter-textobjects")
vim.cmd.packadd("nvim-ts-autotag")
vim.cmd.packadd("nvim-treesitter-context")
vim.cmd.packadd("vim-python-pep8-indent")

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
    "c",
    "cpp",
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

  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to find the next textobject
      keymaps = {
        -- Can be used with operators: daf (delete), caf (change), yaf (yank), etc.
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ai"] = "@conditional.outer", -- if statement
        ["ii"] = "@conditional.inner",
        ["aa"] = "@parameter.outer", -- parameter with type
        ["ia"] = "@parameter.inner", -- parameter name only
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- Add jumps to jumplist
      goto_next_start = {
        ["]f"] = "@function.outer",
      },
      goto_previous_start = {
        ["[f"] = "@function.outer",
      },
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
