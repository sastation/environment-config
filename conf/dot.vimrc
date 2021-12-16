set t_ti= t_te=            " donot send terminal signal to clear screen on quit
set t_Co=256
"set term=term              " terminal type, but it also doesn't clear screen on quit
"set background=light
"colorscheme default
"colorscheme desert
"colorscheme ron
"colorscheme elflord
colorscheme Tomorrow-Night-Bright
set background=dark

syntax on
filetype on

"set foldenable             " 开始折叠
"set foldcolumn=0           " 设置折叠区域的宽度
"setlocal foldlevel=1       " 设置折叠层数为
"set foldclose=all          " 设置为自动关闭折叠                
set foldmethod=indent       " 设置语法折叠
set nofoldenable            " 打开文件是默认不折叠代码
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
                            " 用空格键来开关折叠

set ai "set autoindent
"set noai "set noautoindent

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

execute pathogen#infect()
filetype plugin on
autocmd FileType python set omnifunc=python3complete#Complete

set formatoptions+=mM
set formatoptions-=r

"autocmd FileType python setlocal completeopt-=preview

nmap <F7> :NERDTree<cr>
nmap <F8> :TagbarToggle<cr>
nmap <c-h> :hide<cr>
set pastetoggle=<F9> "以后在插入模式下，只要按F9键就可以切换自动缩进。

let mapleader=";"
nnoremap    <Leader>l  <c-w>l
nnoremap    <Leader>h  <c-w>h
nnoremap    <Leader>k  <c-w>k
nnoremap    <Leader>j  <c-w>j
nnoremap    <Leader>w   <c-w><c-w>

set incsearch "实时搜索
set ignorecase "搜索时大小写不敏感
set nocompatible "关闭兼容模式
set wildmenu "vim 自身命令行模式智能补全
set nowrap "禁止自动折行
set noruler "显示光标当前位置
set nonumber "并闭开启行号显示

if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif

let g:snipMate = { 'snippet_version' : 1 }
