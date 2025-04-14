return {
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  config = function()
    local function execute_cmd(cmd)
      local handle = io.popen(cmd) -- execute command
      if not handle then
        return nil
      end
      local result = handle:read("*a") -- read output
      handle:close()
      result = result:gsub("^%s*(.-)%s*$", "%1") -- trim whitespace
      return result
    end

    require("codecompanion").setup({
      adapters = {
        anthropic = function()
          return require("codecompanion.adapters").extend("anthropic", {
            env = {
              api_key = execute_cmd("echo $ANTHROPIC_API_KEY"),
              model = "claude-3-7-sonnet-20250219",
            },
          })
        end,
        openai = function()
          return require("codecompanion.adapters").extend("openai", {
            env = {
              api_key = execute_cmd("echo $OPENAI_API_KEY"),
              model = "gpt-4o",
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "openai",
        },
        inline = {
          adapter = "openai",
          keymaps = {
            accept_change = {
              modes = { n = "ga" },
              description = "Accept the suggested change",
            },
            reject_change = {
              modes = { n = "gr" },
              description = "Reject the suggested change",
            },
          },
        },
      },
      opts = {
        system_prompt = function()
          return "I'm frontend dev using typescript and react. I prefer short and concise answers."
        end,
      },
      display = {
        chat = {
          auto_scroll = true,
          show_header_separator = true, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
          separator = "─", -- The separator between the different messages in the chat buffer
          show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
          show_settings = true, -- Show LLM settings at the top of the chat buffer?
          show_token_count = true, -- Show the token count for each response?
          start_in_insert_mode = true, -- Open the chat buffer in insert mode?
        },
        inline = {
          layout = "vertical", -- vertical|horizontal|buffer
        },
        -- Options to customize the UI of the chat buffer
        window = {
          layout = "vertical", -- float|vertical|horizontal|buffer
          position = nil, -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
          border = "single",
          height = 0.8,
          width = 0.45,
          relative = "editor",
          full_height = true, -- when set to false, vsplit will be used to open the chat buffer vs. botright/topleft vsplit
          opts = {
            breakindent = true,
            cursorcolumn = false,
            cursorline = false,
            foldcolumn = "0",
            linebreak = true,
            list = false,
            numberwidth = 1,
            signcolumn = "no",
            spell = false,
            wrap = true,
          },
        },
        diff = {
          enabled = true,
          provider = "default", -- default|mini_diff
          close_chat_at = 240, -- Close an open chat buffer if the total columns of your display are less than...
          layout = "vertical", -- vertical|horizontal split for default provider
          opts = {
            "internal",
            "filler",
            "closeoff",
            "algorithm:patience",
            "followwrap",
            "linematch:120",
          },
        },
      },
    })

    local keymap = vim.keymap

    keymap.set("n", "<Leader>cc", "<cmd>CodeCompanionChat<CR>", { desc = "CodeCompanion chat" })
    keymap.set("n", "<Leader>ca", "<cmd>CodeCompanionActions<CR>", { desc = "CodeCompainon actions" })

    keymap.set("v", "<Leader>ci", ":CodeCompanion", { desc = "CodeCompainon inline" })
    keymap.set("v", "<Leader>cr", "<cmd>CodeCompanion refactor<CR>", { desc = "CodeCompainon refactor selected" })
  end,
}
