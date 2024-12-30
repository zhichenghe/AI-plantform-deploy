#!/bin/bash
set -e #uxo pipefail

export PATH=$PATH:$HOME/.local/bin/
export TOP_PID=$$
trap 'exit 1' TERM

current=$(cd `dirname $0` && pwd)
root=$(dirname $current)
bin=$root/bin
playbooks=$root/playbooks
# project=$root/kubespray-2.14.2 #dev
# project=$root/kubespray-2.13.3  #stg\dev\cicd  # pip uninstall ansible ansible-base ansible-core & cd kubespray-2.13.3 & pip install -r  requirements.txt
# project=$root/kubespray-2.13.1  #prod # pip uninstall ansible & cd kubespray-2.18.1 & pip install -r  requirements.txt
project=$root/kubespray-2.18.1  #stg\dev-operation\prod-data\sinternalgateway

sudo chown -R $USER.$USER /tmp

export ANSIBLE_CONFIG=$root/.ansible.cfg

case $1 in
    scale)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi
        ansible-playbook -i inventory.ini $project/scale.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit="$2" --user=devops -b 
        ;;
    scale-master)
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit=kube_control_plane --user=devops -b
        ;;
    scale-etcd)
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit=etcd,kube_control_plane -e ignore_assert_errors=yes -e etcd_retries=10 --user=devops -b
        ;;
    upgrade-etcd)
        ansible-playbook -i inventory.ini $project/upgrade-cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit=etcd,kube_control_plane -e ignore_assert_errors=yes -e etcd_retries=10 --user=devops -b
        ;;
    # migrate-etcd-docker-to-host)
    #     ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit=etcd -e ignore_assert_errors=yes -e etcd_retries=10 --user=devops -b
    #     ;;    
    migrate-etcd-docker-to-host)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi        
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit=$2 -e ignore_assert_errors=yes -e etcd_retries=10 --user=devops -b
        ;;           
    remove-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi
        ansible-playbook -i inventory.ini $project/remove-node.yml -e node="$2" -e 'ansible_python_interpreter=/usr/bin/python3' -e reset_nodes=false -e allow_ungraceful_removal=true --user=devops -b
        ;;
    delete-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi
        ansible-playbook -i inventory.ini $project/remove-node.yml -e node="$2" -e 'ansible_python_interpreter=/usr/bin/python3' --user=devops -b
        ;;        
    remove-online-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi
        ansible-playbook -i inventory.ini $project/remove-node.yml -e node="$2" -e 'ansible_python_interpreter=/usr/bin/python3' --extra-vars "reset_nodes=false" --user=devops -b
        ;;
    create)
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --user=devops -b
        ;;
    create-cluster)
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e @override_common.yml -e 'ansible_python_interpreter=/usr/bin/python3' --user=devops -b
        ;;   
    scale-desay-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi
        ansible-playbook -i inventory.ini $project/scale.yml -e @override.yml -e @override_desay.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit="$2" --user=devops -b 
        ;;  
    upgrade-desay-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi    
        ansible-playbook -i inventory.ini $project/upgrade-cluster.yml -e @override.yml -e @override_desay.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit "$2" --user=devops -b
        ;;        
    scale-common-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi
        ansible-playbook -i inventory.ini $project/scale.yml -e @override.yml -e @override_common.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit="$2" --user=devops -b 
        ;; 
    upgrade-common-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi    
        ansible-playbook -i inventory.ini $project/upgrade-cluster.yml -e @override.yml -e @override_common.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit "$2" -u devops -b
        ;;                                       
    create-skip-network)
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --skip-tags=network --user=devops -b
        ;;
    upgrade-network)
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --tags=network --user=devops -b
        ;;   
    upgrade-common-master-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi      
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e @override_common.yml -e 'ansible_python_interpreter=/usr/bin/python3' --tags=master --limit "$2" --user=devops -b
        ;; 
    upgrade-master-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi      
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --tags=master --limit "$2" --user=devops -b
        ;;                    
    upgrade-coredns)
        ansible-playbook -i inventory.ini $project/upgrade-cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --tags=coredns --user=devops -b
        ;;              
    upgrade-all)
        ansible-playbook -i inventory.ini $project/upgrade-cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3'  --user=devops -b 
        ;;
    migrate-docker-to-containerd)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi      
        ansible-playbook -i inventory.ini $project/cluster.yml -e @override.yml -e 'ansible_python_interpreter=/usr/bin/python3' --limit="$2"  -u devops -b
        ;;
    upgrade-node)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi    
        ansible-playbook -i inventory.ini $project/upgrade-cluster.yml -e @override.yml --limit "$2" -u devops -b
        ;;        
    reset)
        ansible-playbook -i inventory.ini $project/reset.yml -e 'ansible_python_interpreter=/usr/bin/python3' --user=devops -b
        ;;
    init-desay-machine)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi     
        ansible-playbook -i inventory.ini $playbooks/site-init-desay-orin-system.yml -e 'ansible_python_interpreter=/usr/bin/python3' -e "host=$2" --user=devops -b
        ;;
    init-machine)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi     
        ansible-playbook -i inventory.ini $playbooks/site-init-system.yml -e 'ansible_python_interpreter=/usr/bin/python3' -e "host=$2" --user=devops -b
        ;;      
    set-cpu-performance)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi     
        ansible-playbook -i inventory.ini $playbooks/site-set-cpu-performance.yml -e 'ansible_python_interpreter=/usr/bin/python3' -e "host=$2" --user=devops -b
        ;; 
    init-jetson-machine)
        if [ $# != 3 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi     
        ansible-playbook -i inventory.ini $playbooks/site-init-jetson-orin-system.yml -e 'ansible_python_interpreter=/usr/bin/python3' -e "host=$2" -e "data_block_device=$3" --user=devops -b
        ;;  
    patch-disable-periodic-updates)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi     
        ansible-playbook -i inventory.ini $playbooks/site-patch-disable-periodic-updates.yml -e 'ansible_python_interpreter=/usr/bin/python3' -e "host=$2" --user=devops -b
        ;;  
    init-kube-node)
        if [ $# != 3 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi     
        ansible-playbook -i inventory.ini $playbooks/site-init-kube-node.yml -e 'ansible_python_interpreter=/usr/bin/python3' -e "host=$2" -e "data_block_device=$3" --user=devops -b
        ;;     
    install-docker)
        if [ $# != 2 ]; then
            echo "Missing parameters, exit script run"
            kill -s TERM ${TOP_PID}
        fi     
        ansible-playbook -i inventory.ini $playbooks/site-install-docker.yml -e 'ansible_python_interpreter=/usr/bin/python3' -e "host=$2" --user=devops -b
        ;;                                        
    sync-sshkey)
        if [ $# != 3 ]; then
            echo "Missing parameters, arg1 for inventory host e.g. desay_node, arg2 for default user e.g. deeproute or nvidia"
            kill -s TERM ${TOP_PID}
        fi     
        ansible-playbook -i inventory.ini $playbooks/site-sync-sshkey.yml -e 'ansible_python_interpreter=/usr/bin/python3' -e "host=$2" --user=$3 -b -kK
        ;; 
    gen-tags)
        cd $project
        bash ./scripts/gen_tags.sh  
        ;;     
    *)
        echo "帮助说明: 新方式不同节点组使用独立的配置参数,不区分节点组请使用旧方式管理节点"
        echo "-------------------------------新方式-------------------------------"
        echo "$0 sync-sshkey            [清单节点组 or 节点名称] [原始用户名,e.g. deeproute 或 nvidia]      建立机器与跳板机免密钥通信(必须)"
        echo "$0 init-machine           [清单节点组 or 节点名称]                                          初始化机器,如内核参数、工具(无数据盘的机器使用此方式)(必须)"
        echo "$0 init-kube-node         [清单节点组 or 节点名称] [磁盘,e.g. /dev/sdb]                      初始化机器,格式化数据盘(未被挂载使用)，配置内核参数，安装工具(必须,对非maas安装的机器)"        
        echo "$0 init-desay-machine     [清单节点组 or 节点名称]                                          初始化德赛orin机器(必须)"
        echo "$0 init-jetson-machine    [清单节点组 or 节点名称] [磁盘,e.g. /dev/sdb]                      初始化Jetson orin机器,格式化数据盘(未被挂载使用)(必须)"        
        echo "$0 set-cpu-performance    [清单节点组 or 节点名称]                                          设置cpu主频为性能模式(可选)"
        echo "$0 create-cluster                                                                        创建一个集群,引用override.yml、override_common.yml参数配置"
        echo "$0 scale-common-node      [节点名称]                                              添加一个通用节点到集群"
        echo "$0 scale-desay-node       [节点名称]                                              添加一个德赛orin节点"
        echo "$0 upgrade-common-node    [节点名称]                                              升级一个通用节点"
        echo "$0 upgrade-desay-node     [节点名称]                                              升级一个德赛orin节点"
        echo "$0 upgrade-common-master-node    [节点名称]                                       升级一个通用控制平面节点"
        echo "$0 delete-node            [节点名称]                                              移除一个节点,将彻底删除节点k8s相关容器和服务"
        echo "$0 patch-disable-periodic-updates    [节点名称]                                   关闭apt软件更新补丁"
        echo "-------------------------------旧方式-------------------------------"
        echo "$0 create                                                                        创建一个集群"
        echo "$0 upgrade-node           [节点名称]                                              升级一个节点"
        echo "$0 upgrade-master-node    [节点名称]                                              升级一个控制平面节点"
        echo "$0 scale                  [节点名称]                                              添加一个节点"
        echo "$0 remove-node            [节点名称]                                              移除一个节点（注意: 不会卸载kubeadm,机器重启将自动加入集群）"
        echo "$0 reset                                                                         删除集群(谨慎操作)"

        echo "-------------------------------集群addons管理-------------------------------"
        echo "$0 upgrade-network                                                                更新网络配置(calico、flannel)"
        echo "$0 upgrade-coredns                                                                更新coredns配置"
        echo "$0 install-docker         [清单节点组 or 节点名称]                                   只安装docker服务,使用自带的contiainerd,使节点能同时存在containerd、docker(在节点加入集群后执行)"
        exit 0      
        ;;
esac

