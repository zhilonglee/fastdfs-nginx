FROM centos:7

LABEL maintainer "zhilong.li1995@gmail.com"


ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
    NGINX_VERSION="1.14.0" \
    PORT= \
    GROUP_NAME= \
    TRACKER_SERVER=

RUN echo "nameserver 8.8.8.8" >> /etc/resolv.conf

#RUN yum -y update

#get all the dependences and nginx
RUN yum install -y git gcc make wget pcre pcre-devel openssl openssl-devel \
  && rm -rf /var/cache/yum/*

#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_PATH}/libfastcommon \
 && mkdir -p ${FASTDFS_PATH}/fastdfs \
 && mkdir -p ${FASTDFS_PATH}/fastdfs-nginx-module \
 && mkdir ${FASTDFS_BASE_PATH}

# mkdir fastdfs folder
RUN mkdir -p /usr/share/fastdfs/storage \
&& mkdir -p /usr/share/fastdfs/client \
&& mkdir -p /usr/share/fastdfs/tracker \
&& mkdir -p /usr/share/fastdfs/tmp

#compile the libfastcommon
WORKDIR ${FASTDFS_PATH}/libfastcommon

RUN git clone --depth 1 https://github.com/happyfish100/libfastcommon.git ${FASTDFS_PATH}/libfastcommon \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/libfastcommon

#compile the fastdfs
WORKDIR ${FASTDFS_PATH}/fastdfs

RUN git clone --depth 1 https://github.com/happyfish100/fastdfs.git ${FASTDFS_PATH}/fastdfs \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/fastdfs
 
#comile nginx
WORKDIR ${FASTDFS_PATH}/fastdfs-nginx-module

# nginx url: https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
RUN git clone --depth 1 https://github.com/happyfish100/fastdfs-nginx-module.git ${FASTDFS_PATH}/fastdfs-nginx-module \
 && wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz \
 && tar -zxf nginx-${NGINX_VERSION}.tar.gz \
 && cd nginx-${NGINX_VERSION} \
 && ./configure --prefix=/usr/local/nginx --add-module=${FASTDFS_PATH}/fastdfs-nginx-module/src/ \
 && make \
 && make install \
 && ln -s /usr/local/nginx/sbin/nginx /usr/bin/ \
 && rm -rf ${FASTDFS_PATH}/fastdfs-nginx-module \
 
EXPOSE 22122 23000 8080 8888 80
VOLUME ["$FASTDFS_BASE_PATH","/etc/fdfs","/usr/local/nginx/html"]   

COPY fast-conf/*.* /etc/fdfs/

COPY nginx-conf/nginx.conf /usr/local/nginx/conf/

COPY start.sh /usr/bin/

ENV PATH /usr/local/nginx/sbin:$PATH

#make the start.sh executable 
RUN chmod 777 /usr/bin/start.sh


ENTRYPOINT ["/usr/bin/start.sh"]
#CMD ["nginx","-g", "daemon off;"]
