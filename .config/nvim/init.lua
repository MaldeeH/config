_G.NVIM_START_DIR = vim.fn.getcwd()
vim.cmd([[set noswapfile]])
vim.opt.winborder = "rounded"
vim.opt.number = true
vim.opt.wrap = true
vim.opt.swapfile = false
vim.opt.smartindent = true
vim.opt.termguicolors = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.laststatus = 2
vim.opt.winblend = 0
vim.opt.linebreak = true
vim.opt.breakindent = true
vim.diagnostic.config({
	virtual_text = true,
	signs = false,
	underline = true,
	update_in_insert = false,
})

--plugins
vim.pack.add( {
	{ src = "https://github.com/sainnhe/gruvbox-material" },
	{ src = "https://github.com/stevearc/oil.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/mason-org/mason.nvim" },
	{ src = "https://github.com/mason-org/mason-lspconfig.nvim" },
	{ src = "https://github.com/nvim-telescope/telescope.nvim",          version = "0.1.8" }, 
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
})

--plugin configs
require "mason".setup()
require("telescope").setup()
require("mason-lspconfig").setup({
	ensure_installed = { "tinymist" }
})

require("oil").setup({
	skip_confirm_for_simple_edits=true,
	delete_to_trash = true,
	win_options = {
		conceallevel = 3,
		concealcursor = "nvic",
	},
})

local telescope = require("telescope")
telescope.setup({
	defaults = {
		preview = { treesitter = false },
		color_devicons = true,
		sorting_strategy = "ascending",
		path_displays = { "smart" },
		layout_config = {
			height = 100,
			width = 400,
			prompt_position = "top",
			preview_cutoff = 10,
		}
	}
})

-- colors
vim.cmd("colorscheme gruvbox-material")
vim.g.gruvbox_material_background = 'medium'
vim.g.gruvbox_material_foreground = 'material'
local function set_diag_colors()
	local light_red = "#ff6b6b"
	local light_yellow = "#ffea00"
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextError", { fg = light_red, bg = "NONE" })
	vim.api.nvim_set_hl(0, "DiagnosticVirtualLinesError", { fg = light_red, bg = "NONE" })
	vim.api.nvim_set_hl(0, "DiagnosticVirtualTextWarn",   { fg = light_yellow, bg = "NONE" })
	vim.api.nvim_set_hl(0, "DiagnosticVirtualLinesWarn",  { fg = light_yellow, bg = "NONE" })
end
set_diag_colors()
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })

local function apply_dim()
  for _, name in ipairs(vim.fn.getcompletion('', 'highlight')) do
    local ok, hl = pcall(vim.api.nvim_get_hl, 0, { name = name, link = false })
    if ok and hl.fg then
      vim.api.nvim_set_hl(0, name, vim.tbl_extend('force', hl, { fg = 0x928374 }))
    end
  end
end

local function restore_colors()
  vim.cmd("colorscheme gruvbox-material")
  set_diag_colors()
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineError", { fg = "#ff6b6b", bg = "NONE" })
  vim.api.nvim_set_hl(0, "StatusLineWarn",  { fg = "#ffea00", bg = "NONE" })
end

vim.api.nvim_create_autocmd("FocusLost", { callback = apply_dim })
vim.api.nvim_create_autocmd("FocusGained", { callback = restore_colors })
vim.api.nvim_set_hl(0, "FloatBorder", { bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineError", { fg = "#ff6b6b", bg = "NONE" })
vim.api.nvim_set_hl(0, "StatusLineWarn",  { fg = "#ffea00", bg = "NONE" })

--statusline
function _G.Statusline_error_count()
  local bufnr = 0
  local errors = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.ERROR })
  if errors == 0 then
    return ""
  end
  return "E" .. errors
end

function _G.Statusline_warn_count()
  local bufnr = 0
  local warns = #vim.diagnostic.get(bufnr, { severity = vim.diagnostic.severity.WARN })
  if warns == 0 then
    return ""
  end
  return "W" .. warns
end

function _G.Statusline_git_branch()
  if vim.bo.filetype == "oil" then
    return ""
  end
  local dir = vim.fn.expand("%:p:h")
  if dir == "" then
    dir = vim.fn.getcwd()
  end
  local git_dir = vim.fn.finddir(".git", dir .. ";")
  if git_dir == "" then
    return "" -- not a git repo
  end
  local result = vim.fn.systemlist({ "git", "-C", dir, "rev-parse", "--abbrev-ref", "HEAD" })
  local branch = result[1] or ""
  if branch == "" or branch:match("^fatal:") then
    return ""
  end
  return " on " .. branch
end

vim.o.statusline = table.concat({
  "%f",  -- file path
  "%{v:lua.Statusline_git_branch()}", -- branch

  "%=", -- Spacing

  "%#StatusLineError#",
  "%{v:lua.Statusline_error_count()}",
  "%*",
  " ",
  "%{&modified ? '✱' : ''}",
  "%#StatusLineWarn#",
  "%{v:lua.Statusline_warn_count()}",
  "%*",
  " ",

  "%=",

  "%{printf('%4d:%-3d', line('.'), col('.'))} ",
})

