# File visibility policy

## Scope

| Module          | Policy application                                          |
| --------------- | ----------------------------------------------------------- |
| `fzf-lua` files | Apply the shared ignore file to file discovery              |
| `fzf-lua` grep  | Apply the shared ignore file to content search              |
| `sidebar.tree`  | Apply the shared ignore file to the project tree            |
| `oil.nvim`      | Read visible-dotfile exceptions from the shared ignore file |

## Policy

Use [`rules.ignore`](rules.ignore) as the source:

```gitignore
# Hide dotfiles by default
.*

# Visible dotfiles
!.claude/
!.codex/
```

- fzf/sidebar must enumerate dotfiles first, then apply this file. Their native hidden-file exclusion cannot restore `!` exceptions.
- Oil already hides dotfiles natively. A small adapter only needs to read the visible exceptions; avoid implementing a complete gitignore matcher.
- Oil's `g.` continues to reveal hidden entries temporarily.

This policy makes individual dotfile exclusions such as `.git/`, `.cache/`, and `.idea/` redundant.
Rules for non-dot artifacts such as `node_modules/`, `dist/`, and `*.log` are still needed if they should also be excluded.

This design uses supported behavior in all three tools and keeps the Oil adapter narrow.
If Oil must also apply every non-dot ignore rule, reconsider the design instead of adding a complex gitignore parser.
