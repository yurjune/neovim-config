-- A plugin that replaces the UI for messages, cmdline and the popupmenu.
return {
  "folke/noice.nvim",
  dependencies = {
    -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    "rcarriga/nvim-notify",
  },
  event = "VeryLazy",
  opts = {
    cmdline = {
      enabled = true,
      view = "cmdline_popup", -- cmdline, cmdline_popup
      format = {
        search_down = { icon = "v" },
        search_up = { icon = "^" },
      },
    },
    -- 전통적인 vim 의 시스템 메시지
    messages = {
      enabled = true,
      view = "notify", -- notify, mini, virtualtext, popup, messages, split
      view_error = "notify", -- view for errors
    },
    -- vim.notify 함수를 통해 전송되는 알림을 처리
    notify = {
      enabled = true,
      view = "notify", -- notify, mini, split, popup, hover
    },
    popupmenu = {
      enabled = true,
      backend = "nui", -- backend to use to show regular cmdline completions (cmp or nui)
      kind_icons = {}, -- set to `false` to disable icons
    },
    lsp = {
      -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
      },
    },
    views = {
      cmdline_popup = {
        size = {
          height = 1, -- line numbers
        },
      },
    },
  },
}
