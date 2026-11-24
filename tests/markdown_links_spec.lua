local assert = require("luassert")
local stub = require("luassert.stub")

require("etc.markdown")

describe("Markdown link keymap", function()
  local root, source, guide, changelog, open

  before_each(function()
    open = stub(vim.ui, "open")
    local tmp = vim.fn.tempname()
    vim.fn.mkdir(tmp .. "/getting-started", "p")
    root = assert(vim.uv.fs_realpath(tmp))
    source = root .. "/README.md"
    guide = root .. "/getting-started/README.md"
    changelog = root .. "/changelog.md"
    vim.fn.writefile({ "# Getting started", "", "## Install steps" }, guide)
    vim.fn.writefile({ "# Changelog" }, changelog)
  end)

  after_each(function()
    open:revert()
    for _, path in ipairs({ source, guide, changelog }) do
      local buf = vim.fn.bufnr(path)
      if buf ~= -1 then
        vim.api.nvim_buf_delete(buf, { force = true })
      end
    end
    vim.fn.delete(root, "rf")
  end)

  local function follow(lines, cursor_text, key)
    vim.fn.writefile(
      vim.list_extend(vim.deepcopy(lines), {
        "",
        "[Getting started]: getting-started/README.md",
        "[Install steps]: getting-started/README.md#install-steps",
        "[Changelog]: changelog.md",
      }),
      source
    )
    vim.cmd.edit({ args = { source } })
    vim.bo.filetype = "markdown"
    local col = assert(lines[1]:find(cursor_text, 1, true)) - 1
    vim.api.nvim_win_set_cursor(0, { 1, col })
    vim.cmd.normal({ args = { key or "gf" } })
    return col
  end

  it("opens the link under the cursor before an adjacent link", function()
    follow({ "[Getting started] [Changelog]" }, "Getting started")
    assert.equal(guide, vim.api.nvim_buf_get_name(0))
  end)

  it("follows the nearest link on the right to its heading", function()
    local col = follow({ "[Getting started] comes before [Install steps] and [Changelog]." }, "comes before")
    assert.equal(guide, vim.api.nvim_buf_get_name(0))
    assert.equal(3, vim.api.nvim_win_get_cursor(0)[1])

    vim.cmd.normal({ args = { vim.keycode("<C-O>") }, bang = true })
    assert.equal(source, vim.api.nvim_buf_get_name(0))
    assert.same({ 1, col }, vim.api.nvim_win_get_cursor(0))
  end)

  it("skips unresolved, code, and escaped bracket text", function()
    follow({ "Start [undefined] `[Getting started]` \\[Getting started] [Changelog]" }, "Start")
    assert.equal(changelog, vim.api.nvim_buf_get_name(0))
  end)

  it("uses native gf when Markdown links appear only to the left or on the next line", function()
    follow({ "[Getting started] ./changelog.md", "[Install steps]" }, "./changelog.md")
    assert.equal(changelog, vim.api.nvim_buf_get_name(0))
  end)

  it("opens an HTTP(S) reference link under the cursor with gf", function()
    local url = "https://example.com/docs?a=1&b=2#part"
    local col = follow({ "[Docs][web] [Getting started]", "", "[web]: <" .. url .. ">" }, "Docs")
    assert.stub(open).was.called_with(url)
    assert.equal(source, vim.api.nvim_buf_get_name(0))
    assert.same({ 1, col }, vim.api.nvim_win_get_cursor(0))
  end)

  it("follows the destination from inside the reference definition label", function()
    follow({ "[설치 방법]: getting-started/README.md#install-steps" }, "설치 방법")
    assert.equal(guide, vim.api.nvim_buf_get_name(0))
    assert.same({ 3, 0 }, vim.api.nvim_win_get_cursor(0))
  end)

  it("opens an HTTP(S) reference link to the right with gf", function()
    local url = "https://example.com/docs?a=1&b=2#part"
    local col = follow({ "Start [Docs][web]", "", "[web]: <" .. url .. ">" }, "Start")
    assert.stub(open).was.called_with(url)
    assert.same({ 1, col }, vim.api.nvim_win_get_cursor(0))
  end)

  it("keeps native gx on a plain URL in Markdown", function()
    local url = "https://example.com/docs"
    follow({ url }, url, "gx")
    assert.equal(0, vim.fn.maparg("gx", "n", false, true).buffer)
    assert.stub(open).was.called_with(url)
  end)
end)
