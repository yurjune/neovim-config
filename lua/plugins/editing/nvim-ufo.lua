return {
  "kevinhwang91/nvim-ufo",
  dependencies = {
    "kevinhwang91/promise-async",
  },
  config = function()
    local ufo = require("ufo")

    ufo.setup({
      open_fold_hl_timeout = 0, -- highlight duration after opening a fold
      provider_selector = function()
        -- indent provider is more similar to vscode folding
        return { "treesitter", "indent" }
      end,

      -- show folded line count with virtual text
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        local newVirtText = {}
        local suffix = ("  󰁂 %d Folded "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0

        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)

          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end

        -- change 'MoreMsg' to another to change the color of the suffix
        -- table.insert(newVirtText, { suffix, "MoreMsg" })
        table.insert(newVirtText, { suffix, "Number" })

        return newVirtText
      end,
    })

    vim.keymap.set("n", "zr", ufo.openFoldsExceptKinds, { desc = "Open folds except kinds" })
    vim.keymap.set("n", "zR", ufo.openAllFolds, { desc = "Open all folds" })
    vim.keymap.set("n", "zm", ufo.closeFoldsWith, { desc = "Close folds with" }) -- closeAllFolds == closeFoldsWith(0)
    vim.keymap.set("n", "zM", ufo.closeAllFolds, { desc = "close all folds" })
  end,
}
