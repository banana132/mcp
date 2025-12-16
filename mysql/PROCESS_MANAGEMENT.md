# 🔄 MySQL MCP服务器进程管理指南

本指南详细说明如何以进程方式启动、停止和管理MySQL MCP服务器。

## 📋 目录

- [进程管理概述](#进程管理概述)
- [启动服务器](#启动服务器)
- [停止服务器](#停止服务器)
- [状态监控](#状态监控)
- [综合管理](#综合管理)
- [系统服务集成](#系统服务集成)
- [日志管理](#日志管理)
- [性能监控](#性能监控)
- [故障排除](#故障排除)

## 🔄 进程管理概述

MySQL MCP服务器支持两种运行模式：

1. **前台模式**: 在终端前台运行，直接显示输出
2. **后台模式**: 在后台作为守护进程运行

### 管理工具

| 脚本 | 功能 | 使用场景 |
|------|------|----------|
| `start.sh` | 启动服务器 | 启动和管理服务器进程 |
| `stop.sh` | 停止服务器 | 优雅停止服务器进程 |
| `status.sh` | 状态监控 | 查看服务器运行状态 |
| `manage.sh` | 综合管理 | 一站式进程管理 |

## 🚀 启动服务器

### 前台模式启动

```bash
# 默认前台启动
./start.sh

# 明确指定前台模式
./start.sh --foreground
```

**特点**:
- 输出直接显示在终端
- 按 `Ctrl+C` 停止
- 适合调试和开发

### 后台模式启动

```bash
# 后台启动
./start.sh --background

# 或简写
./start.sh -b
```

**特点**:
- 进程在后台运行
- 日志保存到文件
- 可以关闭终端
- 适合生产环境

### 演示模式

```bash
# 运行演示模式（无需依赖）
./start.sh --demo

# 或直接运行
./start.sh -d
```

## 🛑 停止服务器

### 优雅停止

```bash
# 使用停止脚本
./stop.sh

# 或使用管理脚本
./manage.sh stop
```

**停止流程**:
1. 发送 SIGTERM 信号
2. 等待进程优雅退出 (最多10秒)
3. 如未退出则强制终止
4. 清理PID文件

### 强制停止

```bash
# 强制停止所有相关进程
./stop.sh --force

# 或使用管理脚本
./manage.sh stop force
```

### 使用管理菜单

```bash
./manage.sh menu
# 选择 [2] 停止服务器
```

## 📊 状态监控

### 基本状态检查

```bash
# 使用状态脚本
./status.sh

# 使用管理脚本
./manage.sh status
```

**显示信息**:
- 运行状态 (运行中/未运行)
- PID (如果运行中)
- 启动时间
- 资源使用情况

### 完整状态信息

```bash
# 查看完整状态
./status.sh --full

# 或
./status.sh -f
```

**详细信息**:
- 进程详情
- 系统资源使用
- 端口占用情况
- 日志文件信息
- 相关文件状态

### 性能监控

```bash
# 实时性能监控
./status.sh --performance

# 或
./status.sh -p
```

**监控内容**:
- CPU使用率
- 内存使用率
- 进程状态变化
- 实时日志更新

## 🔧 综合管理

### 交互式菜单

```bash
./manage.sh menu
```

提供菜单式操作界面，包括：
- 启动/停止/重启
- 状态查看
- 日志管理
- 性能测试
- 配置备份

### 命令行操作

```bash
# 启动服务器
./manage.sh start [foreground|background]

# 停止服务器
./manage.sh stop

# 重启服务器
./manage.sh restart [foreground|background]

# 查看日志
./manage.sh logs [行数]

# 查看进程信息
./manage.sh process

# 性能测试
./manage.sh test
```

## 🛠️ 系统服务集成

### 生成系统服务文件

```bash
./manage.sh service
```

生成的文件位置: `/tmp/mysql-mcp.service`

**安装步骤**:

1. **复制服务文件**:
```bash
sudo cp /tmp/mysql-mcp.service /etc/systemd/system/
```

2. **重新加载 systemd**:
```bash
sudo systemctl daemon-reload
```

3. **启用服务**:
```bash
sudo systemctl enable mysql-mcp
```

4. **启动服务**:
```bash
sudo systemctl start mysql-mcp
```

5. **查看状态**:
```bash
sudo systemctl status mysql-mcp
```

### 服务管理命令

```bash
# 启动服务
sudo systemctl start mysql-mcp

# 停止服务
sudo systemctl stop mysql-mcp

# 重启服务
sudo systemctl restart mysql-mcp

# 查看状态
sudo systemctl status mysql-mcp

# 查看日志
sudo journalctl -u mysql-mcp -f
```

## 📝 日志管理

### 查看日志

```bash
# 查看默认50行日志
./manage.sh logs

# 查看指定行数
./manage.sh logs 100

# 实时跟踪日志
tail -f mysql_mcp.log

# 使用状态脚本查看
./status.sh --logs
```

### 清理日志

```bash
# 通过管理脚本清理
./manage.sh clean

# 手动清空
> mysql_mcp.log

# 备份后清理
cp mysql_mcp.log mysql_mcp.log.backup
> mysql_mcp.log
```

### 日志轮转

创建 `/etc/logrotate.d/mysql-mcp`:

```bash
/Users/colin/Depots/projects/mcp/mysql/mysql_mcp.log {
    daily
    missingok
    rotate 7
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
}
```

## 📈 性能监控

### 基本性能检查

```bash
# 资源使用情况
./status.sh --system

# 进程详情
./manage.sh process

# 性能测试
./manage.sh test
```

### 详细性能监控

```bash
# 实时监控模式
./status.sh --performance
```

**监控指标**:
- CPU使用率变化
- 内存使用趋势
- 进程生命周期
- 实时日志输出

### 系统资源检查

```bash
# 系统负载
uptime

# 内存使用
free -h

# 磁盘使用
df -h

# 网络连接
netstat -tlnp | grep :3306
```

## 🔍 故障排除

### 常见问题

#### 1. 端口占用

```bash
# 检查端口占用
netstat -tlnp | grep :3306

# 或使用lsof
lsof -i :3306
```

#### 2. 进程僵死

```bash
# 查找僵死进程
ps aux | grep mysql_mcp

# 强制终止
./stop.sh --force
```

#### 3. 权限问题

```bash
# 检查文件权限
ls -la *.sh *.py

# 修复权限
chmod +x *.sh
```

#### 4. 依赖问题

```bash
# 检查Python依赖
python3 -c "import mysql.connector; print('OK')"

# 重新安装依赖
pip3 install mysql-connector-python pydantic
```

### 调试步骤

#### 1. 检查系统状态

```bash
# 运行完整诊断
./status.sh --full
```

#### 2. 查看错误日志

```bash
# 查看最近错误
./manage.sh logs 20 | grep -i error

# 实时跟踪错误
tail -f mysql_mcp.log | grep -i error
```

#### 3. 进程调试

```bash
# 前台启动查看详细输出
./start.sh --foreground

# 或使用strace跟踪
strace -p $(cat mysql_mcp.pid)
```

#### 4. 网络诊断

```bash
# 检查网络连接
netstat -tlnp

# 测试数据库连接
python3 test_connection.py
```

## 🔒 安全考虑

### 进程安全

1. **权限控制**: 使用专用用户运行服务
2. **资源限制**: 限制CPU和内存使用
3. **文件权限**: 保护配置文件和日志文件

### 系统服务配置示例

```ini
[Unit]
Description=MySQL MCP Server
After=network.target

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/Users/colin/Depots/projects/mcp/mysql
ExecStart=/usr/bin/python3 /Users/colin/Depots/projects/mcp/mysql/mysql_mcp_server.py
Restart=always
RestartSec=5
StandardOutput=append:/Users/colin/Depots/projects/mcp/mysql/mysql_mcp.log
StandardError=append:/Users/colin/Depots/projects/mcp/mysql/mysql_mcp.log

# 安全设置
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=/Users/colin/Depots/projects/mcp/mysql

[Install]
WantedBy=multi-user.target
```

## 📋 最佳实践

### 开发环境

```bash
# 前台运行，便于调试
./start.sh --foreground

# 或使用交互式菜单
./manage.sh menu
```

### 生产环境

```bash
# 后台运行
./start.sh --background

# 设置系统服务
./manage.sh service
sudo systemctl enable mysql-mcp
sudo systemctl start mysql-mcp
```

### 监控建议

1. **定期检查状态**: 使用 `./status.sh`
2. **日志轮转**: 配置logrotate
3. **资源监控**: 设置性能告警
4. **备份配置**: 使用 `./manage.sh backup`

### 维护计划

- **每日**: 检查服务状态和资源使用
- **每周**: 清理日志文件
- **每月**: 备份配置和性能评估
- **每季度**: 更新依赖和安全审查

---

**通过这些进程管理工具，您可以高效地管理MySQL MCP服务器的生命周期，确保服务的稳定运行！** 🎯
