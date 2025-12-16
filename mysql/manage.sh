#!/bin/bash

# MySQL MCP服务器综合管理脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/mysql_mcp.pid"
LOG_FILE="$SCRIPT_DIR/mysql_mcp.log"
SERVER_SCRIPT="$SCRIPT_DIR/mysql_mcp_server.py"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 显示横幅
show_banner() {
    echo -e "${PURPLE}🔧 MySQL MCP服务器管理器${NC}"
    echo "================================"
    echo ""
}

# 检查进程是否正在运行
is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# 获取当前状态
get_status() {
    if is_running; then
        local pid=$(cat "$PID_FILE")
        echo "running:$pid"
    else
        echo "stopped"
    fi
}

# 启动服务器
start_server() {
    local mode=${1:-foreground}
    
    if is_running; then
        local pid=$(cat "$PID_FILE")
        log_warning "MySQL MCP服务器已在运行中 (PID: $pid)"
        return 1
    fi
    
    log_info "启动MySQL MCP服务器 ($mode模式)..."
    
    case "$mode" in
        foreground)
            log_success "前台启动模式"
            exec python3 "$SERVER_SCRIPT"
            ;;
        background)
            log_success "后台启动模式"
            nohup python3 "$SERVER_SCRIPT" > "$LOG_FILE" 2>&1 &
            local pid=$!
            echo $pid > "$PID_FILE"
            
            sleep 2
            
            if ps -p "$pid" > /dev/null 2>&1; then
                log_success "服务器启动成功！PID: $pid"
                log_info "日志文件: $LOG_FILE"
                log_info "使用 '$0 stop' 停止服务器"
                return 0
            else
                log_error "服务器启动失败"
                rm -f "$PID_FILE"
                return 1
            fi
            ;;
        *)
            log_error "未知启动模式: $mode"
            return 1
            ;;
    esac
}

# 停止服务器
stop_server() {
    if ! is_running; then
        log_warning "MySQL MCP服务器未运行"
        return 0
    fi
    
    local pid=$(cat "$PID_FILE")
    log_info "停止MySQL MCP服务器 (PID: $pid)..."
    
    # 发送SIGTERM信号
    kill -TERM "$pid" 2>/dev/null
    
    # 等待进程退出
    local count=0
    local max_wait=10
    
    while [ $count -lt $max_wait ]; do
        if ! ps -p "$pid" > /dev/null 2>&1; then
            log_success "服务器已优雅退出"
            rm -f "$PID_FILE"
            return 0
        fi
        sleep 1
        count=$((count + 1))
        echo -n "."
    done
    
    # 强制终止
    log_warning "强制终止进程..."
    kill -KILL "$pid" 2>/dev/null
    sleep 1
    
    if ! ps -p "$pid" > /dev/null 2>&1; then
        log_success "服务器已强制终止"
        rm -f "$PID_FILE"
        return 0
    else
        log_error "无法终止进程 $pid"
        return 1
    fi
}

# 重启服务器
restart_server() {
    local mode=${1:-background}
    
    log_info "重启MySQL MCP服务器..."
    
    if is_running; then
        stop_server
        sleep 2
    fi
    
    start_server "$mode"
}

# 查看状态
show_status() {
    show_banner
    
    if is_running; then
        local pid=$(cat "$PID_FILE")
        local start_time=$(ps -o lstart= -p "$pid")
        local cpu=$(ps -o %cpu= -p "$pid" 2>/dev/null | tr -d ' ')
        local mem=$(ps -o %mem= -p "$pid" 2>/dev/null | tr -d ' ')
        
        echo -e "${GREEN}🟢 状态: 运行中${NC}"
        echo "PID: $pid"
        echo "启动时间: $start_time"
        echo "CPU使用率: ${cpu:-N/A}%"
        echo "内存使用率: ${mem:-N/A}%"
        echo "日志文件: $LOG_FILE"
        
        # 显示最近的日志
        if [ -f "$LOG_FILE" ]; then
            echo ""
            echo "最近的日志:"
            tail -n 5 "$LOG_FILE" | while read line; do
                echo "  $line"
            done
        fi
    else
        echo -e "${RED}🔴 状态: 未运行${NC}"
        echo "PID文件: $PID_FILE (不存在)"
    fi
}

