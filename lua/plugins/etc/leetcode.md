# LeetCode mode

Starting Neovim with the `leet` argument enables `vim.g.leetcode` in [`core.global`](../../core/global.lua).
This is a startup mode, not a runtime toggle.
[`leetcode.lua`](leetcode.lua) loads `leetcode.nvim` only in this mode.

## Integration contract

The mode changes these integrations:

- Completion: [`nvim-cmp`](../lsp/nvim-cmp.lua) loads with no completion sources.
- AI completion: [`Supermaven`](../ai/supermaven.lua) does not load.
- Formatting and linting: [`Conform`](../editing/conform.lua) and [`nvim-lint`](../editing/nvim-lint.lua) do not load.
- C/C++ LSP: [`clangd`](../../../lsp/clangd.lua) stops after attaching while `vim.g.leetcode_lsp_off` is set.
- Images: [`image.nvim`](image.lua) loads for LeetCode content.

New integrations that should not run during problem solving must check `vim.g.leetcode` during setup.
Do not treat this flag as dynamically switchable after startup.
