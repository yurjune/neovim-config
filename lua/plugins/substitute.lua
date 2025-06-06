-- A plugin for easy text substitution in Neovim
return {
  "gbprod/substitute.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local substitute = require("substitute")

    substitute.setup({
      on_substitute = nil,
      yank_substituted_text = false,
      preserve_cursor_position = false,
      modifiers = nil, -- ex) `g`(global), `c`(confirm)
      highlight_substituted_text = {
        enabled = false,
        timer = 200,
      },
      range = {
        prefix = "s",
        prompt_current_text = false,
        confirm = false,
        complete_word = false,
        subject = nil,
        range = nil,
        suffix = "",
        auto_apply = false,
        cursor_position = "end",
      },
      exchange = {
        motion = false,
        use_esc_to_cancel = true,
        preserve_cursor_position = false,
      },
    })

    vim.keymap.set("n", "gs", substitute.operator, { desc = "Substitute with motion" })
    vim.keymap.set("n", "gss", substitute.line, { desc = "Substitute line" })
    vim.keymap.set("n", "gS", substitute.eol, { desc = "Substitute to end of line" })
    vim.keymap.set("x", "gs", substitute.visual, { desc = "Substitute in visual mode" })
  end,
}
