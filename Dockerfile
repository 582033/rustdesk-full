# 使用 Alpine 3.22 作为基础镜像
FROM alpine:3.22

WORKDIR /app
# 将可执行文件从主机的 ./app/ 目录复制到镜像中
COPY ./realese/ .
COPY ./data/key/* .
COPY start-services.sh .

# 开放端口
EXPOSE 21114-21119


# 赋予这两个文件可执行权限
RUN chmod +x /app/hbbs /app/hbbr /app/apimain start-services.sh

# 设置启动命令
CMD ["./start-services.sh"]
