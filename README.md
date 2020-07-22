![Publish Docker Image](https://github.com/crazygit/mainframer-docker/workflows/Publish%20Docker%20Image/badge.svg)

[toc]

# 使用[mainframer](https://github.com/buildfoundation/mainframer)实现远端编译android apk

众所周知，android开发中，每次编译APK的时间都是比较长的，尤其是在本地机器配置较差的情况下，编译一次的时间就更长了。通过`mainframer`，我们可以实现在本机开发的同时，使用一个远端机器(拥有高配置的机器)上编译代码，然后自动将编译结果同步到本地，再自动执行安装，调试等任务。整个过程就跟在本机编译一样，不仅可以大大节约编译时间，也可以降低对开发机器的配置要求。

如果是在团队，搭建这样一个环境，让所有人开发人员共用，可以提高整个团队的开发效率，实乃开发必备的神器。

借助`docker`，我们可以非常方便地快速搭建一套远端的编译环境。

## 远端编译环境配置

直接使用docker镜像，可以让你轻松搞定远端的配置

镜像源码：

<https://github.com/crazygit/mainframer-docker.git>

### 方法一: 直接使用

这种方式适合远端编译机器处于网络条件较好，能自由畅游网络的情况下。

```bash
$ docker run -p 2200:22 -d crazygit/mainframer
```

### 方法二: 配合gradle本机缓存以及阿里云镜像使用

在编译过程中，会下载很多依赖包，由于众所周知的原因，我们需要使用各种源镜像才能流畅编译

```bash
$ git clone https://github.com/crazygit/mainframer-docker.git
$ cd mainframer-docker
$ docker run \
       -p 2200:22 \
       -v ${HOME}/.gradle:/root/.gradle \
       -v $(pwd)/config/init.gradle:/root/.gradle/init.gradle \
       -v $(pwd)/config/gradle.properties:/root/.gradle/gradle.properties \
       -v $(pwd)/config/sources.list:/etc/apt/sources.list \
       -d crazygit/mainframer
```

### 方法三: 使用`docker-compose`

上面命令太长了，使用`docker-compose`简化下。

```bash
$ git clone https://github.com/crazygit/mainframer-docker.git
$ cd mainframer-docker
$ docker-compose up -d
```

### `ssh`连接容器

ssh连接容器, 默认用户名和密码为`root/root`

```bash
$ ssh -p 2200 root@localhost
```

## 客户端配置

### 命令行使用

请参考[项目文档](https://github.com/buildfoundation/mainframer/tree/2.x)，当前稳定版本是`2.x`版本


### 通过[Android Studio插件](https://github.com/elpassion/mainframer-intellij-plugin)使用(推荐)

#### ssh免密码登录配置

参考[文档](https://github.com/buildfoundation/mainframer/blob/v2.1.0/docs/SETUP_LOCAL.md)配置好本机能免ssh密码登录远端服务器，插件的原理就是使用`rsync`命令，通过`ssh`协议在远端和本地同步文件。

#### 安装插件

可以通过`Android Studio`插件中心搜索`mainframer`安装插件，或者到[项目发布页面](https://github.com/elpassion/mainframer-intellij-plugin/releases)下载插件再手动安装

#### 插件初始配置

**注意**: _由于插件的配置只影响当前项目，所以每次新建项目都需要执行下面的配置操作_


首先配置远端编译机器的信息, 在`Tools` -> `Mainframer` -> `Configure Mainframer in Project`

![Configure Mainframer in Project](http://images.wiseturtles.com/1586854091.png)

打开之后，可以选择使用`mainframer`的版本，以及远端编译机器的名字, 和默认的编译命令。这里我设置为`./gralew build`(为什么不设置为`./gralew assemble`? 可以参考[问答](https://stackoverflow.com/a/44185464/1957625))。

_注意修改红色框里的远端机器信息为你自己使用的远端机器信息_

![Configure Mainframer for Project](http://images.wiseturtles.com/1586855079.png)


配置好之后，插件会自动下载`mainframer`插件，然后会看到一个弹窗,让我们选择配置模板，这里我们选择`Android`就可以了。(是的，`mainframer`不光只是用于`android`开发，也支持其它项目的开发)

![config templates](http://images.wiseturtles.com/1586855293.png)

最后在项目根目录下面，可以看到多了一个`mainframer`文件以及一个`.mainframer`目录, 里面包含了默认的配置信息，基本上足够我们日常使用了

```bash
# .mainframer目录结构
$ tree .mainframer
.mainframer
├── config
├── ignore
├── localignore
└── remoteignore

0 directories, 4 files
```

#### 注入mainframer到编译选项中

默认情况下，当我们写好代码，点击`Run`按钮的时候，Android Studio实际执行的任务是依次是: `Gradle-aware Make`，安装APK，运行APK。

![Before](http://images.wiseturtles.com/1586854813.png)

注入`mainframer`之后，效果如下:

![After](http://images.wiseturtles.com/1586855427.png)

`Before launch`的操作由原来的`Gradle-aware Make`变成了`Mainframer Make`。现在我们点击`Run`按钮之后，它会自动将代码同步到远端机器编译，然后将编译生成的APK拷贝回来，再自动执行后续的安装，启动等任务。是不是很方便呢？

注入的具体操作如下：

依次打开`Tools`->`Maineframer`->`Inject or resotore Configurations`

![inject](http://images.wiseturtles.com/1586854917.png)

然后选择要注入的模板，上面是已经创建好的编译配置。下面是Android Studio自带的模板。 选择需要注入的配置即可。后面也可以随时来取消选择，将注入的模板还原回去。
![](http://images.wiseturtles.com/1586854951.png)

另外我们也可以自己添加`Mainframer`运行配置

![custom add](http://images.wiseturtles.com/1586855941.png)


#### 在远端和本地编译直接切换

插件安装好之后，在工具栏可以看到一个蓝色的按钮，通过它，我们可以随时切换在远端编译还是本地编译，非常方便。

![switch](http://images.wiseturtles.com/1586856042.png)

插件的日常使用主要也就这些了，快去体验一下吧！
