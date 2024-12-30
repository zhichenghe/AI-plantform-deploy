### 主要特点
基于k8s部署开源项目kubespray（https://kubespray.io）改造， 利用本仓库代码可在12分钟内完成一套高可用k8s集群的部署 包括了集群节点一建式扩缩容 集群组件升级等内置脚本， 且在开源项目 kubespray基础上优化调整了各种k8s参数的初始配置：如etcd 独立部署，etcd event事件拆分， api-server同时处理请求参数优化， k8s证书自动更新优化，k8s节点内存软硬驱逐优化设置，k8s节点硬盘软硬驱逐阈值设置更新，k8s节点镜像自动清理相关参数优化等。

---
### 在ansible控制机(跳板机)上安装kubespray依赖

- 安装pip
    ```
    apt install python3-pip -y
    ```
- 安装kubespray-v2.18.1版本依赖
    ```
    pip -r install kubespray-2.18.1/requirements.txt
    ```


---
### k8s集群部署步骤

- 示例集群目录结构
```
projects/test-k8s-cluster
├── inventory.ini   # 集群清单文件
├── override.yml    # 自定义集群参数配置
```
- k8s集群的各种参数优化配置如 etcd 独立部署，etcd event事件拆分， api-server同时处理请求参数优化， k8s证书自动更新优化，k8s节点内存软硬驱逐优化设置，k8s节点硬盘软硬驱逐阈值设置更新，k8s节点镜像自动清理相关参数优化等
都在 override.yml 此文件中统一管理。有关此文件配置参数详细介绍可参考官网文档 (https://kubespray.io/#/docs/ansible/vars)

---
#### 1：创建一个集群项目
- 创建项目
    ```
    cd projects
    cp -r example-k8s-cluster xxx-k8s-cluster
    ```
- 修改集群清单文件和自定义集群参数配置 
    ```
    .
    ├── inventory.ini
    └── override.yml    
    ```

---
#### 2：配置ansible管理机对所有节点免密钥登录 
- 修改`scripts/inventory.ini`
    ```
    cat <<EOF > inventory.ini
    [all]
    59.110.141.31 ansible_ssh_port=22
    182.92.169.15 ansible_ssh_port=22
    EOF  
    ```
- 运行脚本批量为所有新节点建立免密钥登录并创建`devops`管理账号
    ```
    cd scripts/
    ./presys.sh root    # 输入节点的初始root账号密码或者其他初始账号密码
    ```

---
#### 3：提前为所有节点下载k8s统一安装包并解压缓存到节点本地目录/srv/
- 修改`scripts/ip.txt` 更新所有节点的IP地址到ip.txt文件中
    ```
    cat <<EOF > ip.txt
    59.110.141.31
    182.92.169.15
    ```
- 批量为所有节点下载并解压k8s安装包到/srv目录
    ```
    cd scripts/
    sh ip.sh "cd /srv && wget 8.141.22.226:8009/releases.tar.gz && tar -zxvf releases.tar.gz" 
    ```

---
#### 4：通过ansible-playbook脚本批量初始化k8s节点并优化内核配置
- 无数据盘的机器初始化
    ```
    cd project/{集群}
    ../../bin/run.sh init-machine   [清单节点组 or 节点名称] #节点没有数据盘时的初始化命令
    e.g. ../../bin/run.sh init-machine    59-110-141-31.bj.master,182-92-169-15.bj.monito- 运行到镜像下载步骤时 可新开一个窗口执行如下命令批量为所有节点从阿里云镜像仓库拉取镜像加速集群安装
    ```
    cd scripts/
    ./pull_docker.sh
    ```r
    ```

- 针对有额外数据盘的机器初始化
    ```
    cd project/{集群}
    ../bin/run.sh init-kube-node [清单节点组 or 节点名称] [磁盘,e.g. /dev/sdb]  #节点有数据盘且没有格式化时初始化命令 在init-machine基础上增加了磁盘的格式化操作 并把k8s pod数据目录配置到数据盘
    
    e.g. ../../bin/run.sh init-kube-node 10-3-10-35.maas /dev/nvme0n1

    ```

---
#### 5：新建k8s集群
    ```
    cd project/{集群}
    ../../bin/run.sh create
    ```
- 运行到镜像下载步骤时 可新开一个窗口执行如下命令批量为所有节点从阿里云镜像仓库拉取镜像加速集群安装
    ```
    cd scripts/
    ./pull_docker.sh
    ```

---
#### 6：扩容k8s节点
    ```
    cd project/{集群}
    ../../bin/run.sh scale xxxx
    ../../bin/run.sh scale 10-3-8-156.bm.pd.sz.deeproute.ai,10-3-8-157.bm.pd.sz.deeproute.ai  #可一次扩容多台节点
    ```
- 运行到镜像下载步骤时 可新开一个窗口执行如下命令批量为所有节点从阿里云镜像仓库拉取镜像加速集群安装
    ```
    cd scripts/
    ./pull_docker.sh
    ```


---
#### 7：删除k8s节点
    ```
    cd project/{集群}
    ../../bin/run.sh delete-node 10-3-8-29.bm.pd.sz.deeproute.ai  #可一次删除多台节点
    ```

---
#### 8：升级节点网络或者更改节点网络配置
    ```
    cd project/{集群}
    ../../bin/run.sh upgrade-network xxxxxxx
    ```


---
#### 9：其他操作
    ```
    cd project/{集群}
    ../../bin/run.sh scale-master xxxxxxx  #扩容master节点
    ../../bin/run.sh scale-etcd xxxxxxx    #扩容etcd节点
    ../../bin/run.sh upgrade-etcd          #升级etcd节点
    ../../bin/run.sh upgrade-master-node   #升级master节点
    ../../bin/run.sh upgrade-node          #升级worker节点
    ../../bin/run.sh reset                 #销毁集群
    ```