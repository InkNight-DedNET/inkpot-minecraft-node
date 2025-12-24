# 1. 基础镜像
FROM eclipse-temurin:21-jre-alpine

# 2. 设置工作目录 (运行时的工作目录)
WORKDIR /server

# 3. 安装基础工具
RUN apk add --no-cache curl jq

# 4. 【关键修改】把 Velocity 下载到 /opt/velocity 目录 (避开挂载点)
RUN mkdir -p /opt/velocity && \
    echo "Downloading latest Velocity..." && \
    VERSION="3.4.0-SNAPSHOT" && \
    BUILD_ID=$(curl -s "https://api.papermc.io/v2/projects/velocity/versions/${VERSION}/builds" | jq -r '.builds[-1].build') && \
    DOWNLOAD_URL="https://api.papermc.io/v2/projects/velocity/versions/${VERSION}/builds/${BUILD_ID}/downloads/velocity-${VERSION}-${BUILD_ID}.jar" && \
    echo "Downloading Build ${BUILD_ID}..." && \
    curl -o /opt/velocity/velocity.jar "${DOWNLOAD_URL}"

# 5. 复制启动脚本
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# 6. 创建用户
# 我们需要确保 velocity 用户对 /server 有权写入，但因为 /server 会被挂载覆盖
# 所以这里的权限设置主要针对非挂载情况，或者作为一种 best practice
RUN addgroup -S velocity && adduser -S velocity -G velocity

# 7. 【重要】不在这里创建 /server 下的子目录
# 因为一旦挂载宿主机目录，这里创建的都会被隐藏

# 8. 切换用户
USER velocity

# 9. 暴露端口
EXPOSE 25577
EXPOSE 19132/udp

# 10. 声明数据卷
# 声明整个 server 目录为数据卷
VOLUME ["/server"]

# 11. 启动
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]