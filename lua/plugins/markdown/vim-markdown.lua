return {
  "preservim/vim-markdown",
  dependencies = { "godlygeek/tabular" },
  ft = { "markdown" },
  init = function()
    vim.g.vim_markdown_auto_insert_bullets = 1 -- 줄바꿈 시 bullet 자동 삽입
    vim.g.vim_markdown_folding_disabled = 1
    vim.g.vim_markdown_conceal = 2 -- 마크다운 구문 숨김 수준 (0=없음, 1=일부, 2=전체)
    vim.g.vim_markdown_conceal_code_blocks = 0
    vim.g.vim_markdown_follow_anchor = 1
    vim.g.vim_markdown_frontmatter = 1 -- YAML 프론트매터 지원
    vim.g.vim_markdown_strikethrough = 1
    vim.g.vim_markdown_new_list_item_indent = 4
    vim.g.vim_markdown_toc_autofit = 1 -- TOC 자동 맞춤
    vim.g.vim_markdown_math = 1 -- LaTeX 수학 문법 지원
    vim.g.vim_markdown_fenced_languages = { -- 펜스드 코드 블록에서 구문 강조할 언어들
      "c",
      "cpp",
      "python",
      "javascript",
      "js=javascript",
      "typescript",
      "ts=typescript",
      "rust",
      "lua",
      "vim",
      "bash",
      "sh",
      "json",
      "yaml",
      "html",
      "css",
    }
  end,
  config = function()
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "markdown",
      callback = function(ev)
        local function map(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = ev.buf
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        map("n", "<leader>mo", ":Toc<CR>", { desc = "Markdown TOC" })
      end,
    })
  end,
}
