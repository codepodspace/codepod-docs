## Nginx

目录结构

    |------------
        |--docker-compose.yaml
        |--nginx
            |--default.conf

`docker-compose.yaml`

```yaml
version: '3'
services:
  nginx: 
    image: nginx:1.22.0
    restart: always
    ports:
      - 80:80
    volumes: 
      - /etc/localtime:/etc/localtime:ro
      - ./nginx/default.conf:/etc/nginx/conf.d/default.conf
      - ./nginx/log:/var/log/nginx
```

`default.conf`

```conf
server {
    listen       80;
    listen  [::]:80;

		location ^~/ {
			proxy_set_header  Host $host;
			proxy_set_header  X-Real-IP  $remote_addr;
			proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
			#proxy_connect_timeout  "100";
			#proxy_read_timeout  "100";
			#proxy_send_timeout  "100";
			#client_max_body_size  "20M";
			#client_body_buffer_size "20M";
			proxy_pass http://hello-world:8080;
		}
}
```

## MySQL

目录结构

    |------------
        |--docker-compose.yaml
        |--mysql
            |--Dockerfile
            |--my.cnf
            |--mysql.env
            |--sql
                |--create_user_auth.sql
                |--xxx.sql

`docker-compose.yaml`

```yaml
version: '3'
services:
  mysql:
    build:
      context: ./mysql
      dockerfile: Dockerfile
    image: my/mysql:5.7.33
    env_file:
      - ./mysql/mysql.env
    volumes:
      - ./mysql/data:/var/lib/mysql
    ports:
      - "3306:3306"
    restart: always
    environment:
      - TZ=Asia/Shanghai
```

`Dockerfile`

```Dockerfile
FROM mysql:5.7.33

ADD sql/hello_world.sql /docker-entrypoint-initdb.d/hello_world.sql

ADD sql/create_user_auth.sql /docker-entrypoint-initdb.d/create_user_auth.sql

COPY my.cnf /etc/mysql/conf.d/my.cnf

RUN chown -R mysql:mysql /docker-entrypoint-initdb.d/*.sql

EXPOSE 3306
CMD ["mysqld", "--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci"]

```


`mysql.env`

```ini

MYSQL_ROOT_PASSWORD=【ROOT密码】
MYSQL_DATABASE=mysql
LANG=C.UTF-8

```

`my.cnf`

```ini

[mysqld]
character-set-server=utf8mb4
default-storage-engine=InnoDB
max_connections=2048
max_allowed_packet=128M

```

`sql/【SQL文件】`

```sql

--创建 create_user_auth.sql 文件

CREATE USER IF NOT EXISTS `hello`@`%` IDENTIFIED BY '【密码】';
GRANT Alter, Create, Create Temporary Tables, Create View, Delete, Execute, Index, Insert, Select, Show View, Trigger, Update ON `hello_world`.* TO `hello`@`%`;

--创建 hello_world.sql 文件

--注意这两行放在开头
CREATE DATABASE IF NOT EXISTS `hello_world` CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_general_ci';
USE `hello_world`;

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE `demo`  (
  `id` bigint(20) UNSIGNED NOT NULL AUTO_INCREMENT COMMENT '主键',
  `uuid` varchar(50) NOT NULL COMMENT '唯一ID',
  `info` varchar(100) NOT NULL DEFAULT '' COMMENT '描述',
  `remark` varchar(50) NULL DEFAULT NULL COMMENT '备注',
  `del_flag` tinyint(1) NOT NULL DEFAULT 1 COMMENT '删除标识: 1存在, 0删除',
  `create_by` varchar(64) NOT NULL DEFAULT '' COMMENT '创建人',
  `create_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP COMMENT '创建时间',
  `update_by` varchar(64) NOT NULL DEFAULT '' COMMENT '更新人',
  `update_time` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP COMMENT '更新时间',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_uuid`(`uuid`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 10 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci COMMENT = '示例DEMO表' ROW_FORMAT = Dynamic;


```

## GitLab

```yaml
version: '3'
services:
  gitlab:
    image: 'gitlab/gitlab-ce:15.2.2-ce.0'
    privileged: true
    container_name: gitlab-ce
    restart: always
    environment:
      GITLAB_OMNIBUS_CONFIG: |
        external_url 'http://192.168.1.2:8929' #若公网访问，填写公网IP或域名
        gitlab_rails['gitlab_shell_ssh_port'] = 10022
    ports:
      - '8929:8929'
      - '10022:22'
    volumes:
      - './config:/etc/gitlab'
      - './logs:/var/log/gitlab'
      - './data:/var/opt/gitlab'

```

## jenkins

```yaml
version: '3'
services:
  jenkins:
    restart: always
    user: root
    image: jenkins/jenkins:lts
    container_name: jenkins
    ports:
      - '8080:8080'
      - '50000:50000'
    volumes:
      - ./data/:/var/jenkins_home
      - ./war/:/usr/share/jenkins
      - /etc/localtime:/etc/localtime:ro
      - /etc/timezone/timezone:/etc/timezone:ro
      - /var/run/docker.sock:/var/run/docker.sock
      - /usr/bin/docker:/usr/bin/docker
```

## Media Wiki

```yaml
version: '3'
services:
  mediawiki:
    image: mediawiki:1.37.1
    restart: always
    ports:
      - 8080:80
    links:
      - database
    volumes:
      - ./mediawiki/html:/var/www/html
    networks:
      - devops
  database:
    image: mariadb
    restart: always
    environment:
      MYSQL_DATABASE: my_wiki
      MYSQL_USER: wikiuser
      MYSQL_PASSWORD: example
      MYSQL_RANDOM_ROOT_PASSWORD: 'yes'
    volumes:
      - ./mysql/data:/var/lib/mysql
    networks:
      - devops
networks:
  devops:
    external:
      name: devops
```
