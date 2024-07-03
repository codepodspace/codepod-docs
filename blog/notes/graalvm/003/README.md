## 配置工程
 
    demo

配置修改

根目录 pom.xml修改，确保整个工程的paren是springboot

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.0.7</version>
    <relativePath/>
</parent>
```

demo 工程目录，pom.xml 文件修改：

```xml
<build>
    <finalName>demo</finalName>
    <plugins>
        <plugin>
            <groupId>org.graalvm.buildtools</groupId>
            <artifactId>native-maven-plugin</artifactId>
        </plugin>
        <plugin>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-maven-plugin</artifactId>
            <executions>
                <execution>
                    <goals>
                        <goal>repackage</goal>
                    </goals>
                </execution>
            </executions>
        </plugin>
    </plugins>
</build>
```

## 编译程序

### 1、清理工程

```bash
    mvn clean install
```

### 2、准备环境

Windows：

环境准备参见地址：[Windows环境](blog/notes/graalvm/001/)

Windows下先在控制台执行`gmpt.cmd`（命令配置详细见：[Windows环境](blog/notes/graalvm/001/?id=_6-新建快捷命令)）

Linux：

环境准备参见地址：[Linux环境](blog/notes/graalvm/002/)

### 3、启动，这一步是为自动生成动态代理的配置

重新进入项目工程代码目录

    java -D"file.encoding"=utf-8 -DspringAot=true -agentlib:native-image-agent=config-output-dir=src/main/resources/META-INF/native-image -jar target/demo.jar

【`重要`】启动成功后，将各个功能访问一遍，以确保覆盖到所有的反射代码。

Ctrl + C 退出

### 4、编译工程

```bash
    mvn -Pnative native:compile
```

## 编译结果

编译成功

## 执行二进制


Windows

```bash
    cd target
    demo.exe
```

Linux

```bash
    cd target
    chmod +x ./demo
    ./demo
```


## 结尾

本文介绍了一个简单的 SpringBoot工程通过 GraalVM 编译成二进制的过程。
