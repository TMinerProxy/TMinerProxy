#!/bin/bash
[[ $(id -u) != 0 ]] && echo -e "请在Root用户下运行安装该脚本" && exit 1

cmd="apt-get"
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
    if [[ $(command -v yum) ]]; then
        cmd="yum"
    fi
else
    echo "这个安装脚本不支持您的系统" && exit 1
fi


install(){    
    if [ -d "/root/t_miner_proxy" ]; then
        echo -e "检测到您已安装TMinerProxy，请勿重复安装，如您确认您未安装请使用rm -rf /root/t_miner_proxy指令" && exit 1
    fi
    if screen -list | grep -q "t_miner_proxy"; then
        echo -e "检测到您的TMinerProxy已启动，请勿重复安装" && exit 1
    fi

    $cmd update -y
    $cmd install wget screen -y
    
    mkdir /root/t_miner_proxy
    wget https://raw.githubusercontent.com/TMinerProxy/TMinerProxy/main/scripts/run.sh -O /root/t_miner_proxy/run.sh
    chmod 777 /root/t_miner_proxy/run.sh
    wget https://raw.githubusercontent.com/TMinerProxy/TMinerProxy/main/others/server.key -O /root/t_miner_proxy/server.key
    wget https://raw.githubusercontent.com/TMinerProxy/TMinerProxy/main/others/server.pem -O /root/t_miner_proxy/server.pem
    
    wget https://github.com/TMinerProxy/TMinerProxy/releases/download/1.2.0/TMinerProxy_v1.2.0_linux_amd64.tar.gz -O /root/TMinerProxy_v1.2.0_linux_amd64.tar.gz
    tar -zxvf /root/TMinerProxy_v1.2.0_linux_amd64.tar.gz -C /root/t_miner_proxy
    chmod 777 /root/t_miner_proxy/TMinerProxy

    screen -dmS t_miner_proxy
    sleep 0.2s
    screen -r t_miner_proxy -p 0 -X stuff "cd /root/t_miner_proxy"
    screen -r t_miner_proxy -p 0 -X stuff $'\n'
    screen -r t_miner_proxy -p 0 -X stuff "./run.sh"
    screen -r t_miner_proxy -p 0 -X stuff $'\n'

    sleep 2s
    echo "TMinerProxy V1.2.0已经安装到/root/t_miner_proxy"
    cat /root/t_miner_proxy/pwd.txt
    echo ""
    echo "您可以使用指令screen -r t_miner_proxy查看程式端口和密码"
}


uninstall(){
    read -p "您确认您是否删除TMinerProxy)[yes/no]：" flag
    if [ -z $flag ];then
         echo "您未正确输入" && exit 1
    else
        if [ "$flag" = "yes" -o "$flag" = "ye" -o "$flag" = "y" ];then
            screen -X -S t_miner_proxy quit
            rm -rf /root/t_miner_proxy
            echo "TMinerProxy已成功从您的服务器上卸载"
        fi
    fi
}


update(){
    wget https://github.com/TMinerProxy/TMinerProxy/releases/download/1.2.0/TMinerProxy_v1.2.0_linux_amd64.tar.gz -O /root/TMinerProxy_v1.2.0_linux_amd64.tar.gz

    if screen -list | grep -q "t_miner_proxy"; then
        screen -X -S t_miner_proxy quit
    fi
    rm -rf /root/t_miner_proxy/TMinerProxy

    tar -zxvf /root/TMinerProxy_v1.2.0_linux_amd64.tar.gz -C /root/t_miner_proxy
    chmod 777 /root/t_miner_proxy/TMinerProxy

    screen -dmS t_miner_proxy
    sleep 0.2s
    screen -r t_miner_proxy -p 0 -X stuff "cd /root/t_miner_proxy"
    screen -r t_miner_proxy -p 0 -X stuff $'\n'
    screen -r t_miner_proxy -p 0 -X stuff "./run.sh"
    screen -r t_miner_proxy -p 0 -X stuff $'\n'

    sleep 2s
    echo "TMinerProxy 已经更新至V1.2.0版本并启动"
    cat /root/t_miner_proxy/pwd.txt
    echo ""
    echo "您可以使用指令screen -r t_miner_proxy查看程式输出"
}


start(){
    if screen -list | grep -q "t_miner_proxy"; then
        echo -e "检测到您的TMinerProxy已启动，请勿重复启动" && exit 1
    fi
    
    screen -dmS t_miner_proxy
    sleep 0.2s
    screen -r t_miner_proxy -p 0 -X stuff "cd /root/t_miner_proxy"
    screen -r t_miner_proxy -p 0 -X stuff $'\n'
    screen -r t_miner_proxy -p 0 -X stuff "./run.sh"
    screen -r t_miner_proxy -p 0 -X stuff $'\n'
    
    echo "TMinerProxy已启动"
    echo "您可以使用指令screen -r t_miner_proxy查看程式输出"
}


restart(){
    if screen -list | grep -q "t_miner_proxy"; then
        screen -X -S t_miner_proxy quit
    fi
    
    screen -dmS t_miner_proxy
    sleep 0.2s
    screen -r t_miner_proxy -p 0 -X stuff "cd /root/t_miner_proxy"
    screen -r t_miner_proxy -p 0 -X stuff $'\n'
    screen -r t_miner_proxy -p 0 -X stuff "./run.sh"
    screen -r t_miner_proxy -p 0 -X stuff $'\n'

    echo "TMinerProxy 已经重新启动"
    echo "您可以使用指令screen -r t_miner_proxy查看程式输出"
}


stop(){
    screen -X -S t_miner_proxy quit
    echo "TMinerProxy 已停止"
}


change_limit(){
    change_flag="n"
    if [ $(grep -c "root soft nofile" /etc/security/limits.conf) -eq '0' ]; then
        echo "root soft nofile 100000" >>/etc/security/limits.conf
        change_flag="y"
    fi

    if [[ "$change_flag" = "y" ]]; then
        echo "系统连接数限制已修改，手动重启下系统即可生效"
    else
        echo -n "您的系统连接数限制可能已修改，当前连接限制："
        ulimit -n
    fi
}


check_limit(){
    echo -n "您的系统当前连接限制："
    ulimit -n
}


echo "======================================================="
echo "TMinerProxy 一键脚本，脚本默认安装到/root/t_miner_proxy"
echo "                                   脚本版本：V1.2.0"
echo "  1、安  装"
echo "  2、卸  载"
echo "  3、更  新"
echo "  4、启  动"
echo "  5、重  启"
echo "  6、停  止"
echo "  7、一键解除Linux连接数限制(需手动重启系统生效)"
echo "  8、查看当前系统连接数限制"
echo "======================================================="
read -p "$(echo -e "请选择[1-8]：")" choose
case $choose in
    1)
        install
        ;;
    2)
        uninstall
        ;;
    3)
        update
        ;;
    4)
        start
        ;;
    5)
        restart
        ;;
    6)
        stop
        ;;
    7)
        change_limit
        ;;
    8)
        check_limit
        ;;
    *)
        echo "请输入正确的数字！"
        ;;
esac