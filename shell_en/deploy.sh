#!/bin/bash
# jenkins automation depoly shell script
# 1. notice target server to pull image from Harbor
# 2. if the container is running on target server, it needs to be kill and delete
# 3. if the image exsits on target server, it needs to be delete
# 4. target server pulls image
# 5. container running
# Harbor address：HarborIpAddr/harborRepoName/image:tag(version) port
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