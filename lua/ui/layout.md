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

## Results

| Device         | Font size | `vim.o.columns` |
| -------------- | --------: | --------------: |
| MacBook Pro 14 |        12 |             215 |
| MacBook Pro 14 |        13 |             188 |
| 5K 27-inch     |        15 |             284 |
