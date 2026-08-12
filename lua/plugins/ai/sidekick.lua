-- A plugin for AI programming assistant
-- Provides a UI for interacting with AI tools
-- Provides Next edit suggestions feature

local layout = require("ui.layout")

return {
  "folke/sidekick.nvim",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
      dependencies = { "nvim-treesitter/nvim-treesitter" },
    },
  },
  lazy = false,
  opts = {
    nes = {
      enabled = false,
    },
    cli = {
      watch = true, -- notify Neovim of file changes done by AI CLI tools
      mux = {
        backend = "tmux",
        enabled = true,
      },
      win = {
        layout = "right",
        split = {
          width = layout.sidekick,
        },
        keys = {
          prompt = { "<c-p>", "prompt" }, -- insert prompt or context
          -- Ghostty's custom mapping sends `\n` for Shift-Enter.
          -- Neovim treats `\n` as <C-j>, which Sidekick maps to `nav_down`.
          -- This triggers unintended downward window navigation instead of inserting a newline.
          -- Disable `nav_down` to avoid the conflict.
          nav_down = false,
        },
      },
      prompts = {
        -- example = "add your custom prompt here"
      },
      context = {},
    },
  },
  config = function(_, opts)
    require("sidekick").setup(opts)

    -- Sidekick은 폭을 지정해 열면 equalalways가 적용되지 않으므로, 고정 폭을 유지하면서 나머지 창을 수동으로 균등화한다.
    vim.api.nvim_create_autocmd({ "BufWinEnter", "WinClosed" }, {
      desc = "Equalize editor windows when Sidekick opens or closes",
      group = vim.api.nvim_create_augroup("sidekick-layout", { clear = true }),
      callback = function(args)
        local buf

        if args.event == "WinClosed" then
          local win = tonumber(args.match)
          if win and vim.api.nvim_win_is_valid(win) then
            buf = vim.api.nvim_win_get_buf(win)
          end
        else
          buf = args.buf
        end

        if not buf or vim.bo[buf].filetype ~= vim.g.sidekick_buf_filetype then
          return
        end

        -- Sidekick이 split을 연 뒤 winfixwidth를 설정하므로 다음 이벤트 루프에서 실행한다.
        vim.schedule(function()
          vim.cmd("wincmd =")
        end)
      end,
    })
  end,
  keys = {
    {
      "<leader>an",
      function()
        require("sidekick.cli").toggle({
          name = "codex",
          focus = true,
        })
      end,
      desc = "Sidekick Toggle CLI",
      mode = { "n" },
    },
    {
      "<leader>an",
      function()
        require("sidekick.cli").send({
          msg = "{selection}",
        })
      end,
      desc = "Send Visual Selection",
      mode = { "x" },
    },
    {
      "<leader>at",
      function()
        local current_path = vim.fn.expand("%")
        require("sidekick.cli").send({
          msg = "@" .. current_path,
        })
      end,
      mode = { "n" },
      desc = "Send This",
    },
    {
      "<leader>at",
      function()
        require("sidekick.cli").send({
          msg = "{this}",
        })
      end,
      mode = { "x" },
      desc = "Send This",
    },
    {
      "<leader>as",
      function()
        require("sidekick.cli").select({
          filter = {
            installed = true,
          },
        })
      end,
      desc = "Select CLI",
    },
    {
      "<leader>ap",
      function()
        require("sidekick.cli").prompt()
      end,
      mode = { "n", "x" },
      desc = "Sidekick Select Prompt",
    },
    {
      "<c-.>",
      function()
        require("sidekick.cli").focus()
      end,
      mode = { "n", "x", "i", "t" },
      desc = "Sidekick Switch Focus",
    },
  },
}
