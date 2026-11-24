-- A focused view for reviewing repository-wide changes
local layout = require("ui.layout")

local function close_diffviews()
  local lib = require("diffview.lib")
  local closed = false

  for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
    local view = lib.tabpage_to_view(tabpage)
    if view then
      view:close()
      lib.dispose_view(view)
      closed = true
    end
  end

  return closed
end

local function toggle_diffview(command)
  if not close_diffviews() then
    vim.cmd(command)
  end
end

local function toggle_diffview_against_branch()
  if close_diffviews() then
    return
  end

  vim.ui.input({ prompt = "Compare against branch: " }, function(branch)
    if branch and vim.trim(branch) ~= "" then
      vim.cmd({ cmd = "DiffviewOpen", args = { vim.trim(branch) } })
    end
  end)
end

local function toggle_commit_diffview()
  if close_diffviews() then
    return
  end

  vim.ui.input({ prompt = "Commits back (0 = HEAD): ", default = "0" }, function(input)
    if not input then
      return
    end

    local offset = vim.trim(input)
    if offset == "" then
      offset = "0"
    end
    if not offset:match("^%d+$") then
      vim.notify("Enter a non-negative commit offset", vim.log.levels.WARN)
      return
    end

    vim.cmd({ cmd = "DiffviewOpen", args = { "HEAD~" .. offset .. "^!" } })
  end)
end

return {
  "sindrets/diffview.nvim",
  cmd = {
    "DiffviewOpen",
    "DiffviewClose",
    "DiffviewToggleFiles",
    "DiffviewFocusFiles",
    "DiffviewRefresh",
    "DiffviewFileHistory",
  },
  keys = {
    {
      "<leader>gr",
      function()
        toggle_diffview("DiffviewOpen")
      end,
      desc = "Toggle Git review",
    },
    {
      "<leader>gc",
      toggle_diffview_against_branch,
      desc = "Toggle Git review against branch",
    },
    {
      "<leader>gd",
      toggle_commit_diffview,
      desc = "Toggle Git commit diff",
    },
  },
  opts = function()
    local actions = require("diffview.actions")

    return {
      keymaps = {
        view = {
          { "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
          { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },

          -- Resolve the conflict under the cursor.
          { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose OURS for conflict" } },
          { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS for conflict" } },
          { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose BASE for conflict" } },
          { "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose ALL for conflict" } },
          { "n", "dx", actions.conflict_choose("none"), { desc = "Delete conflict region" } },

          -- Resolve every conflict in the current file.
          { "n", "<leader>cO", actions.conflict_choose_all("ours"), { desc = "Choose OURS for entire file" } },
          { "n", "<leader>cT", actions.conflict_choose_all("theirs"), { desc = "Choose THEIRS for entire file" } },
          { "n", "<leader>cB", actions.conflict_choose_all("base"), { desc = "Choose BASE for entire file" } },
          { "n", "<leader>cA", actions.conflict_choose_all("all"), { desc = "Choose ALL for entire file" } },
          { "n", "dX", actions.conflict_choose_all("none"), { desc = "Delete all conflict regions" } },
        },
      },
      view = {
        default = {
          layout = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
        merge_tool = {
          layout = "diff3_mixed",
          disable_diagnostics = true,
          winbar_info = true,
        },
        file_history = {
          layout = "diff2_horizontal",
          disable_diagnostics = true,
          winbar_info = true,
        },
      },
      file_panel = {
        win_config = {
          position = "left",
          width = layout.sidebar[2],
        },
      },
      file_history_panel = {
        win_config = {
          position = "bottom",
          height = 16,
        },
      },
    }
  end,
}
