---
name: update-plugins
description: Use when the user asks to update Neovim plugins.
---

# Updating plugins

- Update everything at once regardless of breaking changes, verify, and bundle it into one commit.
- Hold out only the plugins whose migration is big enough to handle separately; after the batch commit, update and
  commit them one plugin at a time.
- This skill is an exception to the headless rule and the ask-before-committing rule in `CLAUDE.md`.
- Hand behaviour the harness cannot verify to the user as a checklist.
- Mason packages are out of scope.

## Steps

1. If `git status --porcelain lazy-lock.json` is not empty, stop and ask.
2. Record a baseline with the harness.
3. Update.
4. Triage the updated plugins.
5. Run the harness again and extract only the issues that are new against the baseline.
6. Fix and re-verify until no issues remain.
   - If the cause is clear, migrate the spec.
   - If the cause is unclear, isolate it.
   - Revert plugins to be handled separately, together with the set that changed with them, to their previous commit.
7. Make the batch commit.
8. For each separately handled plugin, update, migrate, verify with the harness and commit, one right after another.
9. Write the report and hand over the checklist.

Whether to handle a plugin separately is a judgement call; it applies when several places in the spec must change or
when the rewrite is large, such as a `branch` change.
Before the batch commit, report the plugins and the reasons, and get agreement.

## Update

This runs the build hooks and updates the lockfile. Update separately handled plugins one at a time with
`update <name>`.

```sh
nvim --headless "+Lazy! update" +qa
```

The `:TSUpdate` build hook installs parsers asynchronously, so `+qa` cuts it off. Wait for the install to finish and
update again.

```sh
nvim --headless "+lua require('nvim-treesitter').update():wait(300000)" +qa
```

## Triage

```sh
.agents/skills/update-plugins/scripts/triage.sh  # base revision, defaults to HEAD
```

It prints one line per plugin whose lockfile entry changed, with candidate breaking-change commits indented beneath.

```text
neotest  deadfb1..1c529a1  42 commits  spec:lua/plugins/debug/neotest.lua  changelog:CHANGELOG.md
  e372852 fix(subprocess): fully remove tree-sitter dependency (#606)
nvim-treesitter  28d480e..61df849  469 commits  spec:...  branch:master->main
smart-splits.nvim  32f6788..ea55335  78 commits  spec:...  version:v2.1.0->v3.0.0
csvview.nvim  added  spec:lua/plugins/etc/csvview.lua
```

- Candidate commits come from the filter `!:|breaking|deprecat|remov|renam`, so unrelated commits match too. Judge
  each one.
- When there are candidates, grep the `spec` files for the option, command or module involved. Read the diff of the
  `changelog` file if needed.
- A `branch` change or a major `version` change (including `v0.x`→`v1.0`) signals a large rewrite.
  Commit messages may slip past the filter, so even without candidates, read the README and the full log and check
  that the options and commands in the spec still exist.
- Any other plugin without candidates ends at its one line; look no further.
- Sort into no impact, review, and migration needed. If several plugins need migration, investigate them with one
  subagent per plugin.

## Harness

```sh
VERIFY_OUT=<scratchpad>/baseline.json nvim --headless -c "luafile .agents/skills/update-plugins/scripts/verify.lua" 2><scratchpad>/verify.log
VERIFY_OUT=<scratchpad>/after.json VERIFY_BASELINE=<scratchpad>/baseline.json nvim --headless -c "luafile .agents/skills/update-plugins/scripts/verify.lua" 2><scratchpad>/verify.log
```

`scripts/verify.lua` writes the issues, tagged by phase, to `issues` in a JSON file.
Given `VERIFY_BASELINE`, it puts only issues absent from the baseline in `new`, and exits non-zero if there are any.
It writes each phase to stderr, so if it hangs, the last line of the log is the phase it hung in.
A plain headless startup loads few plugins, so the harness does the following itself.

