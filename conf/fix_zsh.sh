#!/bin/bash

cp zwang*theme ~/.oh-my-zsh/themes/

# for disable warning on ~root/.zshrc
sudo chown -R root:root ~/.oh-my-zsh
sudo chown -R zwang:zwang ~/.oh-my-zsh/themes

# zshrc & bashrc
echo "alias ztheme='(){ export ZSH_THEME="$@" && source $ZSH/oh-my-zsh.sh }'" >> ~/.zshrc
echo "alias zunproxy='unset http_proxy; unset https_proxy; unset HTTP_PROXY; unset HTTPS_PROXY'" >> ~/.profile
echo "alias zproxy='zset(){ export http_proxy=$1; export https_proxy=$1; export HTTP_PROXY=$1; export HTTPS_PROXY=$1}; zset'" >> ~/.profile
