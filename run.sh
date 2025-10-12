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

      echo "set -g default-shell /bin/zsh" >> ~/.tmux.conf
      echo "set -g default-command /bin/zsh" >> ~/.tmux.conf
      #echo "alias tmux='tmux -2'" >> ~/.profile
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
      str="ZSH_THEME=zwang-ys\n"
      str=$str"#ZSH_THEME=zwang-rkj\n"
      str=$str"#ZSH_THEME=zwang-skwp\n"
      str=$str"#ZSH_THEME=zwang-michele\n"
      str=$str"#ZSH_THEME=zwang-dpoggi\n"
      sed -i "s/^ZSH_THEME=.*/$str/" ~/.zshrc
      sed -i '/^source \$ZSH\/oh-my-zsh.sh/i\DISABLE_AUTO_UPDATE="true"' ~/.zshrc

      cat conf/zsh.rc >> ~/.zshrc
      cp conf/sh_profile ~/.sh_profile
      echo "source ~${USER}/.sh_profile" >> ~/.zshrc

      # for disable warning on ~root/.zshrc
      sudo chown -R root:root ~/.oh-my-zsh
      sudo chown -R zwang:zwang ~/.oh-my-zsh/themes
    ;;
    6)
      #echo "alias l='ls -lFh'" >> ~/.profile
      cp conf/sh_profile ~/.sh_profile
      echo "source ~${USER}/.sh_profile" >> ~/.bashrc
    ;;        
    Q)
      break
    ;;
    *)
      printf 'The param [%s] is not valid, try again.\n' $opt 
    esac
 
    MAX=`expr $MAX - 1`
done

exit 0
