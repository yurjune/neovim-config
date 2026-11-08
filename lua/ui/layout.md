# Layout column measurements

## Purpose

- Record the conditions and observed column counts used to choose the layout ranges in [layout.lua](layout.lua).
- Measure the column count with `vim.o.columns`
- `:LayoutInfo` displays that value alongside the selected layout.

## Layout ranges

| Layout  | Column count |
| ------- | ------------ |
| compact | Below `200`  |
| medium  | `200 ~ 220`  |
| wide    | Above `220`  |

## Conditions

- font-family: `JetBrainsMono Nerd Font Mono`.
  - Install font on homebrew
- 4K 27-inch: `3840 × 2160`, macOS UI looks like `1920 × 1080`.

## Results

| Device         | Font size | `vim.o.columns` |
| -------------- | --------: | --------------: |
| MacBook Pro 14 |        12 |             215 |
| MacBook Pro 14 |        13 |             188 |
| 4K 27-inch     |        12 |             273 |
| 4K 27-inch     |        13 |             239 |
| 5K 27-inch     |        15 |             284 |
