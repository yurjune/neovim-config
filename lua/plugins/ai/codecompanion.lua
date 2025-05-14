return {
  "olimorris/codecompanion.nvim",
  enabled = true,
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
    local current_adapter = "llama3"

    require("codecompanion").setup({
      strategies = {
        chat = {
          adapter = current_adapter,
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
              -- api_key = execute_cmd("op read op://Private/OPENAI_API_KEY/name/firstname --no-newline"),
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
              -- api_key = execute_cmd("op read op://Private/ANTHROPIC_API_KEY/name/firstname --no-newline"),
              api_key = execute_cmd("echo $ANTHROPIC_API_KEY"),
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
      },
      opts = {
        language = "Korean", -- check if it works
        system_prompt = function()
          return ""
          -- return "I'm frontend dev using typescript and react. I prefer short and concise answers."
        end,
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
          start_in_insert_mode = false, -- Open the chat buffer in insert mode?
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
          enabled = false,
          provider = "mini_diff", -- default|mini_diff
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

    keymap.set("n", "<Leader>cc", "<cmd>CodeCompanionChat Toggle<CR>", { desc = "CodeCompanion toggle" })
    keymap.set("n", "<Leader>cn", "<cmd>CodeCompanionChat<CR>", { desc = "CodeCompanion new chat" })
    keymap.set("n", "<Leader>ca", "<cmd>CodeCompanionActions<CR>", { desc = "CodeCompanion actions" })

    keymap.set("v", "<Leader>ci", ":CodeCompanion ", { desc = "CodeCompanion inline" })
    keymap.set("v", "<Leader>cr", "<cmd>CodeCompanion refactor<CR>", { desc = "CodeCompanion refactor" })
    keymap.set("v", "<Leader>ce", "<cmd>CodeCompanion /explain<CR>", { desc = "CodeCompanion explain" })
    keymap.set("v", "<Leader>cf", "<cmd>CodeCompanion /fix<CR>", { desc = "CodeCompanion fix" })
  end,
}
