local assert = require("luassert")

vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/lazy/nvim-surround")
require("nvim-surround").setup({})
vim.cmd("runtime plugin/nvim-surround.lua")
require("etc.markdown")

describe("Markdown emphasis keymaps", function()
  local buf

  before_each(function()
    buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_set_current_buf(buf)
    vim.bo[buf].filetype = "markdown"
  end)

  after_each(function()
    vim.api.nvim_buf_delete(buf, { force = true })
  end)

  local function toggle(key, lines, cursor_col)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.api.nvim_win_set_cursor(0, { 1, cursor_col })
    vim.cmd.normal({ args = { vim.keycode("<leader>m" .. key) } })
    return vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  end

  local styles = {
    { "bold", "b", "**" },
    { "italic", "i", "*" },
    { "strikethrough", "s", "~~" },
    { "inline code", "c", "`" },
  }

  for _, style in ipairs(styles) do
    local name, key, marker = unpack(style)
    local marked_neighbor = marker .. "one" .. marker
    local marked_target = marker .. "two" .. marker

    describe(name, function()
      it("wraps a plain word between two marked spans", function()
        local actual = toggle(key, { marked_neighbor .. " two " .. marked_neighbor }, #marked_neighbor + 2)
        assert.same({ marked_neighbor .. " " .. marked_target .. " " .. marked_neighbor }, actual)
      end)

      it("wraps a plain word before a marked span on the next line", function()
        local actual = toggle(key, { marked_neighbor .. " two", marked_neighbor }, #marked_neighbor + 2)
        assert.same({ marked_neighbor .. " " .. marked_target, marked_neighbor }, actual)
      end)

      it("unwraps only the span under the cursor", function()
        local actual = toggle(key, { marked_neighbor .. " " .. marked_target }, #marked_neighbor + 2 + #marker)
        assert.same({ marked_neighbor .. " two" }, actual)
      end)

      it("unwraps a multiline span from its first line", function()
        local actual = toggle(key, { marker .. "one", "two" .. marker }, #marker)
        assert.same({ "one", "two" }, actual)
      end)
    end)
  end

  describe("combined bold and italic", function()
    it("removes bold and preserves italic", function()
      local actual = toggle("b", { "***one***" }, 4)
      assert.same({ "*one*" }, actual)
    end)

    it("removes italic and preserves bold", function()
      local actual = toggle("i", { "***one***" }, 4)
      assert.same({ "**one**" }, actual)
    end)

    it("adds italic to bold text", function()
      local actual = toggle("i", { "**one**" }, 3)
      assert.same({ "***one***" }, actual)
    end)

    it("adds bold to italic text", function()
      local actual = toggle("b", { "*one*" }, 2)
      assert.same({ "***one***" }, actual)
    end)
  end)

  it("unwraps a double-backtick code span and preserves its literal backtick", function()
    local actual = toggle("c", { "``one ` two``" }, 3)
    assert.same({ "one ` two" }, actual)
  end)
end)
