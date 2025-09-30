-- ========================
-- Neovim init.lua
-- ========================

local o = vim.o
local wo = vim.wo
local opt = vim.opt

-- ========================
-- General Settings
-- ========================
o.compatible = false
wo.number = true
wo.cursorline = true
o.expandtab = true
o.autoindent = true
o.autoread = true
o.backspace = "indent,eol,start"
o.foldenable = true
o.foldmethod = "syntax"
o.foldlevel = 0
o.foldnestmax = 5
opt.formatoptions = "croq2nl1"
o.hidden = true
o.history = 500
o.hlsearch = true
o.ignorecase = true
o.incsearch = true
o.lazyredraw = true
o.mouse = "a"
o.errorbells = false
o.showmode = false
o.wrap = false
o.scrolloff = 3
o.shiftwidth = 4
o.softtabstop = 4
opt.shortmess:append("I")
o.smartcase = true
o.splitbelow = true
o.splitright = true
o.undofile = true
o.ruler = true
o.wildmenu = true
o.wildmode = "list:longest"
opt.termguicolors = true
o.encoding = "utf-8"

-- Lisp words
opt.lispwords:append({ "defroutes","defpartial","defpage","defaction","deffilter","defview","defsection","describe","it" })

-- Wildignore
opt.wildignore:append({
     ".DS_Store",
     "*.jpg","*.jpeg","*.gif","*.png","*.psd","*.o","*.obj","*.min.js",
     "*/node_modules/*","*/vendor/*","*/.git/*","*/.hg/*","*/.svn/*","*/.sass-cache/*",
     "*/log/*","*/tmp/*","*/build/*","*/dist/*"
})

-- Directories
local data_path = vim.fn.stdpath("data")
opt.backupdir = data_path .. "/backup"
opt.directory = data_path .. "/swap"
opt.undodir = data_path .. "/undo"

-- ========================
-- Plugin Management (lazy.nvim)
-- ========================
local lazypath = data_path .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
     vim.fn.system({
          "git", "clone", "--filter=blob:none",
          "https://github.com/folke/lazy.nvim.git",
          "--branch=stable", lazypath,
     })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

     -- Telescope + File Browser
     { "nvim-telescope/telescope.nvim", branch = "0.1.x", dependencies = { "nvim-lua/plenary.nvim" }, cmd = "Telescope" },
     { "nvim-telescope/telescope-file-browser.nvim" },

     -- nvim-tree (Side directory tree)
     {
          "nvim-tree/nvim-tree.lua",
          dependencies = { "nvim-tree/nvim-web-devicons" },
          cmd = { "NvimTreeToggle", "NvimTreeFindFile" },
          keys = {
               { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle File Explorer" },
          },
          config = function()
          require("nvim-tree").setup({
               view = {
                    width = 30,
                    side = "left",
               },
               renderer = {
                    highlight_git = true,
                    highlight_opened_files = "all",
               },
               filters = {
                    dotfiles = false, -- Show hidden files
               },
               git = {
                    enable = true,
               },
          })
          end,
     },

     -- Colorscheme
     { "dikiaap/minimalist", name = "minimalist", lazy = false, priority = 1000 },

     -- EditorConfig
     { "editorconfig/editorconfig-vim", event = "BufReadPre" },

     -- Emmet
     { "mattn/emmet-vim", ft = { "html", "css", "javascript", "php" } },

     -- Polyglot
     { "sheerun/vim-polyglot", lazy = false },

     -- Fugitive
     { "tpope/vim-fugitive", cmd = { "Git", "Gdiff", "Glog" } },

     -- Lualine (statusline)
     { "nvim-lualine/lualine.nvim", event = "VeryLazy", dependencies = { "nvim-tree/nvim-web-devicons" } },

     -- Null-ls (replaces syntastic)
     { "jose-elias-alvarez/null-ls.nvim", event = "BufReadPre", dependencies = { "nvim-lua/plenary.nvim" } },

     -- nvim-treesitter, loading only when a Lua or Python file is opened
     {
         'nvim-treesitter/nvim-treesitter',
         -- run = ':TSUpdate',
         event = 'BufReadPost',  -- This will load after a file is opened
         config = function()
         require'nvim-treesitter.configs'.setup {
             ensure_installed = { "lua" },  -- You can list all the languages you need: "lua", "python", "javascript", "typescript"
             highlight = {
                 enable = true,  -- Enable syntax highlighting
             },
             -- You can add more configurations here if needed
         }
         end,
         ft = { "lua" },  -- Trigger when opening specific file types: "lua", "python", "javascript", "typescript"
     },
})

-- ========================
-- Colorscheme
-- ========================
local ok, _ = pcall(vim.cmd, "colorscheme minimalist")
if not ok then
     vim.notify("colorscheme 'minimalist' not found!", vim.log.levels.WARN)
end

-- ========================
-- Null-ls setup
-- ========================
local null_ls = require("null-ls")
null_ls.setup({
     sources = {
          null_ls.builtins.formatting.prettier,
          null_ls.builtins.diagnostics.eslint,
          null_ls.builtins.diagnostics.php,
     },
     on_attach = function(_, bufnr)
     local opts = { noremap=true, silent=true, buffer=bufnr }
     vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
     vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
     vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts)
     end,
})

-- ========================
-- Lualine (statusline)
-- ========================
require('lualine').setup {
     options = {
          theme = 'auto',
          section_separators = '',
          component_separators = '',
          icons_enabled = true,
     },
     sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff'},
          lualine_c = {'filename'},
          lualine_x = {'encoding','fileformat','filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
     },
}

-- ========================
-- Telescope setup
-- ========================
local telescope = require("telescope")
local fb_actions = require("telescope").extensions.file_browser.actions

telescope.setup({
     defaults = {
          prompt_prefix = "🔍 ",
          selection_caret = " ",
          path_display = {"smart"},
     },
     extensions = {
          file_browser = {
               theme = "ivy",
               hijack_netrw = true,
               hidden = true,  -- Show hidden files
               mappings = {
                    ["i"] = { ["<C-w>"] = fb_actions.goto_parent_dir },
                    ["n"] = { ["h"] = fb_actions.goto_parent_dir }
               }
          }
     }
})

telescope.load_extension("file_browser")

-- ========================
-- Keymaps
-- ========================
vim.keymap.set('n', '<leader>ff', '<cmd>Telescope find_files<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { noremap=true, silent=true })
vim.keymap.set('n', '<leader>fe', '<cmd>Telescope file_browser<cr>', { noremap=true, silent=true })
