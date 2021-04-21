map <Space> <Leader>
set belloff=all
set clipboard=unnamedplus

" Install vim-plug if not found
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin('~/.vim/plugged')

Plug 'dracula/vim', { 'as': 'dracula' }

Plug 'junegunn/vim-easy-align'

Plug 'https://github.com/tpope/vim-surround.git'

Plug 'preservim/nerdtree'

Plug 'preservim/nerdcommenter'

call plug#end()

colorscheme dracula
