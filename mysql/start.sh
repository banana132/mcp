#!/bin/bash

# MySQL MCP服务器快速启动脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/mysql_mcp.pid"
LOG_FILE="$SCRIPT_DIR/mysql_mcp.log"
SERVER_SCRIPT="$SCRIPT_DIR/mysql_mcp_server.py"
DEMO_SCRIPT="$SCRIPT_DIR/demo.py"

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
    echo "🚀 MySQL MCP服务器启动脚本"
    echo "⚠️  此工具仅应在开发环境中使用！"
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

# 启动前台模式
start_foreground() {
    log_info "启动前台模式..."
    
    if is_running; then
        log_warning "服务器已在运行中 (PID: $(cat $PID_FILE))"
        return 1
    fi
    
    # 检查依赖
    if ! check_dependencies; then
        exit 1
    fi
    
    log_success "启动MCP服务器 (前台模式)..."
    python3 "$SERVER_SCRIPT"
}

# 启动后台模式
start_background() {
    log_info "启动后台模式..."
    
    if is_running; then
        log_warning "服务器已在运行中 (PID: $(cat $PID_FILE))"
        return 1
    fi
    
    # 检查依赖
    if ! check_dependencies; then
        exit 1
    fi
    
    log_success "启动MCP服务器 (后台模式)..."
    
    # 后台启动服务器
    nohup python3 "$SERVER_SCRIPT" > "$LOG_FILE" 2>&1 &
    local pid=$!
    
    # 保存PID
    echo $pid > "$PID_FILE"
    
    # 等待一下确保进程启动成功
    sleep 2
    
    if ps -p "$pid" > /dev/null 2>&1; then
        log_success "服务器已启动成功！"
        log_info "PID: $pid"
        log_info "日志文件: $LOG_FILE"
        log_info "使用 ./stop.sh 停止服务器"
        return 0
    else
        log_error "服务器启动失败"
        rm -f "$PID_FILE"
        return 1
    fi
}

# 检查依赖
check_dependencies() {
    log_info "检查依赖包..."
    missing_deps=()
    
    # 检查mysql.connector
    if ! python3 -c "import mysql.connector" &> /dev/null; then
        missing_deps+=("mysql.connector-python")
    fi
    
    # 检查pydantic
    if ! python3 -c "import pydantic" &> /dev/null; then
        missing_deps+=("pydantic")
    fi
    
    # 如果有缺失的依赖
    if [ ${#missing_deps[@]} -gt 0 ]; then
        log_error "缺少依赖包：${missing_deps[*]}"
        echo ""
        echo "🔧 安装方法："
        echo "   pip3 install mysql-connector-python pydantic"
        echo ""
        echo "🆘 或者运行演示模式（无需依赖）："
        echo "   python3 demo.py"
        echo ""
        echo "💡 演示模式展示了所有功能的工作原理，但不连接真实数据库"
        echo ""
        read -p "是否现在安装依赖？(y/N): " -n 1 -r
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_info "安装依赖包..."
            if pip3 install mysql-connector-python pydantic; then
                log_success "依赖安装成功"
            else
                log_error "依赖安装失败"
                return 1
            fi
        else
            echo ""
            read -p "是否运行演示模式？(y/N): " -n 1 -r
            echo ""
            
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                if [ -f "$DEMO_SCRIPT" ]; then
                    log_info "启动演示模式..."
                    python3 "$DEMO_SCRIPT"
                    return 1
                else
                    log_error "找不到演示文件"
                    return 1
                fi
            else
                log_error "请安装依赖后再运行，或选择运行演示模式"
                return 1
            fi
        fi
    fi
    
    log_success "所有依赖已安装"
    return 0
}

# 显示帮助信息
show_help() {
    echo "MySQL MCP服务器启动脚本"
    echo ""
    echo "用法:"
    echo "  $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -f, --foreground    前台模式启动 (默认)"
    echo "  -b, --background    后台模式启动"
    echo "  -d, --demo         运行演示模式"
    echo "  -s, --status       查看运行状态"
    echo "  -h, --help         显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                 # 前台启动"
    echo "  $0 -b              # 后台启动"
    echo "  $0 -d              # 运行演示"
    echo "  $0 -s              # 查看状态"
}

# 显示状态
show_status() {
    echo "MySQL MCP服务器状态检查"
    echo "========================"
    
    if is_running; then
        local pid=$(cat "$PID_FILE")
        echo "状态: 🟢 运行中"
        echo "PID: $pid"
        echo "启动时间: $(ps -o lstart= -p $pid)"
        echo "日志文件: $LOG_FILE"
        
        # 显示最后几行日志
        if [ -f "$LOG_FILE" ]; then
            echo ""
            echo "最近的日志:"
            tail -n 5 "$LOG_FILE"
        fi
    else
        echo "状态: 🔴 未运行"
    fi
}

# 主函数
main() {
    show_banner
    
    # 检查Python
    if ! command -v python3 &> /dev/null; then
        log_error "未找到Python3。请先安装Python3。"
        exit 1
    fi
    
    log_success "Python3 已安装"
    
    # 检查服务器文件
    if [ ! -f "$SERVER_SCRIPT" ]; then
        log_error "找不到服务器文件: $SERVER_SCRIPT"
        exit 1
    fi
    
    # 解析命令行参数
    case "${1:-}" in
        -f|--foreground)
            start_foreground
            ;;
        -b|--background)
            start_background
            ;;
        -d|--demo)
            if [ -f "$DEMO_SCRIPT" ]; then
                python3 "$DEMO_SCRIPT"
            else
                log_error "找不到演示文件"
                exit 1
            fi
            ;;
        -s|--status)
            show_status
            ;;
        -h|--help)
            show_help
            ;;
        "")
            # 默认前台模式
            start_foreground
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
