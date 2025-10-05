return {
  "folke/sidekick.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
    requires = "nvim-treesitter/nvim-treesitter",
  },
  lazy = false,
  opts = {
    -- NES: next edit suggestion
    nes = {
      debounce = 50,
      trigger = {
        events = { "InsertLeave", "TextChanged", "User SidekickNesDone" },
      },
      clear = {
        events = { "TextChangedI", "TextChanged", "BufWritePre", "InsertEnter" },
        esc = true, -- clear next edit suggestions when pressing <Esc>
      },
      diff = {
        inline = "words",
      },
    },
    -- Work with AI cli tools directly from within Neovim
    cli = {
      watch = true, -- notify Neovim of file changes done by AI CLI tools
      mux = {
        backend = "tmux",
        enabled = true,
      },
      win = {
        layout = "right",
        split = {
          width = 100,
          height = 20,
        },
        keys = {
          hide_n = { "q", "hide", mode = "n" }, -- hide the terminal window in normal mode
          hide_t = { "<c-q>", "hide" }, -- hide the terminal window in terminal mode
          win_p = { "<c-w>p", "blur" }, -- leave the cli window
          prompt = { "<c-p>", "prompt" }, -- insert prompt or context
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
  end,
  keys = {
    {
      "<tab>",
      function()
        -- if there is a next edit, jump to it, otherwise apply it if any
        if require("sidekick").nes_jump_or_apply() then
          return -- jumped or applied
        end

        -- if you are using Neovim's native inline completions
        if vim.lsp.inline_completion.get() then
          return
        end

        -- fall back to normal tab
        return "<tab>"
      end,
      mode = { "i", "n" },
      expr = true,
      desc = "Goto/Apply Next Edit Suggestion",
    },
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle({
          name = "claude",
          focus = true,
        })
      end,
      desc = "Sidekick Toggle CLI",
      mode = { "n" },
    },
    {
      "<leader>aa",
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
        require("sidekick.cli").send({
          msg = "{this}",
        })
      end,
      mode = { "n" },
      desc = "Send This",
    },
    {
      "<leader>at",
      function()
        require("sidekick.cli").send({
          msg = "{this}\n{selection}",
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
