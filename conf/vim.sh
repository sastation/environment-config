#!/bin/sh

Common() {
    #echo >> ~/.profile
    #echo "export TERM='xterm-256color'" >> ~/.profile
    
    mkdir -p ~/.vim/autoload ~/.vim/bundle ~/.vim/colors
    
    sudo pip install jedi
}


Install() {
    cd ~/.vim/autoload
    wget https://raw.github.com/tpope/vim-pathogen/master/autoload/pathogen.vim

    cd ~/.vim/bundle
    git clone --depth=1  https://github.com/tomtom/tlib_vim.git
    git clone --depth=1  https://github.com/MarcWeber/vim-addon-mw-utils.git
    git clone --depth=1  https://github.com/garbas/vim-snipmate.git
    git clone --depth=1  https://github.com/honza/vim-snippets.git

    cd ~/.vim/bundle
    git clone --depth=1  https://github.com/scrooloose/nerdtree.git

    cd ~/.vim/bundle
    git clone --depth=1  https://github.com/majutsushi/tagbar.git

    cd ~/.vim/bundle
    git clone --depth=1  https://github.com/davidhalter/jedi-vim
    cd jedi-vim
    git submodule update --init

    cd ~/.vim/colors
    wget https://raw.githubusercontent.com/chriskempson/tomorrow-theme/master/vim/colors/Tomorrow-Night-Bright.vim
    sed -i 's/^\(let s:comment.*\)/\"\1\nlet s:comment = "cfa8a6"/g' Tomorrow-Night-Bright.vim
}

Copy() {
    tar zxvf conf/dotvim.tar.gz -C ~/.vim/
}

Main() {
    printf "Do you want to install or copy? (Install/Copy/Skip)? " 
    read opt
    case $opt in
    i|I)
        Common
        Install
    ;;
    c|C)
        Common
        Copy
    ;;
    *)
        echo "Skip ... ..."
    esac
    return 0
}

Main
