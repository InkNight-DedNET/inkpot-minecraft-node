#!/bin/sh

# 设置默认内存，如果环境变量没传则使用默认值
: ${MIN_MEM:=512M}
: ${MAX_MEM:=1G}

echo "Starting Velocity with ${MIN_MEM} to ${MAX_MEM} memory..."

# 启动 Velocity
# -XX:+UseG1GC 是官方推荐的垃圾回收器
# exec 命令能让 java 进程替换当前 shell 进程，接收停止信号
exec java \
  -Xms${MIN_MEM} \
  -Xmx${MAX_MEM} \
  -XX:+UseG1GC \
  -XX:G1HeapRegionSize=4M \
  -XX:+UnlockExperimentalVMOptions \
  -XX:+ParallelRefProcEnabled \
  -XX:+AlwaysPreTouch \
  -jar velocity.jar