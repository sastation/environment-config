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
    echo "* a. Config screen for current user"
    echo "* b. Config vim for current user"
    echo "* c. Config ssh for current user"
    echo 
    echo "* 0. Upgrade system" 
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
      Install 'screen'
      cp conf/dot.screenrc ~/.screenrc
    ;;
    b)
      Install 'vim'
      cp conf/dot.vimrc ~/.vimrc
    ;;
    c)
      Install 'openssh-client'
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
