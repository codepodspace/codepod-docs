
## 一键导出业务镜像

```bash
#!/bin/bash

mkdir -p ./images

# 程序名称列表
arr=("server1" "server2")

for i in "${arr[@]}"; do
  echo "$i"
  
  docker pull [仓库地址]/[目录]/$i:test

  docker tag [仓库地址]/[目录]/$i:test my/[目录]/$i:prod

  docker save -o ./images/$i.tar [仓库地址]/[目录]/$i:prod
done

# 其他下载镜像

#示例 download jdk
docker pull openjdk:8u342-jdk
docker save -o ./images/openjdk_8u342.tar openjdk:8u342-jdk


```

## 一键导入镜像

```bash

#!/bin/bash

for f in $(ls -l ./images/*.tar | awk '{print $9}' | grep -E '\w');do docker load -i $f;done

```