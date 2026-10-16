# Repository Instructions

## Commit Message Conventions

- Follow Conventional Commits: `<type>(<scope>): <summary>`.
  Use a short lowercase scope naming the affected area; omit it only when no single area fits.
  Write the summary in English as a lowercase imperative with no trailing period.
- Add a body only when the motivation or tradeoff is not clear from the subject and diff; explain why, not what.
- Do not commit on finishing a task; show the proposed commit message and ask first.

## Validation

- Format changed Lua files with `stylua`; the repository uses `.stylua.toml`.
- Do not run `nvim --headless` as a routine check;

## Project Structure

- `lua/plugins/<category>/` — plugin specs, filed under the matching category; a new category must also be added to the import list in `lua/lazy-config.lua`.
- `lsp/<server>.lua` — native LSP configuration; enable the server in `lua/core/lsp.lua`.
- `lua/core/`, `lua/ui/` — register each new module in that directory's `init.lua`; an unregistered module silently never loads.
- `lua/ui/layout.lua` — shared responsive UI dimensions; do not hardcode them in individual plugin specs.
- `lua/etc/<module>/` — self-contained custom modules.
- `plugin/*.lua` — code that must run at startup even inside the child Neovim processes some plugins spawn; a lazy-loaded plugin spec does not reach those.
- `after/queries/<lang>/` — Tree-sitter query extensions, starting with `; extends`. `queries/<lang>/` replaces Neovim's default outright instead of adding to it.
- `.agents/skills/<name>/SKILL.md` — agent skills, symlinked from `.claude/skills/`. Keep the frontmatter `description` to the trigger condition alone; details belong in the body.
- `lazy-lock.json` — generated data; change it only as a consequence of plugin dependency changes.
