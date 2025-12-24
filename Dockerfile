# 1. 基础镜像
FROM eclipse-temurin:21-jre-alpine

# 2. 设置工作目录
WORKDIR /server

# 3. 安装基础工具
RUN apk add --no-cache curl jq

# 4. 自动下载最新版 Velocity (保持不变)
RUN echo "Downloading latest Velocity..." && \
    VERSION="3.4.0-SNAPSHOT" && \
    BUILD_ID=$(curl -s "https://api.papermc.io/v2/projects/velocity/versions/${VERSION}/builds" | jq -r '.builds[-1].build') && \
    DOWNLOAD_URL="https://api.papermc.io/v2/projects/velocity/versions/${VERSION}/builds/${BUILD_ID}/downloads/velocity-${VERSION}-${BUILD_ID}.jar" && \
    echo "Downloading Build ${BUILD_ID}..." && \
    curl -o velocity.jar "${DOWNLOAD_URL}"

# 创建一个空的 plugins 目录，防止启动时因为目录不存在而报错
RUN mkdir -p /server/plugins

# 6. 复制启动脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 7. 创建用户并赋予权限
# 注意：chown -R 会把刚才创建的空 /server/plugins 目录的所有权给 velocity 用户
RUN addgroup -S velocity && adduser -S velocity -G velocity && \
    chown -R velocity:velocity /server

# 8. 切换用户
USER velocity

# 9. 暴露端口
EXPOSE 25577
EXPOSE 19132/udp

# 10. 声明数据卷 (Volume)
# 这里声明只是为了告诉使用者“这几个目录建议映射出去”
VOLUME ["/server/plugins", "/server/logs", "/server/velocity.toml"]

# 11. 启动
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]