## Update ##
升级 SmokePing 版本为 2.8.2

## 功能 ##
- 一键启动、停止、重启SmokePing服务
- 一键安装、卸载SmokePing三种版本
- 一键安装Tcpping (Smokeping专用版本)
- 一键配置访问密码
- 安装supervisor以守护fcgi进程
- 自动更换至GMT+8时区并对时
- 自动更换Linux软件源(可选)
- 支持中文显示
- 覆盖安装提醒
## 安装/卸载 ##
    wget -N --no-check-certificate https://raw.githubusercontent.com/ZMuSiShui/My-Shell/main/smokeping/smokeping.sh && bash smokeping.sh
## 程序安装目录 ##
- Nginx配置：/etc/nginx/ /etc/nginx/conf/
- smokeping安装目录：/opt/smokeping/
- smokeping配置文件：/opt/smokeping/etc/config
- fcgi文件：/opt/smokeping/htdocs/smokeping.fcgi
