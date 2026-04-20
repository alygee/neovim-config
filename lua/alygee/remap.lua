-- [[ Basic Keymaps ]]

-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ "n", "v" }, "<Space>", "<Nop>", { silent = true })

-- Remap for dealing with word wrap
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- greatest remap ever
vim.keymap.set("x", "<leader>p", '"_dP')

-- next greatest remap ever : asbjornHaland
vim.keymap.set("n", "<leader>y", '"+y')
vim.keymap.set("v", "<leader>y", '"+y')
vim.keymap.set("n", "<leader>Y", '"+Y')

vim.keymap.set("n", "<leader>d", '"_d')
vim.keymap.set("v", "<leader>d", '"_d')

-- This is going to get me cancelled
vim.keymap.set("i", "<C-c>", "<Esc>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "Q", "<nop>")
vim.keymap.set("n", "<C-f>", "<cmd>silent !tmux neww tmux-sessionizer<CR>")
-- vim.keymap.set("n", "<leader>f", function()
--   vim.lsp.buf.format()
-- end)

vim.keymap.set("n", "<Alt-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<Alt-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Clear highlights on search when pressing <Esc> in normal mode
--  See `:help hlsearch`
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Diagnostic keymaps
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })

vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

vim.keymap.set("n", "<leader>debug", function()
  print("Leader H is working!")
  require("harpoon"):list():add()
  print("File added to harpoon")
end, { desc = "Debug Harpoon" })

local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function()
  harpoon:list():add()
end)
vim.keymap.set("n", "<C-e>", function()
  harpoon.ui:toggle_quick_menu(harpoon:list())
end)

vim.keymap.set("n", "<A-1>", function()
  harpoon:list():select(1)
end)
vim.keymap.set("n", "<A-2>", function()
  harpoon:list():select(2)
end)
vim.keymap.set("n", "<A-3>", function()
  harpoon:list():select(3)
end)
vim.keymap.set("n", "<A-4>", function()
  harpoon:list():select(4)
end)
vim.keymap.set("n", "<A-5>", function()
  harpoon:list():select(5)
end)
vim.keymap.set("n", "<A-6>", function()
  harpoon:list():select(6)
end)
vim.keymap.set("n", "<A-7>", function()
  harpoon:list():select(7)
end)
vim.keymap.set("n", "<A-8>", function()
  harpoon:list():select(8)
end)
vim.keymap.set("n", "<A-9>", function()
  harpoon:list():select(9)
end)

-- Toggle previous & next buffers stored within Harpoon list
vim.keymap.set("n", "<C-S-P>", function()
  harpoon:list():prev()
end)
vim.keymap.set("n", "<C-S-N>", function()
  harpoon:list():next()
end)

local function get_dotnet_workdir()
  local current_file = vim.api.nvim_buf_get_name(0)
  local start_path = current_file ~= "" and vim.fn.fnamemodify(current_file, ":p:h") or vim.loop.cwd()

  local solution = vim.fs.find(function(name)
    return name:match("%.sln$") ~= nil
  end, { path = start_path, upward = true, type = "file" })[1]

  if solution ~= nil then
    return vim.fs.dirname(solution)
  end

  local project = vim.fs.find(function(name)
    return name:match("%.csproj$") ~= nil
  end, { path = start_path, upward = true, type = "file" })[1]

  if project ~= nil then
    return vim.fs.dirname(project)
  end

  return nil
end

local function run_dotnet(command)
  local workdir = get_dotnet_workdir()

  if workdir == nil then
    workdir = vim.loop.cwd()
    vim.notify("Не найден .sln или .csproj, запускаю команду из текущей директории", vim.log.levels.WARN)
  end

  vim.cmd("botright split")
  vim.cmd("resize 12")
  -- Иначе split даёт два окна на один буфер — termopen превратит его в терминал сразу вверху и внизу.
  vim.cmd("enew")
  vim.fn.termopen(command, { cwd = workdir })
  vim.cmd("startinsert")
end

-- Префикс <leader>n, а не <leader>d: иначе пересекается с группой which-key «[D]ocument»
-- и команда может выполниться дважды (два split с терминалом).
vim.keymap.set("n", "<leader>nb", function()
  run_dotnet("dotnet build")
end, { desc = "Dotnet: сборка" })

vim.keymap.set("n", "<leader>nr", function()
  run_dotnet("dotnet run")
end, { desc = "Dotnet: запуск" })

vim.keymap.set("n", "<leader>nt", function()
  run_dotnet("dotnet test")
end, { desc = "Dotnet: тесты" })

vim.keymap.set("n", "<leader>nc", function()
  run_dotnet("dotnet clean")
end, { desc = "Dotnet: очистка" })

vim.keymap.set("n", "<leader>nw", function()
  run_dotnet("dotnet watch run")
end, { desc = "Dotnet: watch run" })
