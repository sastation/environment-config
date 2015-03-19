syntax on
"colorscheme pablo
"colorscheme zwang
set autoindent
set noautoindent

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

autocmd FileType python,html,HTML set softtabstop=4 | set shiftwidth=4 | set expandtab
autocmd FileType c,cpp set softtabstop=4 | set shiftwidth=4 | set expandtab

set formatoptions+=mM
set formatoptions-=r
