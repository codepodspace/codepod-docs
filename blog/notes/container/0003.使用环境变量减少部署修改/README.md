
我们可以通过 Docker Compose 一键部署，通过环境变量文件.env来全局管理程序变量，可以提升部署效率，减少出错。

## 目录文件

    |---------------
        |--.env
        |--docker-compose.yaml
            |--hello-world
                |--application-dev.properties
                |--application-sit.properties
                |--application-prd.properties
            |--test
                |--application-dev.properties
                |--application-sit.properties
                |--application-prd.properties


### .env

```ini

# spring.profiles.active
SPRING_PROFILES_ACTIVE=prd

# 构建版本
BUILD_VERSION=1.0.1

# MySQL
MYSQL_SERVER_IP=172.17.0.7
MYSQL_SERVER_PORT=3306

MYSQL_DB1_USER=【用户名】       //替换成实际的数据库用户名
MYSQL_DB1_PASSWORD=【密码】     //替换成实际的数据库密码

MYSQL_DB2_USER=【用户名】       //替换成实际的数据库用户名
MYSQL_DB2_PASSWORD=【密码】     //替换成实际的数据库密码

# Redis 
REDIS_SERVER_IP=172.17.0.7
REDIS_SERVER_PORT=6379
REDIS_DB_0=0
REDIS_DB_1=1

...

```

### docker-compose.yaml

```yaml
version: '3'
services:
  hello-world: 
    image: my/study/hello-world:${BUILD_VERSION}
    restart: always
    ports:
      - 8080:8080
    working_dir: /code
    volumes: 
      - ./hello-world/application.properties:/code/application.properties
    environment:
      TZ: "Asia/Shanghai"
      mysql_server_ip: ${MYSQL_SERVER_IP}
      mysql_server_port: ${MYSQL_SERVER_PORT}
      mysql_hello_user: ${MYSQL_DB1_USER}
      mysql_hello_password: ${MYSQL_DB1_PASSWORD}
      redis_server_ip: ${REDIS_SERVER_IP}
      redis_server_port: ${REDIS_SERVER_PORT}
      redis_db_0: ${REDIS_DB_0}
    entrypoint:
      - java
      - -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}
      - -jar
      - hello-world.jar
  test: 
    image: my/study/test:${BUILD_VERSION}
    restart: always
    ports:
      - 8081:8081
    working_dir: /code
    volumes: 
      - ./hello-world/application.properties:/code/application.properties
    environment:
      TZ: "Asia/Shanghai"
      mysql_server_ip: ${MYSQL_SERVER_IP}
      mysql_server_port: ${MYSQL_SERVER_PORT}
      mysql_test_user: ${MYSQL_DB2_USER}
      mysql_test_password: ${MYSQL_DB2_PASSWORD}
      redis_server_ip: ${REDIS_SERVER_IP}
      redis_server_port: ${REDIS_SERVER_PORT}
      redis_db_1: ${REDIS_DB_1}
    entrypoint:
      - java
      - -Dspring.profiles.active=${SPRING_PROFILES_ACTIVE}
      - -jar
      - test.jar

```

### application-【环境】.properties

- dev: 开发环境
- sit: 集成测试环境
- prd: 生产环境

这里举 hello-world 的例子

```ini

spring.datasource.dynamic.strict=false
spring.datasource.dynamic.primary=default
spring.datasource.dynamic.datasource.default.url=jdbc:mysql://${mysql_server_ip}:${mysql_server_port}/hello_world?characterEncoding=UTF-8&serverTimezone=Asia/Shanghai&useSSL=false
spring.datasource.dynamic.datasource.default.username=${mysql_hello_user}
spring.datasource.dynamic.datasource.default.password=${mysql_hello_password}
spring.datasource.dynamic.datasource.default.driver-class-name=com.mysql.cj.jdbc.Driver
spring.datasource.dynamic.datasource.default.type=com.alibaba.druid.pool.DruidDataSource
#省略...

#redis
spring.redis.host=${redis_server_ip}
spring.redis.port=${redis_server_port}
spring.redis.database=${redis_db_0}
#省略...

```


## 部署发布

后续部署只需要修改 .env 文件，替换环境的实际的环境变量配置，而不需要修改其他很多的配置，非常方便。