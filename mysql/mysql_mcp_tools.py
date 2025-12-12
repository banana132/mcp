"""
MySQL MCP工具定义
"""

import mcp.types as types
from mysql_mcp_server import server

# 定义工具
TOOLS = [
    types.Tool(
        name="connect_database",
        description="连接MySQL数据库。显示开发环境安全警告。",
        inputSchema={
            "type": "object",
            "properties": {
                "host": {
                    "type": "string",
                    "description": "MySQL服务器地址"
                },
                "port": {
                    "type": "integer",
                    "description": "MySQL端口号，默认3306",
                    "default": 3306
                },
                "database": {
                    "type": "string",
                    "description": "数据库名称"
                },
                "username": {
                    "type": "string",
                    "description": "用户名"
                },
                "password": {
                    "type": "string",
                    "description": "密码"
                },
                "charset": {
                    "type": "string",
                    "description": "字符集，默认utf8mb4",
                    "default": "utf8mb4"
                }
            },
            "required": ["host", "database", "username", "password"]
        }
    ),
    types.Tool(
        name="execute_query",
        description="执行SELECT查询。只能执行查询语句，用于读取数据。",
        inputSchema={
            "type": "object",
            "properties": {
                "query": {
                    "type": "string",
                    "description": "SELECT查询语句"
                },
                "max_rows": {
                    "type": "integer",
                    "description": "最大返回行数，默认1000",
                    "default": 1000
                }
            },
            "required": ["query"]
        }
    ),
    types.Tool(
        name="describe_table",
        description="获取指定表的结构信息",
        inputSchema={
            "type": "object",
            "properties": {
                "table_name": {
                    "type": "string",
                    "description": "表名"
                }
            },
            "required": ["table_name"]
        }
    ),
    types.Tool(
        name="show_tables",
        description="显示当前数据库中的所有表",
        inputSchema={
            "type": "object",
            "properties": {},
            "required": []
        }
    ),
    types.Tool(
        name="execute_write_operation",
        description="执行写操作（INSERT、UPDATE、DELETE、CREATE、ALTER、DROP）。需要用户确认！",
        inputSchema={
            "type": "object",
            "properties": {
                "sql": {
                    "type": "string",
                    "description": "写操作SQL语句"
                }
            },
            "required": ["sql"]
        }
    ),
    types.Tool(
        name="confirmed_write_operation",
        description="确认执行写操作。只有在用户明确确认后才能执行。",
        inputSchema={
            "type": "object",
            "properties": {
                "sql": {
                    "type": "string",
                    "description": "确认要执行的写操作SQL语句"
                }
            },
            "required": ["sql"]
        }
    ),
    types.Tool(
        name="get_database_info",
        description="获取当前数据库的基本信息和统计信息",
        inputSchema={
            "type": "object",
            "properties": {},
            "required": []
        }
    )
]
