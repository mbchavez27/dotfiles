-- Dynamically add nvm node to PATH
local nvm_dir = os.getenv("HOME") .. "/.nvm/versions/node/"
local handle = io.popen("nvm current 2>/dev/null")
local version = handle:read("*l")
handle:close()
if version and version ~= "system" then
  vim.env.PATH = nvm_dir .. version .. "/bin:" .. vim.env.PATH
end

require("config.lazy")
