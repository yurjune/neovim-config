-- A plugin for preview color: hex code, rgb(), etc.
return {
  "norcalli/nvim-colorizer.lua",
  lazy = false,
  config = function()
    require("colorizer").setup({
      "*", --  모든 파일 형식에 대해 색상 표시
    })
  end,
}
