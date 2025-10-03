return {
  "olimorris/codecompanion.nvim",
  enabled = true,
  event = "VeryLazy",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "MeanderingProgrammer/render-markdown.nvim",
      ft = { "markdown", "codecompanion" },
    },
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

    local adapters = require("codecompanion.adapters")

    -- NOTE: Change adapter here
    local current_adapter = "openai"

    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = current_adapter,
          keymaps = {
            send = {
              modes = { n = "<Enter>", i = "<C-s>" },
              description = "Send the current chat message",
            },
            -- If you close the chat buffer, you can not see it again
            close = {
              modes = { n = "<Nop>", i = "<Nop>" },
              description = "Close the chat buffer",
            },
          },
        },
        cmd = {
          adapter = current_adapter,
        },
        inline = {
          adapter = current_adapter,
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
      adapters = {
        http = {
          copilot = function()
            return adapters.extend("copilot", {
              schema = {
                model = {
                  default = "gpt-4.1-2025-04-14",
                },
              },
            })
          end,
          openai = function()
            return adapters.extend("openai", {
              env = {
                api_key = execute_cmd("echo $OPENAI_API_KEY"),
              },
              schema = {
                model = {
                  default = "gpt-4.1-2025-04-14",
                },
              },
            })
          end,
          anthropic = function()
            return adapters.extend("anthropic", {
              env = {
                api_key = execute_cmd("echo $ANTHROPIC_API_KEY"),
              },
              schema = {
                model = {
                  default = "claude-sonnet-4-20250514",
                },
                temperature = {
                  -- If you want more creative responses, increase this value
                  -- Recommended for coding: 0 ~ 0.3
                  default = 0.1,
                },
                extended_thinking = {
                  default = false,
                },
                top_p = { -- 누적 확률 샘플링
                  -- Consider only the most certain 10% of tokens (very conservative)
                  -- default is null
                  -- default = 0.1,
                },
                thinking_budget = {
                  default = 16000,
                },
              },
            })
          end,
          llama3 = function()
            return adapters.extend("ollama", {
              name = "llama3", -- Give this adapter a different name to differentiate it from the default ollama adapter
              schema = {
                model = {
                  default = "llama3:latest",
                },
                num_ctx = {
                  default = 16384,
                },
                num_predict = {
                  default = -1,
                },
              },
            })
          end,
          opts = {
            language = "Korean", -- default system prompt includes this
            send_code = true, -- If false, the code will not be sent to the LLM
            -- system_prompt = function()
            --   return ""
            -- end,
          },
        },
      },
      display = {
        chat = {
          intro_message = "Welcome to CodeCompanion ✨! Press ? for options",
          auto_scroll = true,
          show_header_separator = true, -- Show header separators in the chat buffer? Set this to false if you're using an external markdown formatting plugin
          separator = "─", -- The separator between the different messages in the chat buffer
          show_references = true, -- Show references (from slash commands and variables) in the chat buffer?
          show_settings = true, -- Show LLM settings at the top of the chat buffer?
          show_token_count = true, -- Show the token count for each response?
          start_in_insert_mode = true, -- Open the chat buffer in insert mode?
          variables = {
            ["my_var"] = {
              ---Ensure the file matches the CodeCompanion.Variable class
              ---@return string|fun(): nil
              callback = "/Users/Jerry/Code/test.py",
              description = "Explain what my_var does",
              opts = {
                contains_code = true,
              },
            },
          },

          -- Chat buffer commands:
          -- `Variables`, accessed via `#`, contain data about the present state of Neovim:
          -- `Slash commands`, accessed via `/`, run commands to insert additional context into the chat buffer:
          -- `Tools`, accessed via `@`, allow the LLM to function as an agent and carry out actions:
        },
        inline = {
          layout = "vertical", -- vertical|horizontal|buffer
        },
        -- Options to customize the UI of the chat buffer
        window = {
          layout = "vertical", -- float|vertical|horizontal|buffer
          position = "right", -- left|right|top|bottom (nil will default depending on vim.opt.plitright|vim.opt.splitbelow)
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
        action_palette = {
          width = 95,
          height = 10,
          prompt = "Prompt ", -- Prompt used for interactive LLM calls
          provider = "telescope", -- can be default
          opts = {
            show_default_actions = true, -- Show the default actions in the action palette?
            show_default_prompt_library = true, -- Show the default prompt library in the action palette?
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

    -- local function open_new_chat_when_in_chat()
    --   if vim.bo.filetype == "codecompanion" then
    --     vim.cmd("CodeCompanionChat")
    --   end
    -- end

    local keymap = vim.keymap

    keymap.set("n", "<Leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "CodeCompanion toggle" })
    keymap.set("n", "<Leader>cn", "<cmd>CodeCompanionChat<CR>", { desc = "CodeCompanion new chat" })
    -- keymap.set({ "n", "v", "i" }, "<D-i>", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "CodeCompanion toggle" })
    -- keymap.set({ "n", "v", "i" }, "<M-i>", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "CodeCompanion toggle" })
    -- keymap.set({ "n", "v", "i" }, "<D-n>", open_new_chat_when_in_chat, { desc = "CodeCompanion new chat" })
    -- keymap.set({ "n", "v", "i" }, "<M-n>", open_new_chat_when_in_chat, { desc = "CodeCompanion new chat" })

    keymap.set("n", "<Leader>ca", "<cmd>CodeCompanionActions<CR>", { desc = "CodeCompanion actions" })

    keymap.set("v", "<Leader>ci", ":CodeCompanion ", { desc = "CodeCompanion inline" })
  end,
}
