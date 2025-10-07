vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    -- option for remove continue commenting when line changes
    -- r: continue commenting when line changed by enter
    -- o: continue commenting when line changed by o or O command
    vim.opt_local.formatoptions:remove({ "o" })
  end,
})

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight when yanking (copying) text",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- To keep fold state
vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "*",
  callback = function()
    local is_normal_buffer = vim.bo.filetype ~= "" and vim.bo.buftype == ""
    if is_normal_buffer then
      -- make(save) view state: ex) folds, cursor position, etc.
      vim.cmd("silent! mkview")
    end
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  pattern = "*",
  callback = function()
    local is_normal_buffer = vim.bo.filetype ~= "" and vim.bo.buftype == ""
    if is_normal_buffer then
      vim.cmd("silent! loadview")
    end
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
