-- A plugin that replaces the UI for messages, cmdline and the popupmenu.
return {
  "folke/noice.nvim",
  enabled = true,
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  priority = 900,
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup", -- floating popup
    },
    -- traditional vim's system messages
    messages = {
      enabled = true,
      view = "notify",
      view_error = "notify",
    },
    -- notifications caused by "vim.notify"
    notify = {
      enabled = true,
      view = "notify",
    },
    -- cmdline autocomplete popup
    popupmenu = {
      enabled = true,
      backend = "nui", -- cmp or nui
      kind_icons = {}, -- set to `false` to disable icons
    },
    lsp = {
      -- override markdown rendering so that cmp and other plugins use Treesitter
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
      },
      -- vim.lsp.buf.hover()
      hover = {
        enabled = true,
        silent = true, -- suppress "No information available" notifications
      },
    },
    presets = {
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
  },
}
