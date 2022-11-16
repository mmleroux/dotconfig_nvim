----------------------------------------
-- Packman, the not-a-package-manager
--
-- Use nvim's default site and and only manage installing/loading/cleaning
-- packs as submodules.
----------------------------------------

local M = {}

local install_path = vim.fn.stdpath("config") .. "/site/"
vim.opt.packpath:append(install_path)
local packs_dir = "pack/mmleroux/opt/"
local breadcrumbs = vim.fn.readdir(install_path .. packs_dir)

----------------------------------------
-- Bootstrap Site Packs
----------------------------------------
function M.setup(packs)

  local has_errors = false
  for i, pack in pairs(packs) do
    local eager = false
    if type(pack) == "table" then
      local pack_opt = pack
      pack = pack[1]
      eager = pack_opt["eager"]
    end
    local p = string.gsub(pack, "^[^/]+/", "")
    local pack_dir = packs_dir .. p;
    local abs_pack_dir = install_path .. pack_dir;
    if #(vim.fn.glob(abs_pack_dir)) == 0 then
      print("[", i, "/", #packs, "] Adding submodule pack for", p)
      print(vim.fn.system({ "git", "-C", vim.fn.stdpath("config"), "submodule", "add", "--force", "https://github.com/" .. pack,
        "site/" .. pack_dir }))
    end
    if #(vim.fn.readdir(abs_pack_dir)) == 0 then
      print("[", i, "/", #packs, "] Pulling submodule pack for", p)
      vim.fn.system({ "git", "-C", vim.fn.stdpath("config"), "submodule", "update", "--init", "site/pack/mmleroux/opt/" .. p })
    end
    if not has_errors then vim.cmd("redrawstatus") end
    print("loading pack", p)
    if eager then
      table.insert(vim.opt.runtimepath, 0, abs_pack_dir)
    end
    if not pcall(vim.cmd, "packadd! " .. p) then -- lazy pack load, so config globals are initialized
      print("Issue loading pack", p)
      has_errors = true
    end
    for k, v in pairs(breadcrumbs) do
      if v == p then table.remove(breadcrumbs, k) end
    end
  end
  vim.cmd "helptags ALL"
  if #breadcrumbs > 0 then
    local msg = "leftover packs: "
    for _, v in pairs(breadcrumbs) do
      msg = msg .. v .. " "
    end
    print(msg)
  else
    if not has_errors then vim.cmd("redraw") end
  end
end

function M.PackUp()
  print("This is might take a while...")
  print(vim.fn.system({ "git", "-C", vim.fn.stdpath("config"), "submodule", "update", "--remote" }))
end

function M.PackClean()
  for _, v in pairs(breadcrumbs) do
    local dst = install_path .. packs_dir .. v
    print("Trimming", dst)
    vim.fn.delete(dst, "rf")
  end
end

vim.api.nvim_create_user_command("PackUp", M.PackUp, { desc = "Update plugin submodules" })
vim.api.nvim_create_user_command("PackClean", M.PackClean, { desc = "Clean unused plugins submodules" })

return M
