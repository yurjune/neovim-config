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
  opts = {
    -- remove these in 4.0.0
    legacy_commands = false,
    ui = {
      enable = true,
    },
    workspaces = {
      {
        name = "personal",
        path = "~/obsidian/Jerry",
      },
    },
    completion = {
      nvim_cmp = true,
      min_chars = 1,
    },
    link = {
      style = "wiki",
      format = "shortest",
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
