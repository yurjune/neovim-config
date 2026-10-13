# Repository Instructions

## Commit Message Conventions

- Prefer the message form `<type>(<scope>): <summary>`.
    - Use `feat` for new behavior, `fix` for bug fixes, `refactor` for behavior-preserving restructuring, and `chore` for maintenance or configuration work.
    - Use a short lowercase scope naming the affected area, such as `sidekick`, `render-markdown`, `keymaps`, or `lsp`. Omit the scope only when no single area describes the change.
    - Write the summary in concise English, start it with a lowercase imperative verb, and do not end it with a period.
- Omit the commit body for straightforward changes. Add a body only when the motivation, tradeoff, or preserved behavior is not clear from the subject and diff; explain why rather than restating what changed.
- Do not add `Co-authored-by`, AI attribution, or similar trailers unless the user explicitly requests them.

## Validation

- Format changed Lua files with `stylua`; the repository uses `.stylua.toml`.
- Do not run `nvim --headless` as a routine check;

## Project Structure

- Place plugin specs under the matching `lua/plugins/<category>/` directory.
- Put native LSP configurations in `lsp/<server>.lua` and enable them in `lua/core/lsp.lua`.
- Define shared responsive UI dimensions in `lua/ui/layout.lua` instead of hardcoding them in individual plugin specs.
- Treat `lazy-lock.json` as generated data; change it only as a consequence of plugin dependency changes.
