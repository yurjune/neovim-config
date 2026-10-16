# Switch input source

This module delegates macOS input-source changes to the Hammerspoon `hs` CLI.
The Hammerspoon implementation is managed separately through the dotfiles configuration.

## External interface

The Hammerspoon configuration must expose the global module `nvimInputSource` to `hs -c`.
Its method names are case-sensitive.

| Method                         | Neovim use                                        |
| ------------------------------ | ------------------------------------------------- |
| `saveSourceAndSwitchToEnglish` | Save the current source, then select English.     |
| `restoreSavedSource`           | Restore the saved source.                         |
| `switchToEnglish`              | Select English without saving the current source. |

## Event contract

- Normal buffers and Maple use `InsertLeave` to save and select English, then `InsertEnter` to restore.
- Sidekick is not a normal buffer, so it uses `BufLeave` and `BufEnter` for the same transitions.
- [`fzf-lua.lua`](../../plugins/navigation/fzf-lua.lua) calls the exported `switch_to_english` function when a picker closes.

## Process lifetime

Each `jobstart` call uses `stdin = "null"` so the `hs` process exits after evaluating its command.

## Availability

This module has no fallback input-source implementation.
If Hammerspoon, the `hs` executable, or the `nvimInputSource` module is unavailable,
the requested change does not occur; this module neither retries nor handles the failure.
