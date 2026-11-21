local M = {}

local reference_children = {
  shortcut_link = "link_text",
  collapsed_reference_link = "link_text",
  full_reference_link = "link_label",
}

local definitions = vim.treesitter.query.parse(
  "markdown",
  [[
  (link_reference_definition (link_label) @label (link_destination) @destination)
]]
)

local inline_links = vim.treesitter.query.parse(
  "markdown_inline",
  [[
  [(inline_link) (shortcut_link) (collapsed_reference_link) (full_reference_link)] @link
]]
)

local headings = vim.treesitter.query.parse(
  "markdown",
  [[
  (atx_heading (inline) @heading)
  (setext_heading (paragraph (inline) @heading))
]]
)

local node_text = vim.treesitter.get_node_text

local function normalize_label(label)
  label = vim.trim(label):gsub("%s+", " ")
  return vim.fn.tolower(label)
end

local function reference_destinations(root, buf)
  local destinations = {}
  for _, match in definitions:iter_matches(root, buf) do
    local label = normalize_label(node_text(match[1][1], buf):sub(2, -2))
    destinations[label] = destinations[label] or node_text(match[2][1], buf)
  end
  return destinations
end

local function resolve_link(link, buf, destinations)
  local kind = link:type()
  for child in link:iter_children() do
    if kind == "inline_link" and child:type() == "link_destination" then
      return node_text(child, buf)
    end
    if child:type() == reference_children[kind] then
      local label = node_text(child, buf)
      if kind == "full_reference_link" then
        label = label:sub(2, -2)
      end
      return destinations[normalize_label(label)]
    end
  end
end

local function link_destination(buf)
  local parser = vim.treesitter.get_parser(buf, "markdown")
  if not parser then
    return
  end
  local tree = parser:parse(true)[1]
  local destinations = reference_destinations(tree:root(), buf)
  local link = vim.treesitter.get_node({ bufnr = buf, ignore_injections = false })
  while link and not reference_children[link:type()] and link:type() ~= "inline_link" do
    link = link:parent()
  end
  local destination = link and resolve_link(link, buf, destinations)
  if destination then
    return destination
  end

  local cursor = vim.api.nvim_win_get_cursor(0)
  local row, col = cursor[1] - 1, cursor[2]
  local nearest_col = math.huge
  parser:for_each_tree(function(inline_tree, language)
    if language:lang() ~= "markdown_inline" then
      return
    end
    for _, candidate in inline_links:iter_captures(inline_tree:root(), buf, row, row + 1) do
      local start_row, start_col = candidate:start()
      if start_row == row and start_col > col and start_col < nearest_col then
        local target = resolve_link(candidate, buf, destinations)
        if target then
          destination, nearest_col = target, start_col
        end
      end
    end
  end)
  return destination
end

local function jump_to_heading(buf, anchor)
  local parser = vim.treesitter.get_parser(buf, "markdown")
  if not parser then
    return
  end
  local tree = parser:parse()[1]
  for _, heading in headings:iter_captures(tree:root(), buf) do
    local title = node_text(heading, buf)
    if heading:parent():type() == "atx_heading" then
      title = title:gsub("%s+#+%s*$", "")
    end
    local slug = vim.fn
      .tolower(vim.trim(title))
      :gsub("[%p]", function(char)
        return (char == "-" or char == "_") and char or ""
      end)
      :gsub("%s", "-")
    if slug == anchor then
      local row = heading:start()
      vim.api.nvim_win_set_cursor(0, { row + 1, 0 })
      vim.cmd.normal({ args = { "zv" }, bang = true })
      return
    end
  end
  vim.notify("Markdown heading not found: #" .. anchor, vim.log.levels.WARN)
end

local function follow_link(buf)
  local destination = link_destination(buf)
  if not destination then
    vim.cmd.normal({ args = { vim.v.count1 .. "gf" }, bang = true })
    return
  end
  destination = destination:gsub("^<(.*)>$", "%1")
  if destination:lower():match("^https?://") then
    local _, err = vim.ui.open(destination)
    if err then
      vim.notify(err, vim.log.levels.ERROR)
    end
    return
  end

  local path, anchor = destination:match("^([^#]*)#?(.*)$")
  if path:match("^%a[%w+.-]*:") or vim.startswith(path, "//") then
    vim.notify("Place the cursor on a local Markdown file link", vim.log.levels.WARN)
    return
  end

  local source = vim.api.nvim_buf_get_name(buf)
  if path ~= "" then
    path = vim.uri_decode(path)
    if not vim.startswith(path, "/") then
      path = vim.fs.joinpath(vim.fs.dirname(source) or ".", path)
    end
    path = vim.fs.normalize(path, { expand_env = false })
    if vim.fn.filereadable(path) ~= 1 then
      vim.notify("Markdown link target not found: " .. path, vim.log.levels.WARN)
      return
    end
  end

  vim.cmd.normal({ args = { "m'" }, bang = true })
  if path ~= "" and path ~= source then
    vim.cmd.edit({ args = { path }, magic = { file = false, bar = false } })
  end
  if anchor ~= "" then
    jump_to_heading(vim.api.nvim_get_current_buf(), vim.uri_decode(anchor))
  end
end

function M.setup(buf)
  vim.keymap.set("n", "gf", function()
    follow_link(buf)
  end, { buffer = buf, desc = "Follow Markdown link" })
end

return M
