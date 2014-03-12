"
" Custom configurations for vim.
" Global settings for all files (but may be overridden in ~/.vim/ftplugin/*.vim)
" http://vim.wikia.com/wiki/Keep_your_vimrc_file_clean

" Tabs
set tabstop=4
set shiftwidth=4
set noexpandtab

" Searching
set incsearch
set ignorecase
set hlsearch
" Press space to clear search highlighting and any message already displayed.
nnoremap <silent> <Space> :silent noh<Bar>echo<CR>

" Colour scheme
colorscheme koehler

" Syntax highlighting
filetype plugin indent on
syntax on

