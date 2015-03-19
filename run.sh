#!/bin/bash

AG='sudo apt-get '
MAX=30
MASK=50

Apt(){
    pkg=$1
    printf "Do you want to install %s? (y/No)? " $pkg
    read opt
    case $opt in
    y|yes)
      $AG install -y $pkg
    esac
    return 0
}

while [ $MAX -gt 0 ] 
do
    printf '%*s' $MASK|tr ' ' '*';echo
    echo "* a. Config screen for current user"
    echo "* b. Config vim for current user"
    echo "* c. Config ssh for current user"
    echo 
    echo "* 0. apt-get update for system" 
    echo "* 1. Config sshd for system"
    echo "* 2. Config stunnel for system"
    echo "* 3. Config squid for system"
    echo "* 4. Config bind for system"
    echo 
    echo "* Q: Quit"
    printf '%*s' $MASK|tr ' ' '*';echo
    
    printf "Choice: "
    read opt

    case $opt in
    0)
      $AG update
    ;;
    a)
      Apt 'screen'
      cp conf/dot.screenrc ~/.screenrc
    ;;
    b)
      Apt 'vim'
      cp conf/dot.vimrc ~/.vimrc
    ;;
    c)
      Apt 'openssh-client'
      mkdir -p ~/.ssh
      cp conf/ssh_client.conf ~/.ssh/config
    ;;
    Q)
      break
    ;;
    *)
      printf 'The param [%s] is not valid, try again.\n' $opt 
    esac
 
    MAX=`expr $MAX - 1`
done
