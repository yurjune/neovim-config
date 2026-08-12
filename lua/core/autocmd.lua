vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- option for remove continue commenting when line changes
    -- r: continue commenting when line changed by enter
    -- o: continue commenting when line changed by o or O command
    vim.opt_local.formatoptions:append({ "r", "o" })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.conceallevel = 2
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

-- DirChanged 이벤트에 의해 cwd 가 변경되면 initial_cwd 로 복구
-- 1. 항상 neovim 을 시작한 디렉토리를 루트로 고정
-- 2. 특정 버퍼가 열리면 의도하지 않은 cwd 이 변경이 일어나는 문제를 방지
local initial_cwd = vim.fn.getcwd()
vim.api.nvim_create_autocmd("DirChanged", {
  callback = function()
    local current_cwd = vim.fn.getcwd()
    if current_cwd ~= initial_cwd then
      vim.notify("Restore initial cwd", vim.log.levels.INFO, { title = "Directory Change" })
      vim.cmd("cd " .. initial_cwd)
    end
  end,
})
