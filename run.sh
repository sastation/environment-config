#!/bin/bash

AG='sudo apt-get '
MAX=30
MASK=50

os_type='None'

OS() {
    if [ -e /etc/issue ]; then
        os_type='ubuntu'
    elif [ -e /etc/redhat-release ]; then
         os_type='redhat'
    elif [ -e /etc/debian_version ]; then
         os_type='debian'
    else
        os_type='unknow'
    fi
}
OS #get operation distribution
if [ $os_type != "ubuntu" -a $os_type != "debian" ]; then
    echo "Only for Ubuntu/Debian!"
    echo "Your OS: "$os_type
    exit -1
fi

Apt() {
    # install packages for ubuntu
    local pkg=$1
    printf "Do you want to install %s? (y/No)? " $pkg
    read opt
    case $opt in
    y|yes)
      $AG install -y $pkg
    esac
    return 0
}

Yum() {
    # install packages for redhat/centos
    return 0
}

Install() {
    local pkg=$1 
    echo $os_type
    if [ $os_type == 'ubuntu' ]; then
        Apt $pkg
    elif [ $os_type == 'redhat' ]; then
        Yum $pkg
    else
        echo 'do not know dirstribution'
    fi

}

while [ $MAX -gt 0 ] 
do
    printf '%*s' $MASK|tr ' ' '*';echo
    echo "* 0. Upgrade system" 
    echo "* 1. Config screen for current user"
    echo "* 2. Config vim for current user"
    echo "* 3. Config ssh for current user"
    echo "* 4. Config tmux for current user"
    echo "* 5. Config zsh for current user"
    echo "* 6. Config dash/bash for current user"
    echo 
    echo "* Q: Quit"
    printf '%*s' $MASK|tr ' ' '*';echo
    
    printf "Choice: "
    read opt

    case $opt in
    0)
      $AG update
      $AG upgrade
    ;;
    1)
      Install 'screen'
      cp conf/dot.screenrc ~/.screenrc
    ;;
    2)
      Install 'vim'
      conf/vim.sh
      cp conf/dot.vimrc ~/.vimrc
    ;;
    3)
      Install 'openssh-client'
      mkdir -p ~/.ssh
      cp conf/ssh_client.conf ~/.ssh/config
    ;;
    4)
      Install "tmux"
      echo >> ~/.profile
      echo "export TERM=xterm-256color" >> ~/.profile
      #echo "export TERM=linux" >> ~/.profile
      echo "alias tmux='tmux -2'" >> ~/.profile
    ;;
    5)
      Install "zsh"
      #*** install on-my-zsh
      printf "Do you want to install oh-my-zsh? (y/No)"
      read opt
      case $opt in
      y|yes)
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
      esac
      #***
      cp conf/zwang*.zsh-theme ~/.oh-my-zsh/themes/
      sed -i "s/^ZSH_THEME=.*/ZSH_THEME=zwang-rkj\n#ZSH_THEME=zwang-ys/" ~/.zshrc
    
      echo >> ~/.zshrc
      echo "# key bindings" >> ~/.zshrc
      echo 'bindkey "\e[1~" beginning-of-line' >> ~/.zshrc
      echo 'bindkey "\e[4~" end-of-line' >> ~/.zshrc
      echo "alis l='ls -lFh'" >> ~/.zshrc
      echo "alias ll='ls -laFh'" >> ~/.zshrc
    ;;
    6)
      echo "alias l='ls -lFh'" >> ~/.profile
      echo "alias ll='ls -laFh'" >> ~/.profile
    ;;        
    Q)
      break
    ;;
    *)
      printf 'The param [%s] is not valid, try again.\n' $opt 
    esac
 
    MAX=`expr $MAX - 1`
done
