-- A plugin for AI programming assistant
-- Provides a UI for interacting with AI tools
-- Provides Next edit suggestions feature
vim.pack.add({
  "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
  "https://github.com/folke/sidekick.nvim",
})

vim.cmd.packadd("nvim-treesitter-textobjects")
vim.cmd.packadd("sidekick.nvim")

local sidekick = require("sidekick")

sidekick.setup({
  -- NES: next edit suggestion
  nes = {
    enabled = false,
    -- enabled = function(buf)
    --   local ft = vim.bo[buf].filetype
    --   local markdown = ft == "markdown"
    --   return vim.g.inline_completion_enabled and not markdown
    -- end,
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
        width = 80,
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
})

vim.keymap.set({ "i", "n" }, "<tab>", function()
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
end, { expr = true, desc = "Goto/Apply Next Edit Suggestion" })

vim.keymap.set("n", "<leader>an", function()
  require("sidekick.cli").toggle({
    name = "claude",
    focus = true,
  })
end, { desc = "Sidekick Toggle CLI" })

vim.keymap.set("x", "<leader>an", function()
  require("sidekick.cli").send({
    msg = "{selection}",
  })
end, { desc = "Send Visual Selection" })

vim.keymap.set("n", "<leader>at", function()
  local current_path = vim.fn.expand("%")
  require("sidekick.cli").send({
    msg = "@" .. current_path,
  })
end, { desc = "Send This" })

vim.keymap.set("x", "<leader>at", function()
  require("sidekick.cli").send({
    msg = "{this}",
  })
end, { desc = "Send This" })

vim.keymap.set("n", "<leader>as", function()
  require("sidekick.cli").select({
    filter = {
      installed = true,
    },
  })
end, { desc = "Select CLI" })

vim.keymap.set({ "n", "x" }, "<leader>ap", function()
  require("sidekick.cli").prompt()
end, { desc = "Sidekick Select Prompt" })

vim.keymap.set({ "n", "x", "i", "t" }, "<c-.>", function()
  require("sidekick.cli").focus()
end, { desc = "Sidekick Switch Focus" })
