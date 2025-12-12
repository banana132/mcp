"""
MySQL MCP服务器配置示例文件
复制此文件为 config.py 并根据实际情况修改配置
"""

# MySQL连接配置
MYSQL_CONFIG = {
    'host': 'localhost',          # MySQL服务器地址
    'port': 3306,                 # 端口号
    'database': 'your_database',  # 数据库名称
    'username': 'your_username',  # 用户名
    'password': 'your_password',  # 密码
    'charset': 'utf8mb4',         # 字符集
    'use_ssl': False,             # 是否使用SSL
}

# 服务器配置
SERVER_CONFIG = {
    'max_query_rows': 1000,       # 最大查询返回行数
    'query_timeout': 30,          # 查询超时时间（秒）
    'connection_pool_size': 5,    # 连接池大小
}

# 安全配置
SECURITY_CONFIG = {
    'require_confirmation': True,  # 写操作是否需要确认
    'allowed_operations': [        # 允许的写操作类型
        'INSERT', 'UPDATE', 'DELETE', 
        'CREATE', 'ALTER', 'DROP', 'TRUNCATE'
    ],
    'max_sql_length': 10000,      # 最大SQL语句长度
}

# 日志配置
LOGGING_CONFIG = {
    'level': 'INFO',
    'format': '%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    'file': 'mysql_mcp_server.log',
}

# 注意：生产环境中请使用环境变量或安全的配置管理方式
# 不要将包含真实密码的配置提交到版本控制系统
