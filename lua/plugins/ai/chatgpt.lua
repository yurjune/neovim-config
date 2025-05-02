return {
  "jackMort/ChatGPT.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "nvim-lua/plenary.nvim",
    "folke/trouble.nvim", -- optional
    "nvim-telescope/telescope.nvim",
  },
  config = function()
    require("chatgpt").setup({
      async_api_key_cmd = "op read op://Private/OPENAI_API_KEY/name/firstname --no-newline",
      openai_params = {
        -- model can be a function which returns model
        -- model = "gpt-4.1",
        -- model = "gpt-3.5-turbo",
        model = "gpt-4.1-2025-04-14",
        frequency_penalty = 0, -- 텍스트 생성 시 반복 방지
        presence_penalty = 0, -- 새로운 주제 등 조절
        max_tokens = 4095, -- 응답으로 생성할 최대 토큰 수
        temperature = 0.2, -- 0에 가까울 수록 예측된 응답, 1에 가까울 수록 창의적인 응답
        top_p = 0.1,
        n = 1,
      },
      keymaps = {
        close = { "<C-c>", "q" },
        submit = "<Enter>",
        submit_n = "<Enter>",
        toggle_settings = "<C-o>",
        toggle_message_role = "<C-r>",
        toggle_system_role_open = "<C-s>",
        cycle_windows = "<Tab>",
        cycle_modes = "<C-f>",
        next_message = "j",
        prev_message = "k",
        select_session = "<Space>",
        rename_session = "r",
        delete_session = "d",
        new_session = "<C-n>",
        draft_message = "<C-d>",
        edit_message = "e",
        delete_message = "d",
        yank_message = "y",
        yank_message_code = "c",
        scroll_up = "<C-u>",
        scroll_down = "<C-d>",
        stop_generating = "<C-x>",
      },
    })

    local keymap = vim.keymap
    keymap.set("n", "<Leader>cg", "<cmd>ChatGPT<CR>", { desc = "ChatGPT" })
  end,
}
