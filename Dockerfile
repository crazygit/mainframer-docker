FROM ubuntu:18.04

LABEL maintainer=Crazygit
LABEL homepage="https://github.com/crazygit/mainframer-docker"

WORKDIR /android/sdk
ENV ANDROID_SDK_ROOT /android/sdk

# Install Oracle JDK 8
# 方法已经失效: https://stackoverflow.com/a/58214875/1957625
#RUN apt-get update && \
#    apt-get install -y software-properties-common && \
#    add-apt-repository -y ppa:webupd8team/java && \
#    apt-get update && \
#    echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | /usr/bin/debconf-set-selections && \
#    apt-get install -y oracle-java8-installer oracle-java8-set-default && \
#    apt-get clean && \
#    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install OpenJDK 8 and other dependences
RUN apt-get update && \
    # required
    apt-get install -y openjdk-8-jdk openssh-server wget unzip openssh-server && \
    # debug need
    apt-get install -y vim git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*


# set where to get commandline tools
ARG commandlinetools_linux=https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip

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

# Just used for test andoird app compile env
#RUN git clone https://github.com/android/architecture-components-samples.git /tmp/architecture-components-samples && cd /tmp/architecture-components-samples/BasicSample && ./gradlew clean assemble
CMD    ["/usr/sbin/sshd", "-D"]
