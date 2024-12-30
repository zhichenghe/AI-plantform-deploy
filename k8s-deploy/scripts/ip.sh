#!/bin/bash
for _ip in `cat ip.txt`
do
        echo ${_ip}"执行命令结果" $1
        ssh devops@${_ip} "$1"
        echo -e "\n"
done
