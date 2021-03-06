FROM ubuntu:18.04

LABEL maintainer=Crazygit
LABEL homepage="https://github.com/crazygit/mainframer-docker"

WORKDIR /android/sdk

# set where to get commandline tools
ARG commandlinetools_linux=https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip

# Replace apt mirror to speed up in China
#COPY config/sources.list /etc/apt/sources.list

# Set the locale
# https://stackoverflow.com/a/28406007/1957625
RUN apt-get update && \
    apt-get install -y locales && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV LANG=en_US.UTF-8 \
    LANGUAGE=en_US:en \
    LC_ALL=en_US.UTF-8

# ANDROID_HOME环境变量已经废弃不用，但是一些老项目的gradle需要
ENV ANDROID_SDK_ROOT=/android/sdk \
    ANDROID_HOME=/android/sdk

# add android env to the begin of file ~/.bashrc (测试发现添加到~/.bashrc文件末尾不生效)
RUN bash -c 'echo -e "export ANDROID_HOME=${ANDROID_HOME}\nexport ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT}\n"' | cat - ~/.bashrc > bashrc.tmp && mv bashrc.tmp ~/.bashrc

# Install OpenJDK 8 and other dependences
RUN apt-get update && \
    # required
    apt-get install -y openjdk-8-jdk openssh-server wget unzip openssh-server rsync && \
    # debug need
    apt-get install -y vim git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install android commandline tools
RUN wget -q ${commandlinetools_linux} -O tools.zip && unzip tools.zip && rm -f tools.zip

# Install licenses
# https://developer.android.com/studio/intro/update.html#download-with-gradle
RUN mkdir licenses && \
    echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > licenses/android-sdk-license && \
    echo "84831b9409646a918e30573bab4c9c91346d8abd" > licenses/android-sdk-preview-license && \
    echo "d975f751698a77b662f1254ddbeed3901e976f5a" > licenses/intel-android-extra-license

# Setup ssh server
RUN apt-get update && \
    apt-get install -y openssh-server && \
    mkdir /var/run/sshd && \
    echo 'root:root' |chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config


EXPOSE 22

CMD ["/usr/sbin/sshd", "-D"]

