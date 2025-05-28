-- A plugin for debug
-- If .vscode/launch.json is present, nvim-dap will use it when dap.continue() is called.
return {
  "mfussenegger/nvim-dap",
  after = "dapui",
  event = "VeryLazy",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")

    dapui.setup({
      controls = {
        element = "repl",
        enabled = true,
        icons = {
          disconnect = "",
          pause = "",
          play = "",
          run_last = "",
          step_back = "",
          step_into = "",
          step_out = "",
          step_over = "",
          terminate = "",
        },
      },
      element_mappings = {},
      expand_lines = true,
      floating = {
        border = "rounded",
        mappings = {
          close = { "q", "<Esc>" },
        },
      },
      force_buffers = true,
      icons = {
        collapsed = "",
        current_frame = "",
        expanded = "",
      },
      layouts = {
        {
          elements = {
            { id = "scopes", size = 0.25 },
            { id = "breakpoints", size = 0.25 },
            { id = "watches", size = 0.25 },
            { id = "stacks", size = 0.25 },
          },
          position = "right",
          size = 65,
        },
        {
          elements = {
            { id = "repl", size = 0.5 },
            { id = "console", size = 0.5 },
          },
          position = "bottom",
          size = 10,
        },
      },
      mappings = {
        edit = "e",
        expand = { "x", "<CR>", "<2-LeftMouse>" },
        open = "o",
        remove = "d",
        repl = "r",
        toggle = "t",
      },
      render = {
        indent = 1,
        max_value_lines = 100,
      },
    })

    -- define signs and highlight
    local dap_signs = {
      {
        name = "DapBreakpoint",
        text = "⏺",
      },
      {
        name = "DapBreakpointCondition",
        text = "◉",
      },
      {
        name = "DapBreakpointRejected",
        text = "▶",
      },
      {
        name = "DapStopped",
        text = "⏹",
      },
      {
        name = "DapLogPoint",
        text = "◆",
      },
    }
    for _, sign in ipairs(dap_signs) do
      vim.fn.sign_define(sign.name, {
        text = sign.text,
        texthl = sign.name,
        linehl = sign.name,
        numhl = sign.name,
      })
    end

    dap.defaults.fallback.exception_breakpoints = { "uncaught" }
    for _, adapterType in ipairs({ "node", "chrome", "msedge" }) do
      local pwaType = "pwa-" .. adapterType

      dap.adapters[pwaType] = {
        type = "server",
        host = "localhost",
        port = "${port}",
        executable = {
          command = "node",
          args = {
            vim.fn.stdpath("data") .. "/mason/packages/js-debug-adapter/js-debug/src/dapDebugServer.js",
            "${port}",
          },
        },
      }

      -- this allow us to handle launch.json configurations
      -- which specify type as "node" or "chrome" or "msedge"
      dap.adapters[adapterType] = function(cb, config)
        local nativeAdapter = dap.adapters[pwaType]
        config.type = pwaType

        if type(nativeAdapter) == "function" then
          nativeAdapter(cb, config)
        else
          cb(nativeAdapter)
        end
      end
    end

    local enter_launch_url = function()
      local co = coroutine.running()
      return coroutine.create(function()
        vim.ui.input({ prompt = "Enter URL: ", default = "http://localhost:" }, function(url)
          if url == nil or url == "" then
            return
          else
            coroutine.resume(co, url)
          end
        end)
      end)
    end

    for _, language in ipairs({ "typescript", "javascript", "typescriptreact", "javascriptreact" }) do
      dap.configurations[language] = {
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file using Node.js (nvim-dap)",
          program = "${file}",
          cwd = "${workspaceFolder}",
        },
        {
          type = "pwa-node",
          request = "attach",
          name = "Attach to process using Node.js (nvim-dap)",
          processId = require("dap.utils").pick_process,
          cwd = "${workspaceFolder}",
        },
        -- requires ts-node to be installed globally or locally
        {
          type = "pwa-node",
          request = "launch",
          name = "Launch file using Node.js with ts-node/register (nvim-dap)",
          program = "${file}",
          cwd = "${workspaceFolder}",
          runtimeArgs = { "-r", "ts-node/register" },
        },
        {
          type = "pwa-chrome",
          request = "launch",
          name = "Launch Chrome (nvim-dap)",
          url = enter_launch_url,
          webRoot = "${workspaceFolder}",
          sourceMaps = true,
        },
        -- {
        --   type = "pwa-msedge",
        --   request = "launch",
        --   name = "Launch Edge (nvim-dap)",
        --   url = enter_launch_url,
        --   webRoot = "${workspaceFolder}",
        --   sourceMaps = true,
        -- },
      }
    end

    local convertArgStringToArray = function(config)
      local c = {}

      for k, v in pairs(vim.deepcopy(config)) do
        if k == "args" and type(v) == "string" then
          c[k] = require("dap.utils").splitstr(v)
        else
          c[k] = v
        end
      end

      return c
    end

    for key, _ in pairs(dap.configurations) do
      dap.listeners.on_config[key] = convertArgStringToArray
    end

    -- attach dapui events to dap
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    vim.keymap.set("n", "<leader>dab", dap.toggle_breakpoint, { desc = "Dap Toggle breakpoint" })
    vim.keymap.set("n", "<F5>", dap.continue, { desc = "Continue" })
    vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
    vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
    vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step out" })

    vim.keymap.set("n", "<leader>dat", dapui.toggle, { desc = "Toggle DAP UI" })
  end,
}
