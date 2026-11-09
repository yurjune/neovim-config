return {
  -- community fork of epwalsh/obsidian.nvim
  "obsidian-nvim/obsidian.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  lazy = true,
  enabled = true,
  ft = "markdown",
  init = function()
    vim.g.obsidian_default_keymap = false
  end,
  opts = {
    -- remove these in 4.0.0
    legacy_commands = false,
    ui = {
      enable = false, -- prevent collsion with render-markdown.nvim
    },
    workspaces = {
      {
        name = "study-notes",
        path = "~/obsidian/study-notes",
      },
      {
        name = "life-notes",
        path = "~/obsidian/life-notes",
      },
      {
        name = "business-notes",
        path = "~/obsidian/business-notes",
      },
      {
        name = "work-notes",
        path = "~/obsidian/work-notes",
      },
    },
    completion = {
      min_chars = 1,
    },
    link = {
      style = "wiki",
      format = "shortest",
      auto_update = true,
    },
    frontmatter = {
      enabled = false,
    },
    backlinks = {
      parse_headers = true,
    },
    footer = {
      enabled = false,
      format = "{{backlinks}} backlinks  {{properties}} properties  {{words}} words  {{chars}} chars",
      hl_group = "Comment",
      separator = string.rep("-", 80),
    },
    notes_subdir = nil,
    new_notes_location = "current_dir",
  },
}
