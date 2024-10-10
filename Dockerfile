FROM node:latest
LABEL description="Code Pod Space Dockerfile for build Docsify."
RUN npm config set registry https://registry.npmmirror.com
RUN npm install -g docsify-cli@latest
COPY ./ /docs
WORKDIR /docs
EXPOSE 3000/tcp
ENTRYPOINT ["docsify", "serve"]
