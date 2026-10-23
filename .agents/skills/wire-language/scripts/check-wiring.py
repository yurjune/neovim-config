#!/usr/bin/env python3
"""Check the two wirings in languages.yaml that fail silently.

Mason's ensure_installed is a flat list with no link to the code that uses each
entry, so a package survives its config being commented out and nothing says so.
The same holds for `lsp/<server>.lua`: a config file whose server is missing
from `vim.lsp.enable` never starts, and an enable entry with no file falls back
to whatever nvim-lspconfig ships.

The two tables below are this script's own: Mason's package names do not match
the ids used in the Lua, and some tooling is installed outside Mason entirely.
languages.yaml records that those facts exist; the literals live here, where
they are actually read.
"""

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[4]

# Lua id -> Mason package name, for the ids that differ. Anything absent is
# installed under its own name.
ALIASES = {
    "lua_ls": "lua-language-server",
    "ts_ls": "typescript-language-server",
    "svelte": "svelte-language-server",
    "emmet_ls": "emmet-ls",
    "html_ls": "html-lsp",
    "css_lsp": "css-lsp",
    "css_variables": "css-variables-language-server",
    "css_modules": "cssmodules-language-server",
    "some_sass": "some-sass-language-server",
    "tailwindcss": "tailwindcss-language-server",
    "json_ls": "json-lsp",
}

# Provisioned outside Mason, so absence from ensure_installed is correct.
EXTERNAL = {
    "rust_analyzer": "rustup",
    "rustfmt": "rustup",
    "clippy": "rustup",
    "clangd": "brew install llvm",
    "clang_format": "brew install llvm",
    "clangtidy": "brew install llvm",
    "sql_formatter": "npm i -g sql-formatter",
}


def block(rel, anchor):
    """Body of the first brace-matched `{...}` after `anchor`, comments stripped."""
    src = "\n".join(
        re.sub(r"--.*$", "", ln) for ln in (ROOT / rel).read_text().splitlines()
    )
    m = re.search(anchor, src)
    if not m:
        sys.exit(f"{rel}: no match for {anchor}")
    start = src.index("{", m.end() - 1)
    depth = 0
    for i in range(start, len(src)):
        depth += (src[i] == "{") - (src[i] == "}")
        if depth == 0:
            return src[start : i + 1]
    sys.exit(f"{rel}: unbalanced braces after {anchor}")


def strings(text):
    return set(re.findall(r'"([^"]+)"', text))


def report(rows):
    for label, name in rows:
        print(f"{label:<30}{name}")
    return len(rows)


def check_mason():
    """Mason's install list against every place a tool is named, both ways."""
    installed = strings(block("lua/plugins/lsp/mason.lua", r"ensure_installed\s*="))

    used = set()
    used |= strings(block("lua/core/lsp.lua", r"vim\.lsp\.enable\s*\("))
    used |= strings(block("lua/plugins/editing/conform.lua", r"formatters_by_ft\s*="))
    used |= strings(block("lua/plugins/editing/nvim-lint.lua", r"linters_by_ft\s*="))
    used |= set(
        re.findall(
            r'try_lint\("([^"]+)"\)',
            (ROOT / "lua/plugins/editing/nvim-lint.lua").read_text(),
        )
    )
    for path in (ROOT / "lua").rglob("*.lua"):
        used |= set(re.findall(r"mason/packages/([^/\"]+)", path.read_text()))

    wanted = {ALIASES.get(name, name): name for name in used}

    rows = [
        ("installed, wired to nothing", pkg) for pkg in sorted(installed - set(wanted))
    ]
    rows += [
        ("wired, never installed", pkg)
        for pkg, name in sorted(wanted.items())
        if pkg not in installed and name not in EXTERNAL
    ]
    mismatched = report(rows)

    skipped = sorted(name for name in used if name in EXTERNAL)
    if skipped:
        print(f"not Mason's to install: {', '.join(skipped)}")
    print(f"{len(installed)} installed, {len(wanted)} wired, {mismatched} mismatched\n")
    return mismatched


def check_lsp():
    """`lsp/<server>.lua` against the vim.lsp.enable list, both ways."""
    configured = {path.stem for path in (ROOT / "lsp").glob("*.lua")}
    enabled = strings(block("lua/core/lsp.lua", r"vim\.lsp\.enable\s*\("))

    rows = [
        ("configured, never enabled", name) for name in sorted(configured - enabled)
    ]
    rows += [("enabled, no config file", name) for name in sorted(enabled - configured)]
    mismatched = report(rows)

    print(
        f"{len(configured)} configured, {len(enabled)} enabled, {mismatched} mismatched"
    )
    return mismatched


def main():
    return 1 if check_mason() + check_lsp() else 0


if __name__ == "__main__":
    sys.exit(main())
