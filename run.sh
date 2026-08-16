#!/bin/bash

# 防止未定义变量（代码 bug 直接报错退出）；pipefail 让管道失败可被感知
# 不开 -e：交互菜单下普通出错只提示、不中断
set -uo pipefail

AG='sudo apt-get '
MAX=30
MASK=60

os_type='None'

OS() {
    # Debian/Ubuntu 系判定：os-release 的 ID 或 ID_LIKE 含 debian/ubuntu，或存在 debian_version
    if [ -r /etc/os-release ]; then
        . /etc/os-release
        case "${ID:-}:${ID_LIKE:-}" in
            *debian*|*ubuntu*) os_type='debian' ;;
            *) os_type='unknow' ;;
        esac
    elif [ -e /etc/debian_version ]; then
        os_type='debian'
    else
        os_type='unknow'
    fi
}
OS #get operation distribution
if [ "$os_type" != "debian" ]; then
    echo "Only for Debian/Ubuntu family!"
    echo "Your OS: "$os_type
    exit 1
fi

# 运行前提示：面向新用户，仅作提醒，按任意键继续（Ctrl+C 可中断）
echo
printf '%*s' $MASK|tr ' ' '*';echo
echo "Note: this script is for initializing a newly created user environment."
echo "It will overwrite current user's ~/.vimrc, ~/.screenrc, ~/.ssh/config, ~/.sh_profile, etc,"
echo "and modify ~/.zshrc, ~/.bashrc, ~/.tmux.conf. Please back up existing customized configs first."
printf '%*s' $MASK|tr ' ' '*';echo
read -p "Press any key to continue (Ctrl+C to abort) ..."
printf "\n\n"

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

Install() {
    local pkg=$1 
    if [ $os_type == 'debian' ]; then
        Apt $pkg
    else
        echo 'do not know dirstribution'
    fi

}

Append_once() {
    # 幂等追加：目标文件里已有该行则跳过，防止重复执行堆积
    # 用法: Append_once "内容" "目标文件"
    local line=$1
    local file=$2
    if ! grep -qF -- "$line" "$file" 2>/dev/null; then
        echo "$line" >> "$file"
    fi
}

opt_zsh() {
    # 选项 5：配置 zsh（含可选的 oh-my-zsh）
    Install "zsh"
    #*** install on-my-zsh
    printf "Do you want to install oh-my-zsh? (y/No)"
    read opt
    opt=${opt:-no}
    ozh="no"
    case $opt in
    y|yes)
      ozh="yes"
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    esac

    # 纯 zsh 配置，不依赖 oh-my-zsh，始终执行
    if ! grep -qF "# zwang defined" ~/.zshrc 2>/dev/null; then
      cat conf/zsh.rc >> ~/.zshrc
    fi
    cp conf/sh_profile ~/.sh_profile
    Append_once "source ~${USER}/.sh_profile" ~/.zshrc

    # 以下步骤依赖 oh-my-zsh，未安装时跳过
    if [ "$ozh" = "yes" ]; then
      cp conf/zwang*.zsh-theme ~/.oh-my-zsh/themes/
      str="ZSH_THEME=zwang-ys\n"
      str=$str"#ZSH_THEME=zwang-rkj\n"
      str=$str"#ZSH_THEME=zwang-skwp\n"
      str=$str"#ZSH_THEME=zwang-michele\n"
      str=$str"#ZSH_THEME=zwang-dpoggi\n"
      sed -i "s/^ZSH_THEME=.*/$str/" ~/.zshrc
      sed -i '/^source \$ZSH\/oh-my-zsh.sh/i\DISABLE_AUTO_UPDATE="true"' ~/.zshrc

      # 自动建议插件
      git clone https://github.com/zsh-users/zsh-autosuggestions ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
      # 语法高亮插件
      git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
      # 开启所需插件
      if grep -q '^plugins=(' ~/.zshrc; then
        sed -i '/^plugins=(/,/^)/c\
plugins=(\
  git\
  colored-man-pages\
  history-substring-search\
  zsh-autosuggestions\
  zsh-syntax-highlighting\
)' ~/.zshrc
      else
        echo "Warning: 'plugins=(...)' not found in ~/.zshrc, please enable plugins manually"
      fi

      # disable warning for ~root/.zshrc
      printf "Set ~/.oh-my-zsh ownership (root:root + user)? (y/No)? "
      read opt
      case $opt in
      y|yes)
        sudo chown -R root:root ~/.oh-my-zsh
        sudo chown -R $(id -un):$(id -gn) ~/.oh-my-zsh/themes
      esac
    else
      echo "oh-my-zsh not installed, skip themes/plugins/permissions setup"
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
    opt=${opt:-Q}

    case $opt in
    0)
      printf "Do you want to run 'apt-get update && upgrade'? (y/No)? "
      read opt
      case $opt in
      y|yes)
        $AG update
        $AG upgrade
      esac
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

      Append_once "set -g default-shell /bin/zsh" ~/.tmux.conf
      Append_once "set -g default-command /bin/zsh" ~/.tmux.conf
      #echo "alias tmux='tmux -2'" >> ~/.profile
    ;;
    5)
      opt_zsh
    ;;
    6)
      #echo "alias l='ls -lFh'" >> ~/.profile
      cp conf/sh_profile ~/.sh_profile
      Append_once "source ~${USER}/.sh_profile" ~/.bashrc
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
