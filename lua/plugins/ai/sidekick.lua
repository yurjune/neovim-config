-- A plugin for AI programming assistant
-- Provides a UI for interacting with AI tools
-- Provides Next edit suggestions feature
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
          width = 70,
          height = 20,
        },
        keys = {
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
