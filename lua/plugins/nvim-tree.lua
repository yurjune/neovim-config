return {
  "nvim-tree/nvim-tree.lua",
  dependencies = "nvim-tree/nvim-web-devicons",
  config = function()
    local nvimtree = require("nvim-tree")

    -- recommended settings from nvim-tree documentation
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    nvimtree.setup({
      view = {
        width = 35,
        relativenumber = true,
        centralize_selection = true, -- 파일을 찾을 때 해당 항목을 중앙에 배치
      },
      update_focused_file = {
        enable = true, -- 현재 파일에 따라 트리를 자동으로 업데이트
        update_cwd = true, -- 현재 작업 디렉토리도 함께 업데이트 (선택사항)
        ignore_list = {}, -- 무시할 파일 타입 목록
      },
      filters = {
        custom = { ".DS_Store" },
      },
      git = {
        ignore = false,
      },
      -- change folder arrow icons
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
      -- disable window_picker for
      -- explorer to work well with
      -- window splits
      actions = {
        open_file = {
          window_picker = {
            enable = false,
          },
        },
      },
    })

    -- e means explore
    vim.keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    vim.keymap.set(
      "n",
      "<leader>ef",
      "<cmd>NvimTreeFindFileToggle<CR>",
      { desc = "Toggle file explorer on current file" }
    )
  end,
}
