return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local rm = require("render-markdown")

    rm.setup({
      enabled = true,
      debounce = 20, -- reduce debounce ms for proper render on fast current line move
      render_modes = { "n", "c", "t", "i", "v", "V" },
      completions = {
        lsp = {
          enabled = true,
        },
      },
      win_options = {
        conceallevel = {
          default = vim.o.conceallevel,
          rendered = 2,
        },
        -- Neovim 자체 conceal 쿼리로 처리되는 요소(ex. bold, inline code)에 대한 conceal 여부를 결정
        concealcursor = {
          default = vim.o.concealcursor,
          rendered = "nc",
        },
      },
      latex = {
        enabled = false,
      },
      heading = {
        position = "overlay",
        -- icons = { "󰼏 ", "󰼐 ", "󰼑 ", "󰼒 ", "󰼓 ", "󰼔 " },
        icons = { "█ ", "▓ ", "▒ ", "░ ", "▪ ", "·" },
      },
      code = {
        enabled = true,
        -- Determines how the top / bottom of code block are rendered.
        border = "thick",
        width = "full", -- block | full
        -- Turn on / off inline code related rendering.
        inline = true,
        -- Padding to add to the left & right of inline code.
        -- inline_pad = 1, -- set padding 1 for ` char space
      },
      -- render-markdown이 생성한 요소(ex. heading)에 대한 conceal 여부를 결정
      anti_conceal = {
        enabled = true,
      },
    })

    vim.api.nvim_set_hl(0, "RenderMarkdownCode", {
      bg = "#26231c",
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        vim.keymap.set(
          "n",
          "<leader>mt",
          rm.buf_toggle,
          { desc = "Markdown render toggle", buffer = ev.buf, noremap = true }
        )
      end,
    })
  end,
}
