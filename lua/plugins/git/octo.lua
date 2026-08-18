return {
  "pwntester/octo.nvim",
  cmd = "Octo",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "ibhagwan/fzf-lua",
    "nvim-tree/nvim-web-devicons",
  },
  init = function()
    vim.treesitter.language.register("markdown", "octo")
  end,
  keys = {
    { "<leader>op", "<cmd>Octo pr create<CR>", desc = "Create GitHub pull request" },
    { "<leader>oP", "<cmd>Octo pr list<CR>", desc = "List GitHub pull requests" },
    {
      "<leader>or",
      "<cmd>Octo search is:pr is:open review-requested:@me<CR>",
      desc = "List GitHub pull requests awaiting my review",
    },
    { "<leader>on", "<cmd>Octo notification list<CR>", desc = "List unread GitHub notifications" },
    {
      "<leader>oN",
      function()
        require("octo.picker").notifications({ all = true })
      end,
      desc = "List all GitHub notifications",
    },
  },
  opts = {
    picker = "fzf-lua",
    enable_builtin = true,
    ssh_aliases = {
      ["github.com-yhpark"] = "github.com",
      ["github.com-yurjune"] = "github.com",
    },
  },
}