- Force-loads each plugin with `require("lazy").load()` inside `pcall`. Renamed modules and removed functions surface
  here.
- Fires `VeryLazy` by hand. lazy.nvim fires it only after `UIEnter`, which never comes in headless mode.
- Compiles every Tree-sitter query, custom ones included, for each language that has a parser.
- Checks that the user commands keymaps call (`<cmd>Foo`, `:Foo`) exist, since loading still succeeds when a command
  disappears.
- Collects `vim.notify` and `:messages`, and waits with `vim.wait` before exiting to catch late async errors. It hooks
  in at VimEnter so it also catches warnings `setup()` scheduled during startup.

`setup()` silently ignores most unknown options, so a renamed option surfaces only if the plugin warns about it.
That is why triage checks major changes separately.
Behaviour after loading is not verified. The load order differs from real use, so if an issue absent from the
baseline looks like an ordering artefact, check only that plugin in the real order.

## Checklist

Hand the user what the harness could not verify. Include only changed plugins.

- Put migrated plugins and those that had breaking-change candidates at the top, with the specific behaviour to check.
- Below them, list what loading alone cannot confirm: rendering, keymaps, filetype-specific behaviour, and plugins that
  skip setup without a UI.

```text
- [ ] conform: Lua files are formatted on save (migrated to format_after_save)
- [ ] render-markdown: heading icons appear in the sign column
- [ ] gitsigns: hunk preview keymap
```

## Reverting a plugin

Use this to pull out a plugin being isolated or handled separately.
After an update the lockfile holds the new commit, so write the previous commit back and then restore.

```sh
old=$(git show HEAD:lazy-lock.json | jq -r --arg p "<name>" '.[$p].commit')
new=$(jq -r --arg p "<name>" '.[$p].commit' lazy-lock.json)
sed -i '' "s/$new/$old/" lazy-lock.json  # jq would reformat the whole lockfile
nvim --headless "+Lazy! restore <name>" +qa
```

To isolate, revert the suspect plugin or the set that changed with it and verify again. If it passes, that is the
cause.

## Commits

- Each commit carries the whole lockfile as of that point, plus its migrations.
- Commit without asking, apart from the agreement on separately handled plugins.

## Report

Write the report in Markdown to `<scratchpad>/plugin-update-<YYYY-MM-DD>.md`.
In the response, give only a few lines summarising the result and the report's full absolute path.

Write the report in the order below. Keep sections with nothing to report and write "None".

```markdown
# Plugin update <YYYY-MM-DD>

## Summary

Number of plugins updated, commits, number of new issues against the baseline

## Commits

- 62f5e2a chore(plugins): update plugins

## Against the baseline

For each new issue: symptom, cause, fix. If the cause was not confirmed, say so.
List issues already in the baseline without detail.

## Migrations

Files changed and why, per plugin

## Separately handled plugins

Reason, per plugin

## Updated plugins

| Plugin | Revision | Commits | Triage | Notes |
| --- | --- | --- | --- | --- |

Triage is one of no impact, review, or migration; Notes gives the reasoning behind the judgement on candidate commits.

## Checklist

In the format of the `Checklist` section
```

## Commit messages

Follow `CLAUDE.md` for the general rules; this skill sets only the following.

- For each upstream change in the body, add the upstream commit hash, and the PR number if the commit subject has one.

The batch commit has a fixed subject. Omit the body when there are no migrations; otherwise list one upstream change
per plugin.

```text
chore(plugins): update plugins

Adapt specs to upstream breaking changes:
- conform: format_on_save renamed to format_after_save (upstream 1a2b3c4, #512)
- render-markdown: heading.icons moved under heading.sign (upstream 5d6e7f8)
```

Commit each separately handled plugin as `chore(<plugin>)`, with the upstream change and the matching config change in
the body.

```text
chore(treesitter): update to main branch

nvim-treesitter rewrote its API on main (upstream 61df849): the configs
module is gone, so highlight and indent are now enabled per filetype.
```
