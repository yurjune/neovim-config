-- A plugin to explore files with tree ui
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
        centralize_selection = true, -- 파일을 찾을 때 해당 항목을 중앙에 배치
      },
      update_focused_file = {
        enable = true, -- 현재 파일에 따라 트리를 자동으로 업데이트
        ignore_list = { -- not working...
          -- "^node_modules$",
          "^dist$",
          "^build$",
          "^\\.git$",
        },
      },
      -- 파일 트리에 표시하지 않을 파일 지정
      filters = {
        custom = {
          ".DS_Store",
          -- "^node_modules$",
          "^dist$",
          "^build$",
          "^\\.git$",
        },
        exclude = {}, -- 필터에서 제외할 파일/폴더
      },
      git = {
        ignore = false, -- false 이면 git 이 무시하는 파일도 표시
      },
      renderer = {
        indent_markers = {
          enable = true,
        },
        indent_width = 1,
        icons = {
          glyphs = {
            folder = {
              arrow_closed = "", -- arrow when folder is closed
              arrow_open = "", -- arrow when folder is open
            },
          },
        },
      },
      actions = {
        open_file = {
          window_picker = {
            enable = false, -- false 이면 새 파일 열람시 현재 활성화된 창에서 열람
          },
        },
      },
    })

    local function set_tree_width(width)
      return function()
        -- 현재 열려있는 nvim-tree 창 찾기
        for _, win in pairs(vim.api.nvim_list_wins()) do
          local buf = vim.api.nvim_win_get_buf(win)
          local buf_name = vim.api.nvim_buf_get_name(buf)

          -- nvim-tree 버퍼 확인하고 크기 변경
          if string.match(buf_name, "NvimTree") then
            vim.api.nvim_win_set_width(win, width)
          end
        end

        -- 열려있지 않더라도 너비를 적용
        treeview.View.width = width
      end
    end

    -- e means explore
    vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle nvim tree" })
    vim.keymap.set("n", "<leader>ef", "<cmd>NvimTreeFocus<CR>", { desc = "Focus nvim tree" })

    vim.keymap.set("n", "<leader>e1", set_tree_width(42), { desc = "NvimTree width 42" })
    vim.keymap.set("n", "<leader>e2", set_tree_width(50), { desc = "NvimTree width 50" })
    vim.keymap.set("n", "<leader>e3", set_tree_width(60), { desc = "NvimTree width 60" })
  end,
}
