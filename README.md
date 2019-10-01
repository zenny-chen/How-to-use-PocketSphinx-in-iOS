# How-to-use-PocketSphinx-in-iOS
iOS中如何嵌入并使用PocketSphinx

<br />

关于CMUSphinx的介绍可以参考这篇博文：[CMUSphinx文档指南翻译](https://github.com/zenny-chen/CMU-Document-Chinese-Translation)。而PocketSphinx是可用于移动端以及一些基于类Unix的嵌入式系统的跨平台的语音识别库。这个库其实已经非常成熟了，对于应付一般的语音识别已经没啥太大问题。不过，目前网上缺乏iOS平台的demo，因此笔者这里结合自己的一些经验来为大家介绍一下如何用macOS下载、安装、打包PocketSphinx，然后将打包完成的库放入你的iOS项目工程中并最终完成一个“Hello, World”的demo。另外，关于PocketSphinx的API文档可以参考此链接：[PocketSphinx API Documentation](https://cmusphinx.github.io/doc/pocketsphinx/index.html)

首先，对英文比较熟悉的童鞋可以看CMUSphinx官方的GitHub中的iOS demo：https://github.com/cmusphinx/pocketsphinx-ios-demo 。这里其实就一份描述文件和一份`build_iphone.sh`文件，可谓极其简陋。不过各位不用担心，macOS对开源代码的编译十分方便，即便现在Apple默认使用的是Xcode预装的Apple LLVM，但与GCC也基本兼容，所以也不用感到畏惧。如果各位对这段说明不太理解，那么请看下文的详细描述。不过，这里我们先把`build_iphone.sh`文件下载下来。

如果你的macOS上尚未安装autoconf与automake，那么请根据这篇博文进行安装：https://www.jianshu.com/p/497a26736eae 。这两个是作为自动配置、自动编译必备的工具，但最近这几代macOS都没有默认安装，所以我们需要自己手工安装一下。

完成之后，进入这个链接：https://github.com/cmusphinx/sphinxbase ，下载sphinxbase。这个库是Sphinx的基础库，所有版本的Sphinx都依赖此库。下载完成后，我们先把主文件夹名由sphinxbase-master改成 **sphinxbase** 。然后我们在控制台中进入sphinxbase目录，再输入以下shell命令：

```bash
./autogen.sh
./configure
<你存放build_iphone.sh文件的路径>/build_iphone.sh
```

完成之后我们在sphinxbase文件夹中能看到输出的bin文件夹，进入之后能看到这里面针对iOS现在所支持的每一种处理架构都有一个单独的文件夹，像arm64、armv7、i386以及x86_64。我们这里不需要i386处理器架构，因为它已经被废弃了。如果我们的iOS App只支持iOS 11，那么armv7都可以不要，因为iOS 11系统只有64位Apple处理器才能装。如果我们要支持iOS 11以下的设备，那么需要把armv7也带上。我们先进入arm64这个文件夹，把include中的整个sphinxbase文件夹先拷贝出来，后续要用。然后退出到前面的目录，找到lib。这里面有许多库文件，包含了两个静态库文件以及两个动态库文件。la文件是一个安装描述文件，我们可以无视。由于要上架到App Store的iOS App不允许运行时动态加载，因此我们这里选用静态库文件，即 **.a** 文件。为了后续处理方便，我们将这两个.a文件重命名为xxx_arm64.a（这里的xxx指libsphinxad或libsphinxbase），这样能跟后面的架构进行区分，然后将它们放到一个自己指定的文件目录下。
接着，我们再进入x86_64，这个是给模拟器用的，直接进入lib里面跟上面同样操作，只不过这里需要把两个静态库文件名重命名为xxx_x86.a，然后将它们放到与arm64版本相同的目录内。
如果我们的App需要支持iOS 11以下的设备，那么也需要针对armv7文件夹里面的lib做同样操作，将静态库文件名命名为xxx_armv7.a，然后放到指定目录内。
最后我们通过macOS独有的lipo命令分别将libsphinxad与libsphinxbase这两个静态库的所有架构版本组合到一起，生成最终的libsphinxad.a与libsphinxbase.a。lipo的用法请参考此博文：https://www.cnblogs.com/zenny-chen/archive/2012/06/13/2547837.html 。

sphinxbase项目搞定之后我们就可以下载pocketsphinx项目了，链接在此：https://github.com/cmusphinx/pocketsphinx 。下载完之后，将主文件夹名修改为 **pocketsphinx**，然后进入此目录，输入跟上面一样的控制台命令：

```bash
./autogen.sh
./configure
<你存放build_iphone.sh文件的路径>/build_iphone.sh
```

最后同样生成了一个bin目录，进去之后同样把include中的整个pocketsphinx拿出来，然后将lib目录中的相关架构的静态库文件取出来，组合成一个，跟上面的操作类似。然后，我们可以单独创建一个目录叫sphinx，然后把之前单独拿出了的sphinxbase头文件目录跟这里的pocketsphinx头文件目录直接放进去，然后再把三个静态库文件也放进去。然后这个包就作为整个PocketSphinx的包了。我们可以将这个包直接扔进创建出来的iOS项目工程中。

不过这里各位需要注意，由于在这些头文件中用了相对路径的目录形式，因此我们需要将以下三个相对目录添加到你的Xcode的项目中的 **Build Settings**栏下的 **Search Paths** 中的 **Header Search Paths** 项中。假定你创建的项目工程为SphinxTest：

```bash
$(SRCROOT)/SphinxTest/sphinx
$(SRCROOT)/SphinxTest/sphinx/pocketsphinx
$(SRCROOT)/SphinxTest/sphinx/sphinxbase
```

这样就能顺利通过编译了。

另外，我们在做语音识别时所需要的模型资源在Android demo中可以找到😓：https://github.com/cmusphinx/pocketsphinx-android-demo/tree/master/models/src/main/assets/sync

<br />

各位可以在本仓库获得完整的demo项目工程。

如果我们要屏蔽CMUSphinx内部的打印信息，那么我们可以先引入头文件`<sphinxbase/err.h>`，然后在调用任意CMUSphinx的API之前先调用一下`err_set_logfp(NULL);`即可。

关于如何构造自己想要的语音库，可以参考此博文：https://blog.csdn.net/google_acmer/article/details/40052291

这篇博文对CMU Sphinx4有个大致的介绍：https://blog.csdn.net/nnmmbb/article/details/49785535

如何使用PocketSphinx的Java接口，可参考此链接：https://github.com/cmusphinx/pocketsphinx/blob/master/swig/java/test/DecoderTest.java
