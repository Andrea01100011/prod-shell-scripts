#!/bin/bash
# jenkins自动化部署脚本
# 1. 告知目标服务器拉取镜像
# 2. 判断当前目标服务器是否正在运行容器，需要删除
# 3. 判断当前目标服务器是否存在镜像，需要删除
# 4. 目标服务器拉取harbor镜像
# 5. 将拉取的镜像运行成容器
# 镜像地址格式：harbor地址/harbor仓库/镜像名:镜像版本 端口号
harbor_addr=$1
harbor_repo=$2
project=$3
version=$4
host_port=$5
container_port=$6

imageName=$harbor_addr/$harbor_repo/$project:$version
echo $imageName

containerId=$(docker ps -a | grep ${project} | awk '{print $1}')
echo $containerId

if [ "$containerId" != "" ]; then
    docker stop $containerId
    docker rm $containerId
fi

tag=$(docker images | grep ${project} | awk '{print $2}')
echo $tag

if [[ "$tag" =~ "$version" ]]; then
    docker rmi $imageName
fi

docker login -u admin -p Harbor12345 $harbor_addr
docker pull $imageName
docker run -d -p $host_port:$container_port --name $project $imageName

echo "SUCCESS"