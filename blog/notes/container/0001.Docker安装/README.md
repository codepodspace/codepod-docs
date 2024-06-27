
## 安装脚本

docker安装部署，参考[Install Docker Engine on CentOS | Docker Docs](https://docs.docker.com/engine/install/centos/)

CentOS 手动安装执行：

```sh

#设置下载库的地址
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo

#获取版本列表
yum list docker-ce --showduplicates | sort -r

#选择需要的版本进行安装
sudo yum install docker-ce docker-ce-cli containerd.io docker-compose-plugin

#启动docker
systemctl start docker

#设置docker的镜像地址，创建或修改/etc/docker/daemon.json文件
{
  "registry-mirrors": [
    "https://atomhub.openatom.cn"
  ]
}

#刷新变更，重启docker
sudo systemctl daemon-reload
sudo systemctl restart docker

#设置自动重启
sudo systemctl enable docker

#禁用自动重启
sudo systemctl disable docker

#卸载docker
sudo yum remove docker-ce
sudo rm -rf /var/lib/docker

```


## Docker、DockerCompose常用命令

> 启动服务

```sh
docker compose up -d
```

> 查看服务运行状态

```sh
docker ps
```

> 查看服务运行日志

```sh
docker logs --tail=1000 -f 【容器ID】
```

或者

```sh
docker compose logs【服务名】 -f
```

> 重启全部服务

```sh
docker compose restart
```

> 重启某个服务

```sh
docker compose restart 【服务名】
```

> 修改 docker-compose.yaml，重新执行可生效

```sh
docker compose up -d
```

> 服务卸载

```sh
docker compose down
```

## 其他命令笔记

> Docker构建

```sh
docker build --rm -f ./Dockerfile -t 【镜像名称】:【ver】 ./
```

> 提交容器
```sh
docker commit -a "" -m "" 【容器ID】 【镜像名称】:【ver】
```

> Tag

```sh
docker tag 【容器ID】 【镜像名称】:【version】

#或

docker tag 【【镜像名称1】:【ver1】 【镜像名称2】:【ver2】
```

> 保存容器到本地

```sh
docker save -o 【文件名称】【镜像名称】:【ver】
```

> 加载镜像文件

```sh
docker load -i 【文件名称】
```