-- Switch input source when leave or enter insert mode

local last_input_source = nil
local en_input_source = "com.apple.keylayout.ABC"

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

local function set_input_source_async(im)
  if not im or im == "" then
    return
  end
  vim.fn.jobstart("im-select " .. im)
end

local augroup = vim.api.nvim_create_augroup("SwitchInputOnInsert", { clear = true })

-- save current input source change change source to EN when leave insert mode
vim.api.nvim_create_autocmd("InsertLeave", {
  group = augroup,
  pattern = "*",
  callback = function()
    get_input_source_async(function(im)
      if im and im ~= "" then
        last_input_source = im
      end
    end)

    set_input_source_async(en_input_source)
  end,
})

-- restore last input source when enter insert mode
vim.api.nvim_create_autocmd("InsertEnter", {
  group = augroup,
  pattern = "*",
  callback = function()
    if last_input_source and last_input_source ~= "" and last_input_source ~= en_input_source then
      set_input_source_async(last_input_source)
    end
  end,
})
