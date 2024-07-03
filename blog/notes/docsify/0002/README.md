
根目录添加`Dockerfile`文件

```dockerfile
FROM node:latest
LABEL description="A Demo Dockerfile for build Docsify."
RUN npm install -g docsify-cli@latest
COPY ./ /docs
WORKDIR /docs
EXPOSE 3000/tcp
ENTRYPOINT ["docsify", "serve"]
```