--lsp
vim.lsp.config('clangd', {
	cmd = { 'clangd', '--compile-commands-dir=build' },
	filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
})

vim.lsp.config('tinymist', {
	cmd = { 'tinymist' },
	filetypes = { 'typst' },
	root_markers = { 'typst.toml', '.git' },
	settings = {
		exportPdf = "never",
		formatterMode = "typstyle",
	},
})

vim.lsp.enable('clangd')
vim.lsp.enable('lua_ls')
vim.lsp.enable('tinymist')
vim.lsp.enable('glsl_analyzer')

-- Keybinds:
local init = vim.fs.normalize(vim.fn.stdpath("config") .. "/init.lua")
vim.api.nvim_create_user_command("Config", function()
	vim.cmd.edit(vim.fn.fnameescape(init))
end, { desc = "Open init.lua" })
vim.g.mapleader = " "
vim.keymap.set({"n", "v"}, "j", "gj")
vim.keymap.set({"n", "v"}, "k", "gk")
vim.keymap.set("n", "<leader>q", ':q<CR>')
vim.keymap.set("n", "<leader>w", ':w<CR>')
vim.keymap.set("n", "<leader>c", [[:%s/\<<C-r><C-w>\>//gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>e", "<cmd>Oil<CR>")
vim.keymap.set("n", "<leader>tp", "<cmd>w<CR><cmd>!typst compile %<CR>")
vim.keymap.set("n", "<leader>r", ":e!<CR>")
vim.keymap.set("n", "<leader>f", ":Telescope find_files <CR>")
vim.keymap.set("n", "<leader>h", ":ClangdSwitchSourceHeader <CR>")
vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
vim.keymap.set("n", "K",  vim.lsp.buf.hover, opts)
vim.keymap.set("n", "<leader>n", function()
	vim.cmd("vsplit ~/notes/notes.md")
end, { desc = "Open notes.md in split" })
vim.keymap.set("v", "<M-c>", '"+y')
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR><Esc>", {
	silent = true,
	desc = "Clear search highlight",
})

vim.keymap.set("n", "<leader>gg", function()
  local dir = _G.NVIM_START_DIR
  vim.cmd("Oil " .. vim.fn.fnameescape(dir))
end, { desc = "Open start directory in Oil" })
vim.keymap.set("n", "<leader>cd", function()
  local dir
  if vim.bo.filetype == "oil" then
    dir = require("oil").get_current_dir()
  else
    dir = vim.fn.expand("%:p:h")
  end
  if not dir or dir == "" then
    dir = vim.fn.getcwd()
  end
  vim.fn.setreg("+", dir)
  vim.notify("Copied directory: " .. dir, vim.log.levels.INFO)
end, { desc = "Copy directory of current file/Oil view" })

-- Well-Specific Keybinds:
-- Watch Logs
vim.keymap.set("n", "<leader>al", function()
  vim.cmd([[terminal powershell -NoLogo -Command "Get-Content '.\WellPluginLog.txt' -Tail 150 -Wait"]])
  vim.schedule(function()
    vim.cmd("normal! G")
  end)
end, { desc = "Tail WellPluginLog.txt" })

-- build
vim.keymap.set("n", "<leader>ab", function()
  local dir = _G.NVIM_START_DIR or vim.fn.getcwd()
  local command = "pkill -f AudioPluginHost 2>/dev/null; cmake --build build --target Well_VST3; echo 'Build finished. Press Enter to close'; read"
  vim.cmd("enew")
  vim.fn.termopen({ "zsh", "-lc", command }, { cwd = dir })
  vim.cmd("startinsert")
end, { desc = "Build Well_VST3 (cmake --build build --target Well_VST3)" })

-- Run AudioPluginHost
vim.keymap.set("n", "<leader>ar", function()
  local dir = _G.NVIM_START_DIR or vim.fn.getcwd()
  vim.fn.jobstart({ "open", vim.fn.expand("~/code-tools/AudioPluginHost.app") }, {
    cwd = dir,
    detach = true,
  })
end, { desc = "Run AudioPluginHost.app" })

-- ctrl + g to see number of lines in file
-- ( CTRL + R + " ) to paste while in insert mode
-- ctrl + o to jump back
-- ctrl + i to rejump forward
--
--Show diagnosics: <C-w>d
--Jump diagnostics: ]d or [d
--
--
-- Deep tools:
-- lldb, valgrind, buildling with fsanitizer. This is the approach for the future for c++
-- How can i do execute the "fix available"? - just press "g r a" (should work)
-- [d and ]d to jump diagnostics
--
-- MORE TODO:
-- when copying from oil it should not show the line numbers 
-- public private should not cause indentation with autoindent

-- Branch name in bottom bar (eg. on master )does not work for worktrees
-- Add a shortcut to oil that executes a script when hovering over a line
