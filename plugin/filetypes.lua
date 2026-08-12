-- Neotest discovers tests in an isolated child Neovim process.
-- The child loads the parsers but misses nvim-treesitter's React filetype mappings,
-- so register them here.
-- Can be removed if Neotest handle this automatically.
vim.treesitter.language.register("javascript", "javascriptreact")
vim.treesitter.language.register("tsx", "typescriptreact")
