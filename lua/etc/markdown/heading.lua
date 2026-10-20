local M = {}

local function set_heading(level)
  local line = vim.api.nvim_get_current_line()
  local heading_end = line:match("^#+%s+()")

  if level == 0 then
    if heading_end then
      vim.api.nvim_set_current_line(line:sub(heading_end))
    end
    return
  end

  local bullet_end = line:match("^%s*[-+*]%s+()")
  local content = line:sub(heading_end or bullet_end or 1)
  vim.api.nvim_set_current_line(string.rep("#", level) .. " " .. content)
end

local function heading_to_bullet()
  local line = vim.api.nvim_get_current_line()
  local heading_end = line:match("^#+%s+()")
  if heading_end then
    vim.api.nvim_set_current_line("- " .. line:sub(heading_end))
  end
end

-- Generates: ### 10/14 Wed
local function insert_today(buf)
  local today = os.date("*t")
  local weekdays = { "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat" }
  local heading = ("### %d/%d %s"):format(today.month, today.day, weekdays[today.wday])
  local cursor = vim.api.nvim_win_get_cursor(0)

  vim.api.nvim_buf_set_lines(buf, cursor[1] - 1, cursor[1] - 1, false, {
    heading,
    "", -- intended empty line
  })
  vim.api.nvim_win_set_cursor(0, { cursor[1], 0 })
end

local function level_up(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local fence = nil

  for index, line in ipairs(lines) do
    local marker = line:match("^%s*(```+)") or line:match("^%s*(~~~+)")
    if fence then
      -- A fence closes only with the same character and at least as many of them.
      if marker and marker:sub(1, 1) == fence:sub(1, 1) and #marker >= #fence then
        fence = nil
      end
    elseif marker then
      fence = marker
    else
      -- Levels deeper than 6 are not headings, so leave them alone.
      local hashes = line:match("^(#+)%s")
      if hashes and #hashes < 6 then
        vim.api.nvim_buf_set_lines(buf, index - 1, index, false, { "#" .. line })
      end
    end
  end
end

function M.setup(buf)
  vim.keymap.set("n", "<leader>hx", function()
    set_heading(0)
  end, {
    buffer = buf,
    desc = "Remove heading",
  })

  vim.keymap.set("n", "<leader>hl", heading_to_bullet, {
    buffer = buf,
    desc = "Convert heading to bullet",
  })

  for level = 1, 4 do
    -- ex) <leader>h3 generates "###"
    vim.keymap.set("n", "<leader>h" .. level, function()
      set_heading(level)
    end, {
      buffer = buf,
      desc = ("Create level %d heading"):format(level),
    })
  end

  vim.keymap.set("n", "<leader>hd", function()
    insert_today(buf)
  end, {
    buffer = buf,
    desc = "Insert today's level 3 heading",
  })

  vim.api.nvim_buf_create_user_command(buf, "MarkdownHeadingUp", function()
    level_up(buf)
  end, { desc = "Increase every heading level by one" })
end

return M
