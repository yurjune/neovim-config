# Markdown editing

Markdown editing operations are the largest group of filetype-specific keymaps in this configuration, so they live here as a self-contained
module instead of growing inside `lua/core/`.

| Module                         | Scope                                                       |
| ------------------------------ | ----------------------------------------------------------- |
| [`heading.lua`](heading.lua)   | Heading levels, heading and bullet conversion — `<leader>h` |
| [`emphasis.lua`](emphasis.lua) | Bold, italic, strikethrough, inline code — `<leader>m`      |
| [`init.lua`](init.lua)         | The `FileType` autocommand that registers both              |

- Bullets appear in `heading.lua` only as the other end of a heading conversion — list editing of its own, such as checkboxes or
  renumbering, belongs in a new module.
- The emphasis keymaps depend on nvim-surround's `S` and `ds` mappings.
