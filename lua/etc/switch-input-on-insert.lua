local last_input_source = nil
local english_input_source = "com.apple.keylayout.ABC"

-- 비동기로 현재 입력 소스 가져오기
local function get_input_source_async(callback)
  vim.fn.jobstart("im-select", {
    on_stdout = function(_, data)
      if data and data[1] then
        local im = vim.fn.trim(data[1])
        callback(im)
      end
    end,
    stdout_buffered = true,
  })
end

-- 비동기로 입력 소스 설정하기
local function set_input_source_async(im)
  if not im or im == "" then
    return
  end
  vim.fn.jobstart("im-select " .. im)
end

-- 자동 명령어 설정
local augroup = vim.api.nvim_create_augroup("ImSelectManager", { clear = true })

-- Insert 모드에서 나갈 때 영문으로 전환하고 현재 입력소스 저장
vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  pattern = "*",
  callback = function()
    get_input_source_async(function(im)
      if im and im ~= "" then
        last_input_source = im
      end
    end)

    set_input_source_async(english_input_source)
  end,
})

-- Insert 모드 진입 시 이전 입력소스로 복원
vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  pattern = "*",
  callback = function()
    if last_input_source and last_input_source ~= "" and last_input_source ~= english_input_source then
      set_input_source_async(last_input_source)
    end
  end,
})
