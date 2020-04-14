## 创建[mainframer](https://github.com/buildfoundation/mainframer)远端android开编译环境


### 使用

```bash
$ docker run -p 2200:22 -d crazygit/mainframer

# 或使用gradle本机缓存和使用阿里云镜像
$ docker run \
       -p 2200:22 \
       -v ${HOME}/.gradle:/root/.gradle \
       -v $(pwd)/mirror/init.gradle:/root/.gradle/init.gradle \
       -v $(pwd)/mirror/sources.list:/etc/apt/sources.list \
       -d crazygit/mainframer
```

ssh进入容器, 默认用户名和密码都是`root`

```bash
$ ssh -p 2200 root@localhost
```

### 客户端配置

请参考[项目文档](https://github.com/buildfoundation/mainframer/tree/2.x)，当前稳定版本是`2.x`版本
