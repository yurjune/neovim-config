-- A plugin for parser generator
-- analyze syntax: support highlighting, various code edit
return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  lazy = false, -- This plugin does not support lazy-loading
  -- whenever this plugin is updated, all language parsers will be updated
  build = ":TSUpdate",
  dependencies = {
    "windwp/nvim-ts-autotag",
    "nvim-treesitter/nvim-treesitter-context",
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    },
    {
      -- nvim-treesitter 에서는 중첩 함수의 return 이후 indent가 이상적으로 동작하지 않음(들여쓰기 레벨이 초기화)
      -- check current indent method by this command: set indentexpr?
      "Vimjas/vim-python-pep8-indent",
      ft = "python",
    },
  },

  config = function()
    local treesitter = require("nvim-treesitter")
    local context = require("treesitter-context")
    local textobjects = require("nvim-treesitter-textobjects")

    local ensure_installed = {
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
      "sql",
      -- "regex",
      -- "graphql",
      -- "svelte",
    }

    treesitter.setup()

    if vim.fn.executable("tree-sitter") == 1 then
      local installed = treesitter.get_installed()
      local missing_parsers = vim.tbl_filter(function(parser)
        return not vim.tbl_contains(installed, parser)
      end, ensure_installed)

      if #missing_parsers > 0 then
        treesitter.install(missing_parsers)
      end
    end

    vim.api.nvim_create_autocmd("FileType", {
      group = vim.api.nvim_create_augroup("treesitter-start", { clear = true }),
      callback = function()
        pcall(vim.treesitter.start)

        vim.wo.foldmethod = "expr"
        vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"

        if vim.bo.filetype ~= "python" then
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })

    textobjects.setup({
      select = {
        lookahead = true, -- Automatically jump forward to find the next textobject
      },
      move = {
        set_jumps = true, -- Add jumps to jumplist
      },
    })

    local select = require("nvim-treesitter-textobjects.select")
    vim.keymap.set({ "x", "o" }, "af", function()
      select.select_textobject("@function.outer", "textobjects")
    end, { desc = "Select outer function" })
    vim.keymap.set({ "x", "o" }, "if", function()
      select.select_textobject("@function.inner", "textobjects")
    end, { desc = "Select inner function" })
    vim.keymap.set({ "x", "o" }, "ai", function()
      select.select_textobject("@conditional.outer", "textobjects")
    end, { desc = "Select outer conditional" })
    vim.keymap.set({ "x", "o" }, "ii", function()
      select.select_textobject("@conditional.inner", "textobjects")
    end, { desc = "Select inner conditional" })
    vim.keymap.set({ "x", "o" }, "aa", function()
      select.select_textobject("@parameter.outer", "textobjects")
    end, { desc = "Select outer parameter" })
    vim.keymap.set({ "x", "o" }, "ia", function()
      select.select_textobject("@parameter.inner", "textobjects")
    end, { desc = "Select inner parameter" })

    local move = require("nvim-treesitter-textobjects.move")
    vim.keymap.set({ "n", "x", "o" }, "]f", function()
      move.goto_next_start("@function.outer", "textobjects")
    end, { desc = "Next function start" })
    vim.keymap.set({ "n", "x", "o" }, "[f", function()
      move.goto_previous_start("@function.outer", "textobjects")
    end, { desc = "Previous function start" })

    -- show current line context sticky
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
