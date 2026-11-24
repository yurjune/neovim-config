local assert = require("luassert")
local stub = require("luassert.stub")

require("etc.markdown")

describe("Markdown heading", function()
  local buf

  before_each(function()
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = "markdown"
  end)

  after_each(function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  local function press(key, lines, row)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, { row or 1, 0 })
    vim.cmd.normal({ args = { vim.keycode("<leader>h" .. key) } })
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  end

  local function run(command, lines)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.cmd(command)
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  end

  describe("level keymaps", function()
    it("turns plain text into a heading", function()
      assert.same({ "## Install" }, press("2", { "Install" }))
    end)

    it("changes the level of an existing heading", function()
      assert.same({ "# Install" }, press("1", { "### Install" }))
    end)

    it("turns a bullet into a heading without its marker", function()
      assert.same({ "#### Install" }, press("4", { "  - Install" }))
    end)

    it("changes only the line under the cursor", function()
      assert.same({ "Intro", "### Install" }, press("3", { "Intro", "Install" }, 2))
    end)
  end)

  describe("remove keymap", function()
    it("removes the heading marker", function()
      assert.same({ "Install" }, press("x", { "## Install" }))
    end)

    it("leaves a line without a heading unchanged", function()
      assert.same({ "- Install" }, press("x", { "- Install" }))
    end)
  end)

  describe("bullet keymap", function()
    it("turns a heading into a bullet", function()
      assert.same({ "- Install" }, press("l", { "### Install" }))
    end)

    it("leaves a line without a heading unchanged", function()
      assert.same({ "Install" }, press("l", { "Install" }))
    end)
  end)

  describe("today keymap", function()
    local date

    before_each(function()
      date = stub(os, "date", { month = 10, day = 14, wday = 4 })
    end)

    after_each(function()
      date:revert()
    end)

    it("inserts today's heading and an empty line above the cursor line", function()
      assert.same({ "Intro", "### 10/14 Wed", "", "Notes" }, press("d", { "Intro", "Notes" }, 2))
      assert.same({ 2, 0 }, vim.api.nvim_win_get_cursor(0))
    end)
  end)

  describe("level shift commands", function()
    it("promotes every heading", function()
      local actual = run("MarkdownHeadingPromote", { "## Guide", "text", "### Install", "#### Steps" })
      assert.same({ "# Guide", "text", "## Install", "### Steps" }, actual)
    end)

    it("demotes every heading", function()
      local actual = run("MarkdownHeadingDemote", { "# Guide", "## Install" })
      assert.same({ "## Guide", "### Install" }, actual)
    end)

    it("leaves a heading that would move outside levels 1 to 6", function()
      assert.same({ "# Guide", "# Install" }, run("MarkdownHeadingPromote", { "# Guide", "## Install" }))
      assert.same(
        { "###### Guide", "###### Install" },
        run("MarkdownHeadingDemote", { "###### Guide", "##### Install" })
      )
    end)

    it("ignores seven or more hashes and hashes without a following space", function()
      local lines = { "####### Seven", "#tag" }
      assert.same(lines, run("MarkdownHeadingPromote", lines))
      assert.same(lines, run("MarkdownHeadingDemote", lines))
    end)

    it("skips lines inside backtick and tilde fences", function()
      local actual = run("MarkdownHeadingDemote", {
        "```sh",
        "# comment",
        "```",
        "  ~~~",
        "# comment",
        "  ~~~",
        "# Guide",
      })
      assert.same({ "```sh", "# comment", "```", "  ~~~", "# comment", "  ~~~", "## Guide" }, actual)
    end)

    it("keeps a fence open until the same character closes it at least as long", function()
      local actual = run("MarkdownHeadingDemote", {
        "````",
        "~~~~",
        "# inside",
        "```",
        "# inside",
        "````",
        "# Guide",
      })
      assert.same({ "````", "~~~~", "# inside", "```", "# inside", "````", "## Guide" }, actual)
    end)
  end)
end)
