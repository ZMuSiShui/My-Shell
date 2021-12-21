#!/bin/bash
###
# @Author: MuSiShui
# @Date: 2021-11-22 19:34:07
 # @LastEditTime: 2021-11-24 20:29:45
 # @LastEditors: Please set LastEditors
###
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

cd "$(
    cd "$(dirname "$0")" || exit
    pwd
)" || exit

# 字体颜色/背景
Green="\033[32m"
Red="\033[31m"
Yellow="\033[33m"
GreenBG="\033[42;37m"
RedBG="\033[41;37m"
Font="\033[0m"

# 通知消息颜色
INFO="${Green}[INFO]${Font}"
WARN="${Yellow}[WARN]${Font}"
ERROR="${Red}[ERROR]${Font}"

version="0.1"
github_branch="main"

function print_info() {
    echo -e "${INFO} ${Blue} $1 ${Font}"
}

function print_warn() {
    echo -e "${WARN} ${Yellow} $1 ${Font}"
}

function print_error() {
    echo -e "${ERROR} ${RedBG} $1 ${Font}"
}

function check_user() {
    if [[ "$EUID" -ne 0 ]]; then
        print_error "当前用户不是 root 用户，请切换到 root 用户后重新执行脚本"
        exit 1
    fi
}

function check_system() {
    source '/etc/os-release'

    if [[ "${ID}" == "centos" && ${VERSION_ID} -ge 7 ]]; then
        print_ok "当前系统为 Centos ${VERSION_ID} ${VERSION}"
        INS="yum install -y"
        wget -N -P /etc/yum.repos.d/ https://raw.githubusercontent.com/ZMuSiShui/My-Shell/${github_branch}/base/nginx.repo

    elif [[ "${ID}" == "ol" ]]; then
        print_ok "当前系统为 Oracle Linux ${VERSION_ID} ${VERSION}"
        INS="yum install -y"
        wget -N -P /etc/yum.repos.d/ https://raw.githubusercontent.com/ZMuSiShui/My-Shell/${github_branch}/base/nginx.repo

    elif [[ "${ID}" == "debian" && ${VERSION_ID} -ge 9 ]]; then
        print_ok "当前系统为 Debian ${VERSION_ID} ${VERSION}"
        INS="apt install -y"
        # 清除可能的遗留问题
        rm -f /etc/apt/sources.list.d/nginx.list
        $INS lsb-release gnupg2

        echo "deb http://nginx.org/packages/debian $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
        curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -

        apt update

    elif [[ "${ID}" == "ubuntu" && $(echo "${VERSION_ID}" | cut -d '.' -f1) -ge 18 ]]; then
        print_ok "当前系统为 Ubuntu ${VERSION_ID} ${UBUNTU_CODENAME}"
        INS="apt install -y"
        # 清除可能的遗留问题
        rm -f /etc/apt/sources.list.d/nginx.list
        $INS lsb-release gnupg2

        echo "deb http://nginx.org/packages/ubuntu $(lsb_release -cs) nginx" >/etc/apt/sources.list.d/nginx.list
        curl -fsSL https://nginx.org/keys/nginx_signing.key | apt-key add -
        apt update

    else
        print_error "当前系统为 ${ID} ${VERSION_ID} 不在支持的系统列表内"
        exit 1
    fi

    if [[ $(grep "nogroup" /etc/group) ]]; then
        cert_group="nogroup"
    fi
}
