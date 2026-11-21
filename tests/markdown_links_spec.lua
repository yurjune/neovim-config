local assert = require("luassert")
local stub = require("luassert.stub")

require("etc.markdown")

describe("Markdown link keymap", function()
  local root, source, discovery, review, open

  before_each(function()
    open = stub(vim.ui, "open")
    root = vim.fn.tempname()
    vim.fn.mkdir(root .. "/discovery-step", "p")
    root = vim.uv.fs_realpath(root)
    source = root .. "/README.md"
    discovery = root .. "/discovery-step/README.md"
    review = root .. "/review.md"
    vim.fn.writefile({ "# Product discovery", "", "## Discovery results" }, discovery)
    vim.fn.writefile({ "# Profitability review" }, review)
  end)

  after_each(function()
    open:revert()
    for _, path in ipairs({ source, discovery, review }) do
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
        "[Product discovery]: discovery-step/README.md",
        "[Discovery results]: discovery-step/README.md#discovery-results",
        "[Profitability review]: review.md",
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
    follow({ "[Product discovery] [Profitability review]" }, "Product discovery")
    assert.equals(discovery, vim.api.nvim_buf_get_name(0))
  end)

  it("follows the nearest link on the right to its heading", function()
    local col =
      follow({ "[Product discovery] comes before [Discovery results] and [Profitability review]." }, "comes before")
    assert.equals(discovery, vim.api.nvim_buf_get_name(0))
    assert.equals(3, vim.api.nvim_win_get_cursor(0)[1])

    vim.cmd.normal({ args = { vim.keycode("<C-O>") }, bang = true })
    assert.equals(source, vim.api.nvim_buf_get_name(0))
    assert.same({ 1, col }, vim.api.nvim_win_get_cursor(0))
  end)

  it("skips unresolved, code, and escaped bracket text", function()
    follow({ "Start [undefined] `[Product discovery]` \\[Product discovery] [Profitability review]" }, "Start")
    assert.equals(review, vim.api.nvim_buf_get_name(0))
  end)

  it("uses native gf when Markdown links appear only to the left or on the next line", function()
    follow({ "[Product discovery] ./review.md", "[Discovery results]" }, "./review.md")
    assert.equals(review, vim.api.nvim_buf_get_name(0))
  end)

  it("opens an HTTP(S) reference link under the cursor with gf", function()
    local url = "https://example.com/guide?a=1&b=2#part"
    local col = follow({ "[Guide][web] [Product discovery]", "", "[web]: <" .. url .. ">" }, "Guide")
    assert.stub(open).was_called_with(url)
    assert.equals(source, vim.api.nvim_buf_get_name(0))
    assert.same({ 1, col }, vim.api.nvim_win_get_cursor(0))
  end)

  it("opens an HTTP(S) reference link to the right with gf", function()
    local url = "https://example.com/guide?a=1&b=2#part"
    local col = follow({ "Start [Guide][web]", "", "[web]: <" .. url .. ">" }, "Start")
    assert.stub(open).was_called_with(url)
    assert.same({ 1, col }, vim.api.nvim_win_get_cursor(0))
  end)

  it("keeps native gx on a plain URL in Markdown", function()
    local url = "https://example.com/guide"
    follow({ url }, url, "gx")
    assert.equals(0, vim.fn.maparg("gx", "n", false, true).buffer)
    assert.stub(open).was_called_with(url)
  end)
end)
