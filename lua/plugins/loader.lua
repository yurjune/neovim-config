local function safe_require(name)
  local ok, err = pcall(require, name)
  if not ok then
    vim.schedule(function()
      vim.notify("Failed to load " .. name .. ": " .. tostring(err), vim.log.levels.ERROR)
    end)
  end
end

local packages = {
  -- Themes/UI should be early so highlights are ready.
  "plugins.themes.catppuccin",

  "plugins.ui.plenary",
  "plugins.ui.alpha-nvim",
  "plugins.ui.bufferline",
  "plugins.ui.dressing",
  -- "plugins.ui.indent-blankline",
  "plugins.ui.lualine",
  "plugins.ui.nvim-notify",
  "plugins.ui.noice",
  "plugins.ui.nvim-highlight-colors",
  "plugins.ui.smoothie",
  "plugins.ui.vim-illuminate",

  -- Editing core (treesitter first)
  "plugins.editing.nvim-treesitter",
  "plugins.editing.nvim-ts-autotag",
  "plugins.editing.nvim-ufo",
  "plugins.editing.comment",
  "plugins.editing.nvim-autopairs",
  "plugins.editing.nvim-surround",
  "plugins.editing.mini-surround",
  "plugins.editing.conform",
  "plugins.editing.nvim-lint",
  "plugins.editing.refactoring",

  -- LSP/completion
  "plugins.lsp.mason",
  "plugins.lsp.nvim-cmp",

  -- Navigation (telescope before LSP keymaps fire)
  "plugins.navigation.which-key",
  "plugins.navigation.smart-splits",
  "plugins.navigation.nvim-tree",
  "plugins.navigation.oil",
  "plugins.navigation.telescope",
  "plugins.navigation.marks",
  "plugins.navigation.nvim-navic",

  -- Workflow
  "plugins.workflow.toggleterm",
  "plugins.workflow.windows",
  "plugins.workflow.maple",
  "plugins.workflow.todo-comments",
  "plugins.workflow.maximizer",
  "plugins.workflow.auto-session",

  -- Git
  "plugins.git.gitsigns",
  "plugins.git.lazygit",
  "plugins.git.git-conflict",
  "plugins.git.vim-fugitive",

  -- AI
  "plugins.ai.sidekick",
  "plugins.ai.supermaven",
  -- "plugins.ai.copilot",

  -- Debug
  "plugins.debug.nvim-dap",
  -- "plugins.debug.neotest",

  -- Markdown
  "plugins.markdown.markview",
  "plugins.markdown.table-nvim",
  "plugins.markdown.bullets",

  -- Etc
  "plugins.etc.image",
  "plugins.etc.leetcode",
}

for _, name in ipairs(packages) do
  safe_require(name)
end
