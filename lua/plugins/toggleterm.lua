-- A plugin to persist and toggle multiple terminals during an editing session
-- terminal mode -> normal mode => <C-\><C-n>
-- normal mode -> terminal mode => i or a
return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 16,

        open_mapping = [[<c-`>]], -- 숫자 + 단축키로 여러 터미널 세션을 관리할 수 있다.
        insert_mappings = true, -- 노말 모드에서도 토글이 작동하게 할지 여부
        terminal_mappings = true,
        start_in_insert = true,

        persist_size = true,
        persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered

        direction = "horizontal", -- 'vertical' | 'horizontal' | 'tab' | 'float'

        -- This field is only relevant if direction is set to 'float'
        float_opts = {
          border = "curved",
        },
      })
    end,
  },
}
