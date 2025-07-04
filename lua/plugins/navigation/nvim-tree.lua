-- A plugin to explore files with tree ui
-- Type g? in tree buffer to see all key mappings
return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")
    local treeview = require("nvim-tree.view")

    vim.g.loaded_netrw = 1 -- deactivate netrw which is neovim default explorer
    vim.g.loaded_netrwPlugin = 1 -- deactivate netrw extensions

    nvimtree.setup({
      view = {
        width = 42,
        relativenumber = true,
        centralize_selection = true, -- reposition the view so that the current node is initially centralized
        side = "left",
        signcolumn = "no",
        cursorline = true,
        preserve_window_proportions = false, -- If `false`, the height and width of windows other than nvim-tree will be equalized.
      },
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      filters = {
        custom = {
          ".DS_Store",
          "^node_modules$",
          "^dist$",
          "^build$",
          "^\\.git$",
        },
        exclude = {},
        dotfiles = false, -- If false, expose hidden files
      },
      tab = {
        -- all tabs share the same nvim-tree instance
        sync = {
          open = true,
          close = true,
        },
      },
      git = {
        enable = true,
        show_on_dirs = true, -- if false, always hide icon of directory
        show_on_open_dirs = true, -- if false, hide icon of directory if directory is open
      },
      actions = {
        open_file = {
          quit_on_open = false, -- close nvim-tree when file is opened
          resize_window = true, -- default true
          window_picker = {
            enable = true,
            -- pick the previous window when open file
            picker = function()
              local prev_winnr = vim.fn.winnr("#")
              local prev_winid = vim.fn.win_getid(prev_winnr)
              local prev_bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(prev_winid))

              -- If previous window is nvim-tree, find another window
              if prev_bufname:match("NvimTree") then
                for winnr = 1, vim.fn.winnr("$") do
                  local winid = vim.fn.win_getid(winnr)
                  local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(winid))
                  if not bufname:match("NvimTree") then
                    return winid
                  end
                end
              end

              return prev_winid
            end,
          },
        },
        remove_file = {
          close_window = true, -- close window on remove file in nvim-tree
        },
        change_dir = {
          -- If enabled, change the cwd when changing directories in the tree. (ex. C-])
          enable = false,
          global = false, -- Use `:cd` instead of `:lcd` when changing directories.
          restrict_above_cwd = false, -- if true, change to parent directory above cwd disabled
        },
      },
      renderer = {
        indent_markers = {
          enable = true,
        },
        indent_width = 1,
        icons = {
          git_placement = "before",
          modified_placement = "after",
          hidden_placement = "after",
          diagnostics_placement = "signcolumn",
          bookmarks_placement = "signcolumn",
          glyphs = {
            folder = {
              arrow_closed = "", -- arrow when folder is closed
              arrow_open = "", -- arrow when folder is open
            },
          },
        },
      },

      -- sync root when Dirchange event occurs (ex. :cd command)
      sync_root_with_cwd = true, -- default false
      -- reload nvim-tree on BufEnter nvim-tree
      -- this option can cause performance issues, so use filesystem_watchers instead
      -- filesystem_watchers disables BufEnter event on nvim-tree for optimization
      reload_on_bufenter = false, -- default false
      -- observe filesystem changes and apply changes to nvim-tree
      filesystem_watchers = {
        enable = true,
      },
    })

    local function set_tree_width(width)
      return function()
        -- find nvim-tree buf then adjust width
        for _, win in pairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)

          if string.match(buf_name, "NvimTree") then
            vim.api.nvim_win_set_width(win, width)
          end
        end

        -- Apply width even if nvim-tree is hidden
        treeview.View.width = width
      end
    end

    local function toggle_focus_tree()
      local current_buf = vim.api.nvim_get_current_buf()
      local buf_name = vim.api.nvim_buf_get_name(current_buf)
      if string.match(buf_name, "NvimTree") then
        vim.cmd("wincmd p") -- return to previous window
      else
        vim.cmd("NvimTreeFocus")
      end
    end

    local function toggle_tree_keep_focus()
      local prev_win = vim.api.nvim_get_current_win()
      local tree_is_open = require("nvim-tree.view").is_visible()

      vim.cmd("NvimTreeToggle")

      -- If tree is opened, focus the previous window
      if not tree_is_open and vim.api.nvim_win_is_valid(prev_win) then
        vim.schedule(function()
          pcall(vim.api.nvim_set_current_win, prev_win)
        end)
      end
    end

    vim.keymap.set({ "n", "v" }, "<D-e>", toggle_focus_tree, { desc = "Toggle focus nvim tree" })
    vim.keymap.set({ "n", "v" }, "<M-e>", toggle_focus_tree, { desc = "Toggle focus nvim tree" })
    vim.keymap.set({ "n", "v" }, "<D-b>", toggle_tree_keep_focus, { desc = "Toggle nvim tree" })
    vim.keymap.set({ "n", "v" }, "<M-b>", toggle_tree_keep_focus, { desc = "Toggle nvim tree" })

    vim.keymap.set("n", "<leader>e1", set_tree_width(42), { desc = "NvimTree width 42" })
    vim.keymap.set("n", "<leader>e2", set_tree_width(50), { desc = "NvimTree width 50" })
    vim.keymap.set("n", "<leader>e3", set_tree_width(60), { desc = "NvimTree width 60" })
  end,
}
