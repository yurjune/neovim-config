-- A plugin to persist and toggle multiple terminals during an editing session
local layout = require("ui.layout")

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
        width = layout.toggleterm.width,
        height = layout.toggleterm.height,
      },
    })

    local Terminal = require("toggleterm.terminal").Terminal

    local function find_local_test_runner(name, file)
      local dir = vim.fs.dirname(vim.fs.normalize(file))

      while dir do
        local executable = vim.fs.joinpath(dir, "node_modules", ".bin", name)
        if vim.fn.executable(executable) == 1 then
          return executable, dir
        end

        local parent = vim.fs.dirname(dir)
        if parent == dir then
          break
        end
        dir = parent
      end
    end

    local function run_current_test(name, args)
      local file = vim.fn.expand("%:p")
      local executable, project_dir = find_local_test_runner(name, file)

      if not executable then
        vim.notify(("Could not find a local %s executable"):format(name), vim.log.levels.ERROR)
        return
      end

      local command = { executable, file }
      vim.list_extend(command, args or {})
      for index, value in ipairs(command) do
        command[index] = vim.fn.shellescape(value)
      end

      Terminal:new({
        cmd = table.concat(command, " "),
        dir = project_dir,
        close_on_exit = false,
        direction = "float",
      }):toggle()
    end

    vim.api.nvim_create_user_command("JestCurrentFile", function()
      run_current_test("jest")
    end, { desc = "[Jest] Run test current file" })

    vim.api.nvim_create_user_command("JestCurrentFileCoverage", function()
      run_current_test("jest", { "--coverage" })
    end, { desc = "[Jest] Get test coverage of current file" })

    vim.api.nvim_create_user_command("VitestCurrentFile", function()
      run_current_test("vitest")
    end, { desc = "[Vitest] Run test current file" })

    vim.api.nvim_create_user_command("VitestCurrentFileCoverage", function()
      run_current_test("vitest", { "--coverage" })
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
