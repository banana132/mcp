#!/bin/bash

# MySQL MCP服务器停止脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/mysql_mcp.pid"
LOG_FILE="$SCRIPT_DIR/mysql_mcp.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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
    echo "🛑 MySQL MCP服务器停止脚本"
    echo ""
}

# 检查进程是否正在运行
is_running() {
    if [ -f "$PID_FILE" ]; then
        local pid=$(cat "$PID_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            return 0
        else
            # PID文件存在但进程不存在，清理PID文件
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# 优雅停止进程
graceful_stop() {
    local pid=$1
    
    if [ -z "$pid" ]; then
        return 1
    fi
    
    log_info "发送SIGTERM信号到进程 $pid..."
    kill -TERM "$pid" 2>/dev/null
    
    # 等待进程退出
    local count=0
    local max_wait=10
    
    while [ $count -lt $max_wait ]; do
        if ! ps -p "$pid" > /dev/null 2>&1; then
            log_success "进程已优雅退出"
            return 0
        fi
        sleep 1
        count=$((count + 1))
        echo -n "."
    done
    
    # 如果进程仍然运行，强制杀死
    log_warning "进程未在合理时间内退出，发送SIGKILL信号..."
    kill -KILL "$pid" 2>/dev/null
    
    sleep 1
    
    if ! ps -p "$pid" > /dev/null 2>&1; then
        log_success "进程已强制终止"
        return 0
    else
        log_error "无法终止进程 $pid"
        return 1
    fi
}

# 停止服务器
stop_server() {
    show_banner
    
    if ! is_running; then
        log_warning "MySQL MCP服务器未运行"
        return 0
    fi
    
    local pid=$(cat "$PID_FILE")
    log_info "发现运行中的MySQL MCP服务器 (PID: $pid)"
    echo ""
    
    # 确认停止
    read -p "确定要停止MySQL MCP服务器吗？(y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "取消停止操作"
        return 0
    fi
    
    echo ""
    log_info "正在停止MySQL MCP服务器..."
    
    if graceful_stop "$pid"; then
        # 清理PID文件
        rm -f "$PID_FILE"
        log_success "MySQL MCP服务器已成功停止"
        
        # 显示最近的日志
        if [ -f "$LOG_FILE" ]; then
            echo ""
            log_info "最近的日志记录:"
            tail -n 10 "$LOG_FILE" | while read line; do
                echo "  $line"
            done
        fi
        
        return 0
    else
        log_error "停止MySQL MCP服务器失败"
        return 1
    fi
}

# 强制停止所有相关进程
force_stop_all() {
    show_banner
    
    log_warning "强制停止所有MySQL MCP相关进程..."
    
    # 查找所有Python进程运行mysql_mcp_server.py
    local pids=$(pgrep -f "mysql_mcp_server.py")
    
    if [ -z "$pids" ]; then
        log_info "没有找到运行中的MySQL MCP服务器进程"
        return 0
    fi
    
    echo "找到以下进程:"
    echo "$pids" | while read pid; do
        local cmd=$(ps -o cmd= -p "$pid")
        echo "  PID: $pid, CMD: $cmd"
    done
    
    echo ""
    read -p "确定要强制停止这些进程吗？(y/N): " -n 1 -r
    echo ""
    
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "取消强制停止操作"
        return 0
    fi
    
    echo ""
    log_info "正在强制停止进程..."
    
    # 强制终止所有找到的进程
    for pid in $pids; do
        log_info "停止进程 $pid..."
        kill -KILL "$pid" 2>/dev/null
        if ! ps -p "$pid" > /dev/null 2>&1; then
            log_success "进程 $pid 已终止"
        else
            log_error "无法终止进程 $pid"
        fi
    done
    
    # 清理PID文件
    rm -f "$PID_FILE"
    
    log_success "强制停止操作完成"
}

# 显示帮助信息
show_help() {
    echo "MySQL MCP服务器停止脚本"
    echo ""
    echo "用法:"
    echo "  $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -g, --graceful     优雅停止 (默认)"
    echo "  -f, --force        强制停止所有相关进程"
    echo "  -h, --help         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                 # 优雅停止"
    echo "  $0 -g              # 优雅停止"
    echo "  $0 -f              # 强制停止"
}

# 显示状态
show_status() {
    show_banner
    
    if is_running; then
        local pid=$(cat "$PID_FILE")
        local start_time=$(ps -o lstart= -p "$pid")
        echo "状态: 🟢 运行中"
        echo "PID: $pid"
        echo "启动时间: $start_time"
        echo "日志文件: $LOG_FILE"
        
        if [ -f "$LOG_FILE" ]; then
            echo ""
            echo "最近的日志:"
            tail -n 5 "$LOG_FILE" | while read line; do
                echo "  $line"
            done
        fi
        
        echo ""
        echo "使用以下命令停止服务器:"
        echo "  $0           # 优雅停止"
        echo "  $0 --force   # 强制停止"
    else
        echo "状态: 🔴 未运行"
        echo "PID文件: $PID_FILE (不存在)"
    fi
}

# 主函数
main() {
    # 解析命令行参数
    case "${1:-}" in
        -g|--graceful)
            stop_server
            ;;
        -f|--force)
            force_stop_all
            ;;
        -s|--status)
            show_status
            ;;
        -h|--help)
            show_help
            ;;
        "")
            # 默认优雅停止
            stop_server
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
}

# 执行主函数
main "$@"
