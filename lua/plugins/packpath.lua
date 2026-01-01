local data_site = vim.fn.stdpath("data") .. "/site"

-- vim.pack installs to $XDG_DATA_HOME/nvim/site/pack/core/opt, but our config
-- overwrote 'packpath' to the runtime-only path, so Neovim couldn't find the
-- opt packages. Add stdpath("data")/site back to keep vim.pack plugins visible.
local pack = vim.opt.packpath:get()
if type(pack) == "string" then
  pack = vim.split(pack, ",", { plain = true })
end

if not vim.tbl_contains(pack, data_site) then
  table.insert(pack, data_site)
end
if not vim.tbl_contains(pack, data_site .. "/after") then
  table.insert(pack, data_site .. "/after")
end

vim.opt.packpath = pack
