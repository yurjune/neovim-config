-- A fast fuzzy finder powered by fzf
return {
  "ibhagwan/fzf-lua",
  enabled = true,
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local fzf = require("fzf-lua")
    local ignore_file_option = "--ignore-file "
      .. vim.fn.shellescape(vim.fn.stdpath("config") .. "/lua/plugins/navigation/fzf.ignore")

    fzf.setup({
      "fzf-native",
      fzf_colors = true,
      -- Handle vim.ui.select directly. Going through dressing.nvim's queued
      -- adapter can leave later selects queued when an fzf picker is cancelled.
      ui_select = {},
      fzf_opts = {
        ["--cycle"] = true,
        ["--ignore-case"] = true,
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
        hidden = false,
        no_ignore = true, -- ignore project config
        fd_opts = table.concat({
          "--color=never",
          "--type f",
          "--type l",
          ignore_file_option,
        }, " "),
      },
      grep = {
        hidden = false,
        no_ignore = true, -- ignore project config
        rg_opts = table.concat({
          "--column",
          "--line-number",
          "--no-heading",
          "--color=always",
          "--ignore-case",
          "--max-columns=4096",
          ignore_file_option,
          "-e",
        }, " "),
      },
      keymap = {
        fzf = {
          true,
          ["ctrl-d"] = "preview-page-down",
          ["ctrl-u"] = "preview-page-up",
        },
      },
    })

    vim.keymap.set("n", "<leader>fh", fzf.files, { desc = "FzfLua find files" })
    vim.keymap.set("n", "<leader>fg", fzf.git_status, { desc = "FzfLua git status" })

    vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "FzfLua buffers" })

    vim.keymap.set("n", "<leader>fl", fzf.live_grep, { desc = "FzfLua live grep" })
    vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "FzfLua grep word under cursor" })
    vim.keymap.set("v", "<leader>fw", fzf.grep_visual, { desc = "FzfLua grep selected" })

    vim.keymap.set("n", "<leader>fG", fzf.git_bcommits, { desc = "FzfLua git buffer commits" })
    vim.keymap.set("n", "<leader>fr", fzf.resume, { desc = "FzfLua resume last picker" })
    vim.keymap.set("n", "<leader>fq", fzf.quickfix, { desc = "FzfLua quickfix list" })

    vim.keymap.set("n", "<leader>fs", fzf.lsp_document_symbols, { desc = "FzfLua document symbols" })
    vim.keymap.set("n", "<leader>fn", function()
      require("notify.integrations.fzf").open()
    end, { desc = "FzfLua notifications" })
  end,
}
