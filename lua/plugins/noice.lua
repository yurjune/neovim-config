-- A plugin that replaces the UI for messages, cmdline and the popupmenu.
return {
  "folke/noice.nvim",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  -- presets > lsp_doc_border 가 빈번하게 적용되지 않는 경우가 있어 priority 를 높여 우선적으로 로드.
  priority = 900,
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
    presets = {
      lsp_doc_border = true, -- add a border to hover docs and signature help
    },
  },
}
