

## 一款跨平台的开源Github客户端App，仅供学习使用。



```!
基于Flutter开发，适配Android与IOS。

项目的目的是为方便个人日常维护和查阅Github，更好的沉浸于码友之间的互基，Github就是你的家。

项目同时适合Flutter的练手学习，覆盖了各种框架的使用，与原生的交互等。

随着项目的使用情况和反馈，将时不时根据更新并完善用户体验与功能优化吗，欢迎提出问题。
```


## 编译运行流程

1、配置好Flutter开发环境(目前Flutter SDK 版本 **1.7.8**)，可参阅 [【搭建环境】](https://flutter-io.cn/docs/get-started/install)。

2、clone代码，执行`Packages get`安装第三方包。(因为某些不可抗力原因，国内可能需要 [镜像地址](https://flutter-io.cn/community/china/))

>### 3、重点：你需要自己在lib/common/config/目录下 创建一个`ignoreConfig.dart`文件，然后输入你申请的Github client_id 和 client_secret。

     class NetConfig {
       static const CLIENT_ID = "xxxx";

       static const CLIENT_SECRET = "xxxxxxxxxxx";
     }


   [      注册 Github APP 传送门](https://github.com/settings/applications/new)，当然，前提是你现有一个github账号(～￣▽￣)～ 。

4、运行之前请注意下

>### 1、本地Flutter SDK 版本 1.7.8 以上。2、pubspec.yaml 中的第三方包版本和 pubspec.lock 中的是否对应的上

### 下载

#### Apk下载链接： [Apk下载链接](https://fir.im/m8zw)


### 常见问题

* 如果包同步失败，一般都是因为没设置包代理，可以参考：[环境变量](https://flutter-io.cn/community/china)



### 示例图片

<div>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/iOS_1.png" width="240px"/>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/Android_1.png" width="240px"/>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/iOS_2.png" width="240px"/>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/Android_3.png" width="240px"/>
<br>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/iOS_3.png" width="240px"/>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/Android_3.png" width="240px"/>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/iOS_4.png" width="240px"/>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/Android_4.png" width="240px"/>
<br>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/iOS_5.png" width="240px"/>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/Android_5.png" width="240px"/>
<br>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/iOS_6.png" width="240px"/>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/iOS_7.png" width="240px"/>
<img src="https://raw.githubusercontent.com/luoei/LGithubFlutter/master/images/iOS_8.png" width="240px"/>
</div>

### 感谢
[GSYGithubAppFlutter](https://github.com/CarGuo/GSYGithubAppFlutter/)
