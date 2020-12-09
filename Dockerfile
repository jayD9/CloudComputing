#FROM ubuntu:latest
#RUN apt-get update && apt-get install -y \
#        software-properties-common
#RUN add-apt-repository ppa:deadsnakes/ppa
#RUN apt-get update && apt-get install -y \
	#python3.7 \
	#python3-pip
#RUN python3.7 -m pip install pip
#RUN apt-get update && apt-get install -y \
	#python3-distutils \
	#python3-setuptools
	
	
#RUN #apt-get update && apt-get install -y python3.7 curl python3-distutils python3-setuptools python3-numpy #&& curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py && python3.7 get-pip.py

#ARG ubuntu_version=18.04
#FROM ubuntu:${ubuntu_version}
#Use ubuntu 18:04 as your base image
FROM ubuntu:18.04
#Any label to recognise this image.
LABEL image=Spark-base-image
ENV SPARK_VERSION=2.4.1
ENV HADOOP_VERSION=2.7


#Run the following commands on my Linux machine
#install the below packages on the ubuntu image
RUN apt-get update -qq && \
    apt-get install -qq -y gnupg2 wget openjdk-8-jdk scala
#Download the Spark binaries from the repo
WORKDIR /
COPY ./downloads/*  /

RUN wget --no-verbose https://downloads.apache.org/spark/spark-3.0.1/spark-3.0.1-bin-hadoop2.7.tgz #https://archive.apache.org/dist/spark/spark-2.4.3/spark-2.4.5-bin-hadoop2.7.tgz

# Untar the downloaded binaries , move them the folder name spark and add the spark bin on my class path
RUN tar xvf spark-3.0.1-bin-hadoop2.7.tgz && \
    mv spark-3.0.1-bin-hadoop2.7 /opt/spark && \
    echo "export PATH=$PATH:/spark/bin" >> ~/.bashrc
RUN wget -O get-pip.py https://bootstrap.pypa.io/get-pip.py 
RUN apt-get install -y python3.7 python3-distutils && \
	echo "export PATH=$PATH:/usr/bin/python3.7" >>~/.bashrc
RUN python3.7 get-pip.py && \
	echo "export PATH=$PATH:/usr/local/bin/pip3" >> ~/.bashrc
RUN pip3 install pyspark findspark
RUN ls -l /spark/sbin/
ENV SPARK_HOME=/spark
ENV PYSPARK_PYTHON=/usr/bin/python3
RUN apt-get install -y python3-numpy

#RUN ./spark/sbin/start-master.sh 

RUN spark-submit test.py
