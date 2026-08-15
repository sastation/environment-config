# 环境初始化脚本

Debian/Ubuntu 系 Linux 新用户环境初始化脚本，通过交互式菜单逐项配置当前用户环境。

## 用户需求

### 1. 平台限定

- 需求：脚本仅适用于 Debian/Ubuntu 系（apt 系）系统，其他发行版不应运行。
- 实现：通过 `/etc/os-release` 的 `ID`/`ID_LIKE` 判定（兼容 Linux Mint 等衍生版），不符合则提示并退出。

### 2. 运行前保护

- 需求：脚本面向**新创建的用户**，运行会覆盖/修改已有配置；运行前需向用户确认，防止误跑在有自订配置的账号上。
- 实现：打印即将覆盖的配置清单（~/.vimrc、~/.screenrc、~/.ssh/config、~/.sh_profile、~/.zshrc、~/.bashrc、~/.tmux.conf），默认 No（回车取消）。

### 3. 交互式菜单

- 需求：按需选择要配置的项目，支持多次选择，随时退出。
- 实现：循环菜单（0-6 + Q），回车默认退出（Q）；无效输入提示重选。

### 4. 各选项满足的需求

#### 0. 系统升级
- 需求：将当前已安装软件包更新到最新版本。
- 实现：`apt-get update` + `apt-get upgrade`（保持"更新当前版本"语义，不做 dist-upgrade）。

#### 1. 配置 screen
- 需求：为当前用户启用 GNU screen 终端复用，并套用个人化的状态栏/滚动/颜色配置。
- 实现：安装 screen，拷贝 `conf/dot.screenrc` 到 `~/.screenrc`。

#### 2. 配置 vim
- 需求：搭建个人化的 Vim 编辑环境（配色、缩进、折叠、插件：pathogen、nerdtree、tagbar、snipmate、jedi-vim 等）。
- 实现：安装 vim，运行 `conf/vim.sh`（可选"在线安装"或"从本地 tar 拷贝"插件），拷贝 `conf/dot.vimrc` 到 `~/.vimrc`。

#### 3. 配置 ssh
- 需求：为当前用户生成一套可直接使用的 SSH 客户端配置（连接保活、关闭主机指纹校检、默认端口，针对 LANG sendenv 等）。
- 实现：安装 openssh-client，建 `~/.ssh`，拷贝 `conf/ssh_client.conf` 到 `~/.ssh/config`。

#### 4. 配置 tmux
- 需求：安装 tmux 并使 tmux 默认使用 zsh 作为 shell（与用户 zsh 环境一致）。
- 实现：安装 tmux，幂等写入默认 shell/command 到 `~/.tmux.conf`。

#### 5. 配置 zsh
- 需求：
  - 当前用户默认以 zsh 为主要 shell；
  - 可选安装 oh-my-zsh 框架及自定义主题（zwang-ys 等）、语法高亮插件；
  - 无论是否安装 oh-my-zsh，都注入统一的命令别名与自定义函数（见 conf/sh_profile）。
- 实现：安装 zsh；询问是否装 oh-my-zsh（默认不装）；未安装时跳过依赖 oh-my-zsh 的主题/插件/权限步骤；安装了才配置主题、插件、目录属主（root 借用时不报 compinit 警告）。

#### 6. 配置 dash/bash
- 需求：为当前用户启用与 zsh 一致的别名/函数环境（.sh_profile），用于 bash 环境下复用。
- 实现：拷贝 `conf/sh_profile` 到 `~/.sh_profile`，并在 `~/.bashrc` 中幂等追加 source。

### 5. 命令别名与函数（conf/sh_profile）

- 需求：一套高频维护命令的快捷别名/函数，供 zsh 与 bash 共用：

| 名称 | 用途 |
|---|---|
| `ll` / `l` | 列表查看（带格式/权限/大小） |
| `zping` / `zhping` | 快速 ping / hping3 探测 |
| `zmore` | 大行数分页查看 |
| `zcurl` | 只看下载速度的 curl |
| `zmtr` | 单次 mtr 路由追踪 |
| `zdu` | 磁盘占用排序统计 |
| `zds` | docker ps 简洁格式化输出 |
| `zunproxy` | 清除代理环境变量 |
| `zproxy` | 查看/设置/清除代理（status/off/地址） |
| `zspeed` | 测试某主机下载速度 |
| `ztheme` | 运行时切换 zsh 主题 |

### 6. 跨用户借用配置

- 需求：系统维护时可能进入 root 或其他用户环境，期望借用户账号的配置而不换环境重跑脚本；且 source 写明确指向当前账号路径。
- 实现：`~/.zshrc`/`~/.bashrc` 中的 source 写成 `~${USER}/.sh_profile`（不依赖 HOME），任何用户执行都指向该账号自身路径。

## 非需求（明确不做的）

- 不做红帽系（redhat/centos/yum）支持。
- 不做无人值守/批量（设计为交互式操作）。
- 不处理代理配置（使用时手动 zproxy）。
- 不做 dist-upgrade（只更新当前版本包）。
- 不做配置文件备份（面向新用户，仅运行前确认提示）。

## 设计决策备忘（有意为之，修改前请先确认意图）

- **`~/.zshrc`/`~/.bashrc` 中 source 写成 `~${USER}/.sh_profile`**：不依赖 `$HOME`，任何用户（含 root）执行时都明确指向该账号自身路径，便于维护时借用当前账号配置。**勿改为 `~/.sh_profile`**。
- **安装 oh-my-zsh 后 chown：外层 `root:root`、内层（themes/custom）归当前用户**：`root:root` 是为了 root 借用 zsh 时避免 compinit 属主引用警告，themes/custom 归当前用户才能正常装插件、写自定义配置。此组合是验证过的设计，勿拆散。chown 用户名用 `$(id -un):$(id -gn)` 动态获取，勿写死具体用户名。
- **oh-my-zsh 下载地址用 `ohmyzsh/ohmyzsh`**（分支 `master`）：仓库名已从 `robbyrussell/oh-my-zsh` 迁移，旧地址仅靠 GitHub 重定向存活。
- **jedi 不通过 `sudo pip install` 安装**：由 jedi-vim 的 git submodule（`git submodule update --init`）自带，避免污染系统 Python。
- **zmore 用 `more -1000`**：`-number` 等价 `--lines`（每屏行数），但 more 内部上限 32767，之前 `-100000` 会报 `out of range`。
- **幂等追加用 `Append_once`**：所有 `echo >>` 追加均需查重（grep -qF），防止重复执行堆积重复配置。
- **未定义变量即报错、但不全局 `set -e`**：`set -uo pipefail` —— 交互菜单下普通出错只提示、不中断流程。
- **仅判定 Debian/Ubuntu 系（apt 系）**，不再精确区分 ubuntu/debian，也不支持 redhat（相关 Yum 代码已移除）。