### Spring Initializr在线工具

	https://start.spring.io

### 项目信息

1. Project：Maven
2. Language：Java
3. SpringBoot Version: 3+
4. Project Metadata：
	- 按照项目信息填写，省略...
	- Package: Jar
    - Java版本选择：17

### 依赖选择

**Spring Reactive Web WEB**

Build reactive web applications with Spring WebFlux and Netty.

**Lombok DEVELOPER TOOLS**

Java annotation library which helps to reduce boilerplate code.

**Netflix DGS WEB**

Build GraphQL applications with Netflix DGS and Spring for GraphQL.

**GraphQL DGS Code Generation DEVELOPER TOOLS**

Generate data types and type-safe APIs for querying GraphQL APIs by parsing schema files.

**MySQL Driver SQL**

MySQL JDBC driver.

**Spring Data R2DBC SQL**

Provides Reactive Relational Database Connectivity to persist data in SQL stores using Spring Data in reactive applications.

### 生成完成

生成后自动下载项目zip包，完成！

### 定义Schema

	src/main/resources/schema/user.graphql

```graphql

type Query {
  user: UserInfo
}

type UserInfo {
  uuid: String
  name: String
  profile: String
}

```

### 配置代码自动生成

	pom.xml

```xml

	<build>
		<plugins>
			<plugin>
				<groupId>io.github.deweyjose</groupId>
				<artifactId>graphqlcodegen-maven-plugin</artifactId>
				<version>1.50</version>
				<executions>
					<execution>
						<id>dgs-codegen</id>
						<goals>
							<goal>generate</goal>
						</goals>
						<configuration>
							<!--schema目录-->
							<schemaPaths>
								<param>src/main/resources/schema</param>
							</schemaPaths>
							<packageName>com.example.demo.schema</packageName>
							<addGeneratedAnnotation>true</addGeneratedAnnotation>
						</configuration>
					</execution>
				</executions>
			</plugin>
			<plugin>
				<groupId>org.codehaus.mojo</groupId>
				<artifactId>build-helper-maven-plugin</artifactId>
				<executions>
					<execution>
						<id>add-dgs-source</id>
						<phase>generate-sources</phase>
						<goals>
							<goal>add-source</goal>
						</goals>
						<configuration>
							<sources>
								<source>${project.build.directory}/generated-sources</source>
							</sources>
						</configuration>
					</execution>
				</executions>
			</plugin>
			<plugin>
				<groupId>org.springframework.boot</groupId>
				<artifactId>spring-boot-maven-plugin</artifactId>
				<configuration>
					<excludes>
						<exclude>
							<groupId>org.projectlombok</groupId>
							<artifactId>lombok</artifactId>
						</exclude>
					</excludes>
				</configuration>
			</plugin>
		</plugins>
	</build>


	<repositories>
		<repository>
			<id>maven-public</id>
			<url>https://maven.aliyun.com/repository/public</url>
			<releases>
				<enabled>true</enabled>
			</releases>
			<snapshots>
				<enabled>true</enabled>
			</snapshots>
		</repository>
	</repositories>

	<pluginRepositories>
		<pluginRepository>
			<id>maven-public</id>
			<url>https://maven.aliyun.com/repository/public</url>
			<releases>
				<enabled>true</enabled>
			</releases>
			<snapshots>
				<enabled>true</enabled>
			</snapshots>
		</pluginRepository>
	</pluginRepositories>


```

执行Maven构建命令

	mvn clean package

在`target`目录下找到`generated-sources` 和`generated-examples`。

拷贝目录下的生成的类到项目工程中。

### 实现逻辑

继续完成 `UserDatafetcher`的代码逻辑

```java

@DgsComponent
public class UserDatafetcher {
  @DgsData(
      parentType = "Query",
      field = "user"
  )
  public Mono<UserInfo> getUser(DataFetchingEnvironment dataFetchingEnvironment) {
	//实现查询用户信息的逻辑，如查询数据库
	UserInfo user = new UserInfo();
    return Mono.just(user);
  }
}


```

### 调试代码

使用`postman`工具，使用`graphql`接口请求，调试接口。
