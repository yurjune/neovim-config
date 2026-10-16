# File visibility policy

## Policy

Oil, sidebar, and fzf follow the same visibility policy:

1. Hide dotfiles and dot-directories by default.
2. Declare exceptions that should be visible.
3. Hide additional non-dot entries as needed.

## Configuration

Manage this policy in [`rules.ignore`](rules.ignore) using
[gitignore syntax](https://git-scm.com/docs/gitignore#_pattern_format).

## Tool integration

| Interface | Implementation                                                                       |
| --------- | ------------------------------------------------------------------------------------ |
| fzf files | `fd --hidden --no-ignore --ignore-file <rules.ignore>`                               |
| fzf grep  | `rg --hidden --no-ignore --ignore-file <rules.ignore>`                               |
| sidebar   | `tree -a --gitfile=<rules.ignore>`                                                   |
| Oil       | `view_options.is_hidden_file(name, bufnr)` evaluates the shared rules for each entry |

### fzf and sidebar

fzf's discovery tools and sidebar include hidden entries before applying the rules so visible
exceptions can take effect. fzf also disables project ignore files with `--no-ignore`.

### Oil

Oil has no ignore-file option, so [`oil-adapter.lua`](oil-adapter.lua) adapts the rules to its callback.
It supports entry-name patterns with `*`, `?`, `!`, and a trailing `/`;
path patterns, character classes, and escaping are unsupported.
It filters the open directory; directory-only rules use local filesystem checks.
Unlike recursive searches, opening an excluded directory directly still shows its contents.
