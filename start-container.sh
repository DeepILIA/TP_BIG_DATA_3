#!/bin/bash
docker network rm hadoop1
docker network create --driver=bridge hadoop1

# the default node number is 3
N=${1:-3}

xhost +
# start hadoop master container
docker rm -f hadoop-master &> /dev/null
echo "start hadoop-master container..."
docker run -itd \
                --net=hadoop1 \
                -p 50070:50070 \
                -p 8088:8088 \
		-p 7077:7077 \
		-p 16010:16010 \
		-e DISPLAY=$DISPLAY \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
                --name hadoop-master \
                --hostname hadoop-master \
                amine2733/spark-hadoop &> /dev/null


# start hadoop slave container
i=1
while [ $i -lt $N ]
do
	docker rm -f hadoop-slave$i &> /dev/null
	echo "start hadoop-slave$i container..."
	port=$(( 8040 + $i ))
	docker run -itd \
			-p $port:8042 \
	                --net=hadoop1 \
	                --name hadoop-slave$i \
	                --hostname hadoop-slave$i \
	                amine2733/spark-hadoop  &> /dev/null
	i=$(( $i + 1 ))
done 

# get into hadoop master container

docker  exec -it hadoop-master bash
