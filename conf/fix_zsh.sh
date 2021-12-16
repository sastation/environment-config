#!/bin/bash

cp zwang*theme ~/.oh-my-zsh/themes/

# for disable warning on ~root/.zshrc
sudo chown -R root:root ~/.oh-my-zsh
sudo chown -R zwang:zwang ~/.oh-my-zsh/themes

# zshrc & bashrc
ztheme="alias ztheme='(){ export ZSH_THEME="$@" && source $ZSH/oh-my-zsh.sh }'" 
echo $ztheme >> ~/.zshrc

cp bash.rc ~/.sh_profile
echo "source ~zwang/.sh_profile" >> ~/.bashrc
echo "source ~zwang/.sh_profile" >> ~/.zshrc

sed -i "/^ZSH_THEME=zwang-ys/i\#ZSH_THEME=zwang-dpoggi" ~/.zshrc
