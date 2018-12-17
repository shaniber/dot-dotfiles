"
" Custom configurations for vim.
" Global settings for all files (but may be overridden in ~/.vim/ftplugin/*.vim)
" http://vim.wikia.com/wiki/Keep_your_vimrc_file_clean

" Colour reference: 
" http://vim.wikia.com/wiki/Xterm256_color_names_for_console_Vim

""" Vundle
"set nocompatible
"filetype off

" set the runtime path to include Vundle and initialize.
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()

" let Vundle manage itself.
"Plugin 'gmarik/Vundle'

"Plugin 'scrooloose/nerdtree'
"Plugin 'flazz/vim-colorschemes'

"call vundle#end()
"filetype plugin indent on


""" Tabs
set tabstop=4
set shiftwidth=4
"set expandtab


""" Searching
set incsearch
set ignorecase
set hlsearch
" Press space to clear search highlighting and any message already displayed.
nnoremap <silent> <Space> :silent noh<Bar>echo<CR>


""" Colour scheme
colorscheme shaniber


""" Syntax highlighting
filetype plugin indent on
syntax on

""" Line numbers
set number

""" Turn off auto commenting
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

""" Other stuff, I guess.
set ruler
set statusline=%<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P
set ls=2
au FileType javascript setl sw=2 sts=2 et
