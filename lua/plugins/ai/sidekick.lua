-- A plugin for AI programming assistant
-- Provides a UI for interacting with AI tools
-- Provides Next edit suggestions feature
return {
  "folke/sidekick.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter-textobjects",
    after = "nvim-treesitter",
    requires = "nvim-treesitter/nvim-treesitter",
    branch = "master",
    -- branch = "main",  -- prepare for update.
  },
  lazy = false,
  opts = {
    -- NES: next edit suggestion
    nes = {
      enabled = false,
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
          width = 70,
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

    -- Auto enter insert mode when entering terminal buffer
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = vim.g.sidekick_buf_pattern,
      callback = function()
        vim.cmd("startinsert")
      end,
    })
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
