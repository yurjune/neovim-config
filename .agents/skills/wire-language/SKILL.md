---
name: wire-language
description: Add a language to this Neovim config, or change which LSP, formatter, linter, parser or debug adapter handles one. Use before editing any of those tables.
---

# Wiring a language

Each piece lives in a different file, and every omission fails silently - no error, no log line, the tool simply never
runs. [`languages.yaml`](../../ontology/languages.yaml) lists the places that have to agree and what each missing piece
looks like. Read it before editing any of them.

## Order

1. Find the **filetype**, not the language. One language owns several and they do not all appear in every table.
2. Edit the tables you need. Formatter list order is run order.
3. Install the tool. Mason is the default; rust, clang and `sql_formatter` come from elsewhere and must stay out of
   `ensure_installed`. Mason's package names do not match the ids used in `lsp/` - copy them from `mason.lua`, never
   infer.
4. Run the checker:

   ```sh
   python3 .agents/skills/wire-language/scripts/check-wiring.py
   ```

   It exits 1 on anything unpaired, and some things are unpaired on purpose - read the output against `dormant` in
   `languages.yaml`.

5. To confirm it loaded, ask the user to run `:checkhealth lsp`, `:ConformInfo` or `:Mason` in their running Neovim. Do
   not launch `nvim --headless`.
