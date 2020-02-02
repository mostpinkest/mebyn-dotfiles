set belloff=all

call plug#begin('~/.vim/plugged')

Plug 'dracula/vim', { 'as': 'dracula' }

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

call plug#end()

colorscheme dracula
