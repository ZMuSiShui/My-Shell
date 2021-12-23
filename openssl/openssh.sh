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

version="1.0"
github_branch="main"

function print_msg() {
    if [[ "$1" == "info" ]]; then
        echo -e "${INFO} ${Blue} $2 ${Font}"
    elif [[ "$1" == "warn" ]]; then
        echo -e "${WARN} ${Yellow} $2 ${Font}"
    elif [[ "$1" == "error" ]]; then
        echo -e "${ERROR} ${RedBG} $2 ${Font}"
    else
        echo -e "${ERROR} ${RedBG} 参数错误 ${Font}"
        exit 1
    fi
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

# 安装 OpenSSL
function openssl_install() {
    print_msg "info" "安装 OpenSSL"
    if ! command -v openssl >/dev/null 2>&1; then
        ${INS} openssl
        print_msg "info" "OpenSSL 安装"
    else
        print_msg "warn" "OpenSSL 已存在"
        ${INS} openssl
    fi
}

function main() {
    check_system
    openssl_install
    clear
    echo -e "\t OpenSSL 一键自签证书 ${Green}[${version}]${Font}"
    
    while [[ -z "$domain" ]]; do
        read -rp "*请输入域名/IP(如 *.example.com): " domain
    done
    read -rp "请输入邮箱地址(默认 admin@example.com): " email
    [[ -z "$email" ]] && email=admin@example.com
    read -rp "请输入证书有效期(默认 3650): " day
    [[ -z "$day" ]] && day=3650
    dir=$domain && mkdir -p $dir
    crt_file="$dir/${domain}.crt"
    key_file="$dir/${domain}.key"
    openssl req -x509 -nodes -newkey rsa:2048 -days $day -keyout $key_file -out $crt_file -subj "/C=CN/ST=MyCrt/L=MyCrt/O=MyCrt/OU=MyCrt/CN=${domain}/emailAddress=${email}"
    echo -e "\t证书: $(pwd)/$crt_file\n\t私钥: $(pwd)/$key_file"
}

main