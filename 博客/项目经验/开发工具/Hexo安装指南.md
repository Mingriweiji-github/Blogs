## Hexo安装指南

**目录结构**

- 安装Node.js
- 添加国内镜像源
- 安装Git
- 注册Github账号
- 安装Hexo
- 连接Github与本地
- 写文章、发布文章
- 绑定域名
- 备份博客源文件
- 博客源代码下载
- 个性化设置（matery主题）
- 常见问题及解答（FAQ）
- 个性化设置（beantech主题，已停更）

# 安装Node.js

首先下载稳定版[Node.js](http://nodejs.cn/download/)。

安装选项全部默认，一路点击`Next`。

最后安装好之后，windows按`Win+R`打开命令提示符,mac打开命令行工具，输入`node -v`和`npm -v`，如果出现版本号，那么就安装成功了。

# 添加国内镜像源

如果没有梯子的话，可以使用阿里的国内镜像进行加速。

```bash
npm config set registry https://registry.npm.taobao.org
```

# 安装Git

为了把本地的网页文件上传到github上面去，我们需要用到分布式版本控制工具————Git[[下载地址\]](https://git-scm.com/download/win)。

安装选项还是全部默认，只不过最后一步添加路径时选择`Use Git from the Windows Command Prompt`，这样我们就可以直接在命令提示符里打开git了。

安装完成后在命令提示符中输入`git --version`验证是否安装成功。

# 注册Github账号

接下来就去注册一个github账号，用来存放我们的网站。大多数小伙伴应该都有了吧，作为一个合格的程序猿（媛）还是要有一个的。

打开https://github.com/，新建一个项目，如下所示：
![img](https://godweiyang.com/2018/04/13/hexo-blog/1.jpg)
然后如下图所示，输入自己的项目名字，后面一定要加`.github.io`后缀，README初始化也要勾上。**名称一定要和你的github名字完全一样，比如你github名字叫`abc`，那么仓库名字一定要是`abc.github.io`。**
![img](https://godweiyang.com/2018/04/13/hexo-blog/2.jpg)
然后项目就建成了，点击`Settings`，向下拉到最后有个`GitHub Pages`，点击`Choose a theme`选择一个主题。然后等一会儿，再回到`GitHub Pages`，会变成下面这样：
![img](https://godweiyang.com/2018/04/13/hexo-blog/3.jpg)
点击那个链接，就会出现自己的网页啦，效果如下：
![img](https://godweiyang.com/2018/04/13/hexo-blog/4.jpg)

# 安装Hexo

在合适的地方新建一个文件夹，用来存放自己的博客文件，比如存放到```~/Desktop/Dev/blog```目录下。

在该目录下右键点击`Git Bash Here`，打开git的控制台窗口，以后我们所有的操作都在git控制台进行，就不要用Windows自带的控制台了。

定位到该目录下，输入`npm i hexo-cli -g`安装Hexo。会有几个报错，无视它就行。

#### 安装报错：Mac install hexo use sudo but sitll permission denied



参照hexo官网 [Hexo](https://hexo.io/zh-cn/index.html) 安装hexo时,使用命令 `npm install hexo-cli -g` 却报没有权限:

```nginx
$ npm install hexo-cli -g
npm WARN checkPermissions Missing write access to /usr/local/lib/node_modules
npm ERR! path /usr/local/lib/node_modules
npm ERR! code EACCES
npm ERR! errno -13
npm ERR! syscall access
npm ERR! Error: EACCES: permission denied, access '/usr/local/lib/node_modules'
npm ERR!  { Error: EACCES: permission denied, access '/usr/local/lib/node_modules'
npm ERR!   stack: 'Error: EACCES: permission denied, access \'/usr/local/lib/node_modules\'',
npm ERR!   errno: -13,
npm ERR!   code: 'EACCES',
npm ERR!   syscall: 'access',
npm ERR!   path: '/usr/local/lib/node_modules' }
npm ERR!
npm ERR! Please try running this command again as root/Administrator.

npm ERR! A complete log of this run can be found in:
npm ERR!     /Users/xxx/.npm/_logs/2017-10-27T01_21_01_871Z-debug.log
```

#### 解决permission denied方法

第一步,赋予目录权限:

```
$ sudo chown -R `whoami` /usr/local/lib/node_modules
```

第二步,安装hexo:

```
$ npm install hexo-cli -g
```

> 需要注意的点: 在安装hexo时,不要用 `sudo` 命令.



安装完后输入`hexo -v`验证是否安装成功。

> 出现   INFO  Start blogging with Hexo! 表示成功安装hexo

然后初始化我们的网站，依次输入

$ hexo init blog

$ cd blog

$ npm install

$ hexo g # 或者hexo generate

$ hexo s # 或者hexo server，可以在http://localhost:4000/ 查看

输入`hexo g`生成静态网页，然后输入`hexo s`打开本地服务器，然后浏览器打开http://localhost:4000/，就可以看到我们的博客啦，效果如下：
![img](https://godweiyang.com/2018/04/13/hexo-blog/5.jpg)

按`ctrl+c`关闭本地服务器。

# 连接Github与本地

首先右键打开git bash，然后输入下面命令：

```bash
git config --global user.name "godweiyang"
git config --global user.email "792321264@qq.com"
```

用户名和邮箱根据你注册github的信息自行修改。

然后生成密钥SSH key：

```bash
ssh-keygen -t rsa -C "792321264@qq.com"
```

打开[github](https://github.com/)，在头像下面点击`settings`，再点击`SSH and GPG keys`，新建一个SSH，名字随便。

git bash中输入

```bash
cat ~/.ssh/id_rsa.pub
```

将输出的内容复制到框中，点击确定保存。

输入`ssh -T git@github.com`，如果如下图所示，出现你的用户名，那就成功了。
![img](https://godweiyang.com/2018/04/13/hexo-blog/6.jpg)

打开博客根目录下的`_config.yml`文件，这是博客的配置文件，在这里你可以修改与博客相关的各种信息。

修改最后一行的配置：

```bash
deploy:
  type: git
  repository: https://github.com/godweiyang/godweiyang.github.io
  branch: master
```

repository修改为你自己的github项目地址。

# 写文章、发布文章

首先在博客根目录下右键打开git bash，安装一个扩展`npm i hexo-deployer-git`。

然后输入`hexo new post "article title"`，新建一篇文章。

然后打开`D:\study\program\blog\source\_posts`的目录，可以发现下面多了一个文件夹和一个`.md`文件，一个用来存放你的图片等数据，另一个就是你的文章文件啦。

编写完markdown文件后，根目录下输入`hexo g`生成静态网页，然后输入`hexo s`可以本地预览效果，最后输入`hexo d`上传到github上。这时打开你的github.io主页就能看到发布的文章啦。





