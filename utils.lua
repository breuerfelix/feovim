local function keymap(...) vim.keymap.set(...) end
local function nmap(...) keymap('n', ...) end
