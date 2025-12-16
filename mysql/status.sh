#!/bin/bash

# MySQL MCP服务器状态检查脚本

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PID_FILE="$SCRIPT_DIR/mysql_mcp.pid"
LOG_FILE="$SCRIPT_DIR/mysql_mcp.log"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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
    echo "📊 MySQL MCP服务器状态监控"
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
            # PID文件存在但进程不存在，清理PID文件
            rm -f "$PID_FILE"
            return 1
        fi
    fi
    return 1
}

# 获取详细进程信息
get_process_info() {
    local pid=$1
    
    if [ -z "$pid" ]; then
        return 1
    fi
    
    # 获取进程信息
    local pid_info=$(ps -o pid,ppid,user,start,etime,pcpu,pmem,cmd= -p "$pid" 2>/dev/null)
    
    if [ -n "$pid_info" ]; then
        echo "$pid_info"
        return 0
    else
        return 1
    fi
}

# 检查系统资源使用
check_system_resources() {
    local pid=$1
    
    echo "💻 系统资源使用情况:"
    echo "----------------------------------------"
    
    if [ -n "$pid" ]; then
        # 获取特定进程的CPU和内存使用情况
        local cpu=$(ps -o %cpu= -p "$pid" 2>/dev/null | tr -d ' ')
        local mem=$(ps -o %mem= -p "$pid" 2>/dev/null | tr -d ' ')
        
        echo "  CPU使用率: ${cpu:-N/A}%"
        echo "  内存使用率: ${mem:-N/A}%"
        
        # 获取进程的工作目录
        local cwd=$(lsof -p "$pid" 2>/dev/null | grep cwd | head -1 | awk '{print $9}')
        if [ -n "$cwd" ]; then
            echo "  工作目录: $cwd"
        fi
    fi
    
    # 系统整体信息
    local load_avg=$(uptime | awk -F'load average:' '{print $2}')
    local total_mem=$(free -h | grep '^Mem:' | awk '{print $2}')
    local used_mem=$(free -h | grep '^Mem:' | awk '{print $3}')
    
    echo "  系统负载: $load_avg"
    echo "  内存使用: $used_mem / $total_mem"
    echo ""
}

# 检查端口占用
check_port_usage() {
    echo "🌐 网络端口使用情况:"
    echo "----------------------------------------"
    
    # MySQL默认端口3306
    local mysql_port=$(netstat -tlnp 2>/dev/null | grep ":3306 " || echo "")
    
    if [ -n "$mysql_port" ]; then
        echo "  MySQL端口 (3306): 🟢 已占用"
        echo "    $mysql_port"
    else
        echo "  MySQL端口 (3306): 🔴 未占用"
    fi
    
    # 检查其他相关端口
    local other_ports=$(netstat -tlnp 2>/dev/null | grep -E ":(8000|8080|3000)" || echo "")
    
    if [ -n "$other_ports" ]; then
        echo "  其他开发端口:"
        echo "$other_ports" | while read line; do
            echo "    $line"
        done
    fi
    
    echo ""
}

# 检查日志文件
check_log_files() {
    echo "📝 日志文件检查:"
    echo "----------------------------------------"
    
    if [ -f "$LOG_FILE" ]; then
        local log_size=$(du -h "$LOG_FILE" | cut -f1)
        local log_lines=$(wc -l < "$LOG_FILE")
        local log_modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$LOG_FILE" 2>/dev/null || stat -c "%y" "$LOG_FILE" 2>/dev/null | cut -d' ' -f1-2)
        
        echo "  主日志文件: $LOG_FILE"
        echo "    大小: $log_size"
        echo "    行数: $log_lines"
        echo "    修改时间: $log_modified"
        
        # 显示最近的日志条目
        echo ""
        echo "  最近的日志 (最后5行):"
        tail -n 5 "$LOG_FILE" | while read line; do
            echo "    $line"
        done
    else
        echo "  主日志文件: $LOG_FILE (不存在)"
    fi
    
    echo ""
}

# 检查相关文件
check_related_files() {
    echo "📁 相关文件检查:"
    echo "----------------------------------------"
    
    local files=(
        "$SCRIPT_DIR/mysql_mcp_server.py"
        "$SCRIPT_DIR/demo.py"
        "$SCRIPT_DIR/start.sh"
        "$SCRIPT_DIR/stop.sh"
        "$SCRIPT_DIR/requirements.txt"
    )
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            local size=$(du -h "$file" | cut -f1)
            local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M:%S" "$file" 2>/dev/null || stat -c "%y" "$file" 2>/dev/null | cut -d' ' -f1-2)
            echo "  ✅ $(basename "$file"): $size (修改时间: $modified)"
        else
            echo "  ❌ $(basename "$file"): 文件不存在"
        fi
    done
    
    echo ""
}

