return {
  "MeanderingProgrammer/render-markdown.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local rm = require("render-markdown")

    -- 커서가 놓인 줄에서 원본 마크업(**, [ ] 등)을 드러낼지 여부. <leader>mr로 전환한다.
    local reveal = true

    local opts = {
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
          rendered = "", -- reveal 값에 따라 ""(노출) / "nc"(은닉)로 바뀐다
        },
      },
      latex = {
        enabled = false,
      },
      sign = {
        priority = 5, -- lower than gitsigns' default sign_priority (6)
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
      -- render-markdown이 생성한 요소(ex. heading, checkbox)에 대한 conceal 여부를 결정
      anti_conceal = {
        enabled = true, -- reveal 값에 따라 바뀐다
      },
    }

    rm.setup(opts)

    -- setup()은 버퍼 캐시와 extmark를 비우므로, 열려 있는 버퍼에 반영하려면 다시 렌더링해야 한다.
    local function toggle_reveal()
      reveal = not reveal
      opts.win_options.concealcursor.rendered = reveal and "" or "nc"
      opts.anti_conceal.enabled = reveal
      rm.setup(opts)
      rm.enable()
    end

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

        vim.keymap.set(
          "n",
          "<leader>mr",
          toggle_reveal,
          { desc = "Markdown raw markup reveal toggle", buffer = ev.buf, noremap = true }
        )
      end,
    })
  end,
}
