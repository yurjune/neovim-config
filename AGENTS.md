# Repository Instructions

## Commit Message Conventions

- Prefer the message form `<type>(<scope>): <summary>`.
    - Use `feat` for new behavior, `fix` for bug fixes, `refactor` for behavior-preserving restructuring,
      and `chore` for maintenance or configuration work.
    - Use a short lowercase scope naming the affected area, such as `sidekick`, `render-markdown`, `keymaps`, or `lsp`.
      Omit the scope only when no single area describes the change.
    - Write the summary in concise English, start it with a lowercase imperative verb, and do not end it with a period.
- Omit the commit body for straightforward changes. Add a body only when the motivation, tradeoff, or preserved behavior is not clear from the subject and diff;
  explain why rather than restating what changed.
- Do not add `Co-authored-by`, AI attribution, or similar trailers unless the user explicitly requests them.

## Validation

- Format changed Lua files with `stylua`; the repository uses `.stylua.toml`.
- Do not run `nvim --headless` as a routine check;

## Project Structure

- `lua/plugins/<category>/` — plugin specs, filed under the matching category.
- `lsp/<server>.lua` — native LSP configuration; enable the server in `lua/core/lsp.lua`.
- `lua/core/`, `lua/ui/` — register each new module in that directory's `init.lua`; an unregistered module silently never loads.
- `lua/ui/layout.lua` — shared responsive UI dimensions; do not hardcode them in individual plugin specs.
- `lua/etc/<module>/` — self-contained custom modules.
- `plugin/*.lua` — code that must run at startup even inside the child Neovim processes some plugins spawn; a lazy-loaded plugin spec does not reach those.
- `after/queries/<lang>/` — Tree-sitter query extensions, starting with `; extends`. `queries/<lang>/` replaces Neovim's default outright instead of adding to it.
- `lazy-lock.json` — generated data; change it only as a consequence of plugin dependency changes.