# 查看日志
show_logs() {
    local lines=${1:-50}
    
    if [ -f "$LOG_FILE" ]; then
        log_info "显示最近的 $lines 行日志:"
        echo ""
        tail -n "$lines" "$LOG_FILE"
    else
        log_warning "日志文件不存在: $LOG_FILE"
    fi
}

# 清理日志
clean_logs() {
    if [ -f "$LOG_FILE" ]; then
        echo "当前日志文件大小: $(du -h "$LOG_FILE" | cut -f1)"
        echo ""
        read -p "确定要清空日志文件吗？(y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            > "$LOG_FILE"
            log_success "日志文件已清空"
        else
            log_info "取消清理操作"
        fi
    else
        log_info "日志文件不存在，无需清理"
    fi
}

# 查看进程信息
show_process_info() {
    if is_running; then
        local pid=$(cat "$PID_FILE")
        echo "进程详细信息 (PID: $pid):"
        echo "================================"
        ps -f -p "$pid"
        echo ""
        
        # 网络连接信息
        echo "网络连接:"
        netstat -p 2>/dev/null | grep "$pid" || echo "  无网络连接信息"
    else
        log_warning "服务器未运行"
    fi
}

# 性能测试
performance_test() {
    if ! is_running; then
        log_error "服务器未运行，无法进行性能测试"
        return 1
    fi
    
    log_info "开始性能测试..."
    
    # 检查系统资源
    local pid=$(cat "$PID_FILE")
    local cpu_before=$(ps -o %cpu= -p "$pid" 2>/dev/null | tr -d ' ')
    local mem_before=$(ps -o %mem= -p "$pid" 2>/dev/null | tr -d ' ')
    
    echo "测试前资源使用:"
    echo "  CPU: ${cpu_before:-N/A}%"
    echo "  内存: ${mem_before:-N/A}%"
    
    # 模拟一些操作
    sleep 5
    
    local cpu_after=$(ps -o %cpu= -p "$pid" 2>/dev/null | tr -d ' ')
    local mem_after=$(ps -o %mem= -p "$pid" 2>/dev/null | tr -d ' ')
    
    echo ""
    echo "测试后资源使用:"
    echo "  CPU: ${cpu_after:-N/A}%"
    echo "  内存: ${mem_after:-N/A}%"
    
    log_success "性能测试完成"
}

# 生成系统服务文件
generate_service_file() {
    local service_file="/tmp/mysql-mcp.service"
    
    cat > "$service_file" << EOF
[Unit]
Description=MySQL MCP Server
After=network.target

[Service]
Type=simple
User=www-data
WorkingDirectory=$SCRIPT_DIR
ExecStart=/usr/bin/python3 $SERVER_SCRIPT
Restart=always
RestartSec=5
StandardOutput=append:$LOG_FILE
StandardError=append:$LOG_FILE

[Install]
WantedBy=multi-user.target
EOF

    log_success "系统服务文件已生成: $service_file"
    echo ""
    echo "安装说明:"
    echo "1. 复制文件到系统目录:"
    echo "   sudo cp $service_file /etc/systemd/system/"
    echo ""
    echo "2. 重新加载 systemd:"
    echo "   sudo systemctl daemon-reload"
    echo ""
    echo "3. 启用服务:"
    echo "   sudo systemctl enable mysql-mcp"
    echo ""
    echo "4. 启动服务:"
    echo "   sudo systemctl start mysql-mcp"
    echo ""
    echo "5. 查看状态:"
    echo "   sudo systemctl status mysql-mcp"
}