# 性能监控
performance_monitor() {
    if ! is_running; then
        log_warning "服务器未运行，无法进行性能监控"
        return 1
    fi
    
    local pid=$(cat "$PID_FILE")
    
    echo "📈 性能监控 (实时更新，按Ctrl+C退出):"
    echo "----------------------------------------"
    
    # 设置一个循环来显示实时性能数据
    local count=0
    local max_iterations=5
    
    while [ $count -lt $max_iterations ]; do
        clear
        echo "📈 MySQL MCP服务器性能监控"
        echo "============================="
        echo "更新时间: $(date)"
        echo ""
        
        # 进程信息
        if get_process_info "$pid"; then
            echo ""
        fi
        
        # CPU和内存使用情况
        echo "资源使用:"
        local cpu=$(ps -o %cpu= -p "$pid" 2>/dev/null | tr -d ' ')
        local mem=$(ps -o %mem= -p "$pid" 2>/dev/null | tr -d ' ')
        local vsz=$(ps -o vsz= -p "$pid" 2>/dev/null | tr -d ' ')
        local rss=$(ps -o rss= -p "$pid" 2>/dev/null | tr -d ' ')
        
        echo "  CPU使用率: ${cpu:-N/A}%"
        echo "  内存使用率: ${mem:-N/A}%"
        echo "  虚拟内存: ${vsz:-N/A} KB"
        echo "  物理内存: ${rss:-N/A} KB"
        
        echo ""
        echo "最近日志 (最后3行):"
        if [ -f "$LOG_FILE" ]; then
            tail -n 3 "$LOG_FILE" | while read line; do
                echo "  $line"
            done
        fi
        
        count=$((count + 1))
        
        if [ $count -lt $max_iterations ]; then
            echo ""
            echo "下次更新倒计时: 3..."
            sleep 1
            echo "下次更新倒计时: 2..."
            sleep 1
            echo "下次更新倒计时: 1..."
            sleep 1
        fi
    done
    
    echo ""
    log_info "性能监控完成"
}

# 显示完整状态
show_full_status() {
    show_banner
    
    echo "🎯 总体状态:"
    echo "----------------------------------------"
    
    if is_running; then
        local pid=$(cat "$PID_FILE")
        echo "状态: 🟢 运行中"
        echo "PID: $pid"
        
        if get_process_info "$pid"; then
            echo ""
        fi
    else
        echo "状态: 🔴 未运行"
        echo "PID文件: $PID_FILE (不存在)"
    fi
    
    echo ""
    
    # 系统资源
    if [ -f "$PID_FILE" ]; then
        check_system_resources $(cat "$PID_FILE")
    else
        check_system_resources
    fi
    
    # 端口使用
    check_port_usage
    
    # 日志文件
    check_log_files
    
    # 相关文件
    check_related_files
    
    # 连接建议
    echo "💡 操作建议:"
    echo "----------------------------------------"
    if is_running; then
        echo "  服务器正在运行，您可以在Cursor中配置MCP服务器"
        echo "  使用以下命令管理服务器:"
        echo "    ./stop.sh           # 停止服务器"
        echo "    ./status.sh -p      # 性能监控"
    else
        echo "  服务器未运行，使用以下命令启动:"
        echo "    ./start.sh          # 前台启动"
        echo "    ./start.sh -b       # 后台启动"
        echo "    ./start.sh -d       # 运行演示"
    fi
    
    echo ""
}

# 显示帮助信息
show_help() {
    echo "MySQL MCP服务器状态检查脚本"
    echo ""
    echo "用法:"
    echo "  $0 [选项]"
    echo ""
    echo "选项:"
    echo "  -f, --full        显示完整状态信息"
    echo "  -p, --performance 性能监控模式"
    echo "  -l, --logs        仅显示日志信息"
    echo "  -s, --system      仅显示系统信息"
    echo "  -h, --help        显示此帮助信息"
    echo ""
    echo "示例:"
    echo "  $0                # 基本状态检查"
    echo "  $0 -f             # 完整状态信息"
    echo "  $0 -p             # 性能监控"
    echo "  $0 -l             # 仅查看日志"
}

# 主函数
main() {
    # 解析命令行参数
    case "${1:-}" in
        -f|--full)
            show_full_status
            ;;
        -p|--performance)
            performance_monitor
            ;;
        -l|--logs)
            show_banner
            check_log_files
            ;;
        -s|--system)
            show_banner
            if [ -f "$PID_FILE" ]; then
                check_system_resources $(cat "$PID_FILE")
            else
                check_system_resources
            fi
            check_port_usage
            ;;
        -h|--help)
            show_help
            ;;
        "")
            # 默认基本状态
            show_banner
            
            if is_running; then
                local pid=$(cat "$PID_FILE")
                log_success "MySQL MCP服务器正在运行"
                echo "PID: $pid"
                
                local start_time=$(ps -o lstart= -p "$pid")
                echo "启动时间: $start_time"
                echo ""
                
                echo "💡 提示:"
                echo "  - 使用 ./status.sh -f 查看完整状态"
                echo "  - 使用 ./status.sh -p 查看性能监控"
                echo "  - 使用 ./stop.sh 停止服务器"
            else
                log_warning "MySQL MCP服务器未运行"
                echo ""
                echo "💡 提示:"
                echo "  - 使用 ./start.sh 启动服务器"
                echo "  - 使用 ./start.sh -b 后台启动"
                echo "  - 使用 ./start.sh -d 运行演示"
            fi
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
