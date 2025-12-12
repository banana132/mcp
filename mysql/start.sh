#!/bin/bash

# MySQL MCP服务器快速启动脚本

echo "🚀 启动 MySQL MCP服务器..."
echo "⚠️  此工具仅应在开发环境中使用！"
echo ""

# 检查Python是否安装
if ! command -v python3 &> /dev/null; then
    echo "❌ 错误：未找到Python3。请先安装Python3。"
    exit 1
fi

echo "✅ Python3 已安装"

# 检查服务器文件是否存在
if [ ! -f "mysql_mcp_server.py" ]; then
    echo "❌ 错误：找不到 mysql_mcp_server.py 文件"
    exit 1
fi

# 检查依赖是否安装
echo "📦 检查依赖包..."
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
    echo "❌ 缺少依赖包：${missing_deps[*]}"
    echo ""
    echo "🔧 安装方法："
    echo "   pip3 install mysql-connector-python pydantic"
    echo ""
    echo "🆘 或者运行演示模式（无需依赖）："
    echo "   python3 demo.py"
    echo ""
    echo "💡 演示模式展示了所有功能的工作原理，但不连接真实数据库"
    
    # 询问是否运行演示模式
    echo ""
    read -p "是否运行演示模式？(y/N): " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "demo.py" ]; then
            echo "🟢 启动演示模式..."
            python3 demo.py
        else
            echo "❌ 找不到 demo.py 文件"
            exit 1
        fi
    else
        echo "请安装依赖后再运行，或选择运行演示模式。"
        exit 1
    fi
else
    echo "✅ 所有依赖已安装"
    echo "🟢 启动MCP服务器..."
    python3 mysql_mcp_server.py
fi
