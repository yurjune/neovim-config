-- A plugin to persist and toggle multiple terminals during an editing session
return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      size = 22,
      persist_size = true,
      persist_mode = false, -- if set to true (default) the previous terminal mode will be remembered

      direction = "float", -- 'vertical' | 'horizontal' | 'tab' | 'float'
      float_opts = {
        border = "curved",
        width = 180,
        height = 45,
      },
    })

    local Terminal = require("toggleterm.terminal").Terminal
    vim.api.nvim_create_user_command("JestCurrentFile", function()
      Terminal:new({
        cmd = "npx jest " .. vim.fn.shellescape(vim.fn.expand("%")),
        close_on_exit = false,
        direction = "float",
      }):toggle()
    end, { desc = "[Jest] Run test current file" })

    vim.api.nvim_create_user_command("JestCurrentFileCoverage", function()
      Terminal:new({
        cmd = "npx jest " .. vim.fn.shellescape(vim.fn.expand("%")) .. " --coverage",
        close_on_exit = false,
        direction = "float",
      }):toggle()
    end, { desc = "[Jest] Get test coverage of current file" })

    vim.api.nvim_create_user_command("VitestCurrentFile", function()
      Terminal:new({
        cmd = "npx vitest " .. vim.fn.shellescape(vim.fn.expand("%")),
        close_on_exit = false,
        direction = "float",
      }):toggle()
    end, { desc = "[Vitest] Run test current file" })

    vim.api.nvim_create_user_command("VitestCurrentFileCoverage", function()
      Terminal:new({
        cmd = "npx vitest " .. vim.fn.shellescape(vim.fn.expand("%")) .. " --coverage",
        close_on_exit = false,
        direction = "float",
      }):toggle()
    end, { desc = "[Vitest] Get test coverage of current file" })

    local function get_project_root()
      -- Prefer VCS/project markers, fall back to cwd.
      local root = vim.fs.root(0, { ".git", "package.json", "pyproject.toml", "go.mod", "Cargo.toml" })
      return root or vim.fn.getcwd()
    end

    local function tmux_session_name(root)
      local base = vim.fs.basename(root)
      local hash = vim.fn.sha256(root):sub(1, 8)
      return ("toggle_%s_%s"):format(base, hash)
    end

    local tmux_terms_by_root = {}

    local function toggle_tmux_session()
      local root = get_project_root()
      local term = tmux_terms_by_root[root]
      if not term then
        term = Terminal:new({
          cmd = "tmux new -A -s " .. tmux_session_name(root),
          dir = root,
          close_on_exit = false,
          direction = "float",
        })
        tmux_terms_by_root[root] = term
      end
      term:toggle()
    end

    -- override default C-g keymap
    vim.keymap.set({ "n", "t" }, "<C-g>", toggle_tmux_session, { desc = "Toggle tmux session in toggleterm" })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "rust",
      callback = function()
        vim.keymap.set("n", "<leader>cb", function()
          Terminal:new({
            cmd = "cargo run",
            close_on_exit = false,
            direction = "float",
          }):toggle()
        end, { desc = "Cargo run", buffer = true })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "c",
      callback = function()
        vim.keymap.set("n", "<leader>cb", function()
          local dir = vim.fn.expand("%:p:h")
          Terminal
            :new({
              cmd = string.format("cd %s && gcc *.c && ./a.out && rm a.out", vim.fn.shellescape(dir)),
              close_on_exit = false,
              direction = "float",
            })
            :toggle()
        end, { desc = "Compile current dir and run program", buffer = true })
      end,
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "cpp",
      callback = function()
        vim.keymap.set("n", "<leader>cb", function()
          local dir = vim.fn.expand("%:p:h")
          Terminal:new({
            cmd = string.format(
              "cd %s && g++ -std=c++20 %s && ./a.out && rm a.out",
              vim.fn.shellescape(dir),
              vim.fn.expand("%:p")
            ),
            close_on_exit = false,
            direction = "float",
          }):toggle()
        end, { desc = "Compile current dir and run program", buffer = true })
      end,
    })
  end,
}
