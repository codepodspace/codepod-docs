
本文介绍在Windows下安装 GraalVM，以及配置 Native Image 环境，来进行`java`编译成二进制。

## 1. 下载安装GraalVM

官方地址：https://www.graalvm.org/downloads/

Java17：https://github.com/graalvm/graalvm-ce-builds/releases/download/vm-22.3.1/graalvm-ce-java17-windows-amd64-22.3.1.zip


## 2. 配置环境变量

```bash
    GRAALVM_HOME=D:\javaEnv\graalvm-ce-java17-22.3.1
```

## 3. 安装Visual Studio Community 2022

官方地址：https://visualstudio.microsoft.com/zh-hans/downloads/

安装`C++桌面开发`，确保勾选`MSVC`生成工具

![](./_media/01.png ':size=800')

安装结束后，在开始菜单搜索`prompt`：

![](./_media/02.png ':size=800')

## 4. 修改默认JAVA版本为GraalVM

本地有多个JDK版本的情况，为了让命令工具默认使用 GraalVM JAVA，我们可以这样设置：

![](./_media/03.png ':size=800')

`右键`->`属性`，在`目标`中找到命令地址：

比如这里是：`D:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat`

![](./_media/04.png ':size=800')

![](./_media/05.png ':size=800')

打开`资源管理器`：在地址栏输入地址：`D:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\`

![](./_media/06.png ':size=800')

右键`vcvarsall.bat`，找个顺手的文本编辑器进行编辑，在文件内容最前面，添加如下代码

![](./_media/07.png ':size=800')

    set JAVA_HOME=%GRAALVM_HOME%
    set PATH=%JAVA_HOME%\bin;%PATH%

这样就替换了`GraalVM`的版本。

## 5. 安装 Native Image

```bash
    gu install native-image
```

参考地址：https://www.graalvm.org/latest/docs/getting-started/#native-image


## 6. 新建快捷命令

- 1）自己确定一个目录存放快捷命令，比如：

    D:\javaEnv\graalvm17-prompt

- 2）新建`gmpt.cmd`文件，内容：

    cmd.exe /k "D:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvars64.bat"

- 3）添加环境变量

![](./_media/08.png ':size=800')


最后，在编译java的时候，在 cmd 命令输入`gmpt.cmd`，回车执行

![](./_media/09.png ':size=800')

![](./_media/10.png ':size=800')

看到 visual studio 相关信息 说明配置成功。

查看java环境，输入:

```bash
    java -version
```

![](./_media/11.png ':size=800')


## 7. 结尾

这样Windows 整个环境都安装完成了。