# 备份配置
backup_config() {
    local backup_dir="$SCRIPT_DIR/backups"
    local backup_file="$backup_dir/mysql_mcp_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    mkdir -p "$backup_dir"
    
    tar -czf "$backup_file" \
        --exclude="$backup_dir" \
        --exclude="$PID_FILE" \
        --exclude="$LOG_FILE" \
        "$SCRIPT_DIR"
    
    log_success "配置已备份到: $backup_file"
    
    # 保留最近5个备份
    ls -t "$backup_dir"/mysql_mcp_backup_*.tar.gz 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null
    
    echo "备份目录: $backup_dir"
}

# 显示菜单
show_menu() {
    show_banner
    
    local status_info=$(get_status)
    
    echo "当前状态: $(echo $status_info | cut -d: -f1)"
    echo ""
    echo "可用操作:"
    echo ""
    
    if [[ $status_info == running:* ]]; then
        local pid=$(echo $status_info | cut -d: -f2)
        echo "  🟢 服务器正在运行 (PID: $pid)"
        echo ""
        echo "  [1] 查看状态"
        echo "  [2] 停止服务器"
        echo "  [3] 重启服务器"
        echo "  [4] 查看日志"
        echo "  [5] 进程信息"
        echo "  [6] 性能测试"
    else
        echo "  🔴 服务器未运行"
        echo ""
        echo "  [1] 前台启动"
        echo "  [2] 后台启动"
        echo "  [3] 运行演示"
        echo "  [4] 查看日志"
    fi
    
    echo ""
    echo "  [7] 清理日志"
    echo "  [8] 备份配置"
    echo "  [9] 生成系统服务"
    echo "  [0] 退出"
    echo ""
    read -p "请选择操作 [0-9]: " choice
    
    case $choice in
        0)
            log_info "退出管理器"
            exit 0
            ;;
        1)
            if [[ $status_info == running:* ]]; then
                show_status
            else
                start_server foreground
            fi
            ;;
        2)
            if [[ $status_info == running:* ]]; then
                stop_server
            else
                start_server background
            fi
            ;;
        3)
            if [[ $status_info == running:* ]]; then
                restart_server background
            else
                "$SCRIPT_DIR/demo.py"
            fi
            ;;
        4)
            show_logs 50
            ;;
        5)
            show_process_info
            ;;
        6)
            performance_test
            ;;
        7)
            clean_logs
            ;;
        8)
            backup_config
            ;;
        9)
            generate_service_file
            ;;
        *)
            log_error "无效选择: $choice"
            ;;
    esac
    
    echo ""
    read -p "按回车键继续..."
    
    # 递归调用显示菜单
    show_menu
}

# 显示帮助信息
show_help() {
    echo "MySQL MCP服务器综合管理脚本"
    echo ""
    echo "用法:"
    echo "  $0 [命令] [选项]"
    echo ""
    echo "命令:"
    echo "  start [mode]     启动服务器 (mode: foreground|background)"
    echo "  stop            停止服务器"
    echo "  restart [mode]  重启服务器 (mode: foreground|background)"
    echo "  status          显示状态"
    echo "  logs [lines]    查看日志 (默认50行)"
    echo "  process         显示进程信息"
    echo "  test            性能测试"
    echo "  clean           清理日志"
    echo "  backup          备份配置"
    echo "  service         生成系统服务文件"
    echo "  menu            交互式菜单"
    echo "  help            显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0 start background    # 后台启动"
    echo "  $0 restart foreground  # 前台重启"
    echo "  $0 logs 100            # 查看100行日志"
    echo "  $0 menu                # 交互式菜单"
}

# 主函数
main() {
    case "${1:-menu}" in
        start)
            start_server "${2:-foreground}"
            ;;
        stop)
            stop_server
            ;;
        restart)
            restart_server "${2:-background}"
            ;;
        status)
            show_status
            ;;
        logs)
            show_logs "${2:-50}"
            ;;
        process)
            show_process_info
            ;;
        test)
            performance_test
            ;;
        clean)
            clean_logs
            ;;
        backup)
            backup_config
            ;;
        service)
            generate_service_file
            ;;
        menu)
            show_menu
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
