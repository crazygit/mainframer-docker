# 创建[mainframer](https://github.com/buildfoundation/mainframer)远端android编译环境


## 使用

### 直接使用

```bash
$ docker run -p 2200:22 -d crazygit/mainframer
```

### 配合gradle本机缓存以及阿里云镜像使用

```bash
$ docker run \
       -p 2200:22 \
       -v ${HOME}/.gradle:/root/.gradle \
       -v $(pwd)/mirror/init.gradle:/root/.gradle/init.gradle \
       -v $(pwd)/mirror/sources.list:/etc/apt/sources.list \
       -d crazygit/mainframer
```

### 使用`docker-compose`

```bash
$ git clone https://github.com/crazygit/mainframer-docker.git
$ cd mainframer-docker
$ docker-compose up -d
```

## `ssh`连接
ssh进入容器, 默认用户名和密码为`root/root`

```bash
$ ssh -p 2200 root@localhost
```

### 客户端配置

请参考[项目文档](https://github.com/buildfoundation/mainframer/tree/2.x)，当前稳定版本是`2.x`版本

配合插件[Android Studio Plugin](https://github.com/elpassion/mainframer-intellij-plugin)使用效果更佳。
