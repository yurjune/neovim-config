-- Run from the repository root with: nvim -l tests/run.lua
vim.opt.runtimepath:prepend(vim.fn.stdpath("data") .. "/lazy/plenary.nvim")
require("plenary.test_harness").test_directory("tests", { minimal_init = "NONE" })
