-- A fast fuzzy finder powered by fzf
return {
  "ibhagwan/fzf-lua",
  enabled = true,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local fzf = require("fzf-lua")

    fzf.setup({
      "fzf-native",
      fzf_opts = {
        ["--cycle"] = true,
      },
      winopts = {
        preview = {
          default = "bat", -- use bat instead of neovim buffer
          horizontal = "right:40%",
        },
      },
      previewers = {
        bat = {
          args = "--color=always --style=numbers,changes --theme='Catppuccin Mocha'",
        },
      },
      files = {
        hidden = true,
        file_ignore_patterns = {
          "^%.git/",
          "node_modules/",
        },
      },
      grep = {
        hidden = true,
        file_ignore_patterns = {
          "^%.git/",
          "node_modules/",
        },
      },
      keymap = {
        -- for fzf-native
        builtin = {
          true,
          ["<C-d>"] = "preview-page-down",
          ["<C-u>"] = "preview-page-up",
        },
      },
    })

    vim.keymap.set("n", "<leader>fh", fzf.files, { desc = "FzfLua find files" })

    vim.keymap.set("n", "<leader>fl", fzf.live_grep, { desc = "FzfLua live grep" })
    vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "FzfLua grep word under cursor" })
    vim.keymap.set("v", "<leader>fs", fzf.grep_visual, { desc = "FzfLua grep selected" })

    vim.keymap.set("n", "<leader>fg", fzf.git_status, { desc = "FzfLua git status" })
    vim.keymap.set("n", "<leader>fG", fzf.git_bcommits, { desc = "FzfLua git file commits" })

    vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "FzfLua buffers" })
    vim.keymap.set("n", "<leader>ft", "<cmd>TodoFzfLua<CR>", { desc = "FzfLua all todos" })
    vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "FzfLua resume last picker" })

    vim.keymap.set("n", "<leader>fn", function()
      require("notify.integrations.fzf").open()
    end, { desc = "FzfLua notifications" })
  end,
}
