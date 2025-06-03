-- A plugin for customizing statusline of neovim
-- status: current mode, current file name, and more
return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    -- configure lualine with modified theme
    lualine.setup({
      options = {
        theme = "catppuccin",
      },

      -- sections: a,b,c,x,y,z 총 6개의 섹션
      -- 한 섹션은 여러개의 컴포넌트로 구성
      -- lualine_a: 모드 표시 (e.g. NORMAL)
      -- lualine_b: 브랜치, diff 정보 등
      -- lualine_c: 파일 경로, 파일명 등
      -- lualine_x: 인코딩, 파일 형식, 파일 타입 등
      -- lualine_y: 진행 상태
      -- lualine_z: 행/열 위치
      sections = {
        lualine_c = {
          {
            "filename",
            path = 1, -- If 1, relative path is shown
            shorting_target = 40, -- 경로가 길 경우 줄이는 기준 길이
          },
        },
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
        },
      },
      extensions = {},
    })
  end,
}
