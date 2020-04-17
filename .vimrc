" Install vim-plug if not installed
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

call plug#begin()
Plug 'tpope/vim-sensible'
Plug 'airblade/vim-gitgutter'
Plug 'jamessan/vim-gnupg'
call plug#end()

color twilight-fryguy
set number
set updatetime=250
let g:gitgutter_sign_column_always=1
