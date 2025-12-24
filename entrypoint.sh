#!/bin/sh

# 定义源文件位置和目标位置
SOURCE_JAR="/opt/velocity/velocity.jar"
TARGET_JAR="/server/velocity.jar"

echo "Checking Velocity jar..."

# 如果运行目录下没有 jar 包，或者强制更新开启，则从镜像内部复制出来
if [ ! -f "$TARGET_JAR" ]; then
    echo "Velocity jar not found in /server. Copying from image..."
    cp "$SOURCE_JAR" "$TARGET_JAR"
fi

# 设置默认内存
: ${MIN_MEM:=512M}
: ${MAX_MEM:=1G}

echo "Starting Velocity with ${MIN_MEM} to ${MAX_MEM} memory..."

# 启动
exec java \
  -Xms${MIN_MEM} \
  -Xmx${MAX_MEM} \
  -XX:+UseG1GC \
  -XX:G1HeapRegionSize=4M \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+ParallelRefProcEnabled \
  -XX:+AlwaysPreTouch \
  -jar velocity.jar