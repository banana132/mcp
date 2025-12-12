#!/usr/bin/env python3
"""
MySQL MCP服务器 - 开发环境专用
警告：此工具仅应在开发环境中使用，不应在生产环境使用
"""

import os
import json
import logging
from typing import Any, Dict, List, Optional, Union
from contextlib import contextmanager
import mysql.connector
from mysql.connector import Error
from pydantic import BaseModel

# 配置日志
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("mysql-mcp-server")


class DatabaseConfig(BaseModel):
    """数据库配置模型"""
    host: str
    port: int = 3306
    database: str
    username: str
    password: str
    charset: str = "utf8mb4"
    use_ssl: bool = False


class MySQLConnectionManager:
    """MySQL连接管理器"""
    
    def __init__(self):
        self.connection: Optional[mysql.connector.MySQLConnection] = None
        self.config: Optional[DatabaseConfig] = None
    
    @contextmanager
    def get_connection(self, config: DatabaseConfig):
        """获取数据库连接的上下文管理器"""
        self.config = config
        try:
            self.connection = mysql.connector.connect(
                host=config.host,
                port=config.port,
                database=config.database,
                user=config.username,
                password=config.password,
                charset=config.charset,
                use_pure=True,  # 使用纯Python实现
                ssl_disabled=not config.use_ssl
            )
            yield self.connection
        except Error as e:
            logger.error(f"MySQL连接错误: {e}")
            raise
        finally:
            if self.connection and self.connection.is_connected():
                self.connection.close()


class MySQLMCPServer:
    """MySQL MCP服务器主类"""
    
    def __init__(self):
        self.connection_manager = MySQLConnectionManager()
        self.dev_warning_shown = False
    
    def show_dev_warning(self) -> str:
        """显示开发环境警告"""
        if not self.dev_warning_shown:
            self.dev_warning_shown = True
            return """
⚠️  安全警告 ⚠️

此MySQL MCP服务器仅应在开发环境中使用！
- 不应在生产环境中使用此工具
- 使用前请确保数据库中的数据可以安全修改
- 建议使用专门的测试数据库
- 定期备份重要数据

继续使用即表示您理解并接受此风险。
"""
        return ""
    
    async def handle_connect_database(self, 
                                    host: str,
                                    port: int = 3306,
                                    database: str = "",
                                    username: str = "",
                                    password: str = "",
                                    charset: str = "utf8mb4") -> str:
        """连接数据库工具"""
        warning = self.show_dev_warning()
        
        if not all([host, database, username]):
            return f"{warning}错误：缺少必要的连接参数。请提供host、database、username和password。"
        
        config = DatabaseConfig(
            host=host,
            port=port,
            database=database,
            username=username,
            password=password,
            charset=charset
        )
        
        try:
            with self.connection_manager.get_connection(config) as conn:
                cursor = conn.cursor()
                cursor.execute("SELECT VERSION()")
                version = cursor.fetchone()
                cursor.close()
                
                return f"{warning}✅ 数据库连接成功！\nMySQL版本: {version[0]}\n主机: {host}:{port}\n数据库: {database}"
        except Error as e:
            return f"{warning}❌ 数据库连接失败: {str(e)}"
    
    async def handle_execute_query(self, query: str, max_rows: int = 1000) -> str:
        """执行SELECT查询工具"""
        warning = self.show_dev_warning()
        
        if not self.connection_manager.connection:
            return f"{warning}❌ 请先连接数据库"
        
        # 安全检查：只允许SELECT语句
        query_upper = query.strip().upper()
        if not query_upper.startswith('SELECT'):
            return f"{warning}❌ 此工具只允许执行SELECT查询语句。如需执行写操作，请使用相应的写操作工具。"
        
        try:
            with self.connection_manager.get_connection(self.connection_manager.config) as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(query)
                results = cursor.fetchall()
                cursor.close()
                
                if not results:
                    return f"{warning}查询成功，但没有返回任何数据。"
                
                # 格式化结果
                output = f"{warning}查询成功！返回 {len(results)} 行数据：\n\n"
                
                # 显示列名
                if results:
                    columns = list(results[0].keys())
                    output += " | ".join(columns) + "\n"
                    output += "-" * (len(" | ".join(columns))) + "\n"
                    
                    # 显示数据
                    for row in results[:max_rows]:
                        values = [str(row[col]) for col in columns]
                        output += " | ".join(values) + "\n"
                    
                    if len(results) > max_rows:
                        output += f"\n... (显示前 {max_rows} 行，共 {len(results)} 行)"
                
                return output
        except Error as e:
            return f"{warning}❌ 查询执行失败: {str(e)}"
    
    async def handle_describe_table(self, table_name: str) -> str:
        """获取表结构信息"""
        warning = self.show_dev_warning()
        
        if not self.connection_manager.connection:
            return f"{warning}❌ 请先连接数据库"
        
        try:
            with self.connection_manager.get_connection(self.connection_manager.config) as conn:
                cursor = conn.cursor(dictionary=True)
                cursor.execute(f"DESCRIBE {table_name}")
                columns = cursor.fetchall()
                
                cursor.execute(f"SHOW INDEX FROM {table_name}")
                indexes = cursor.fetchall()
                cursor.close()
                
                output = f"{warning}表 {table_name} 结构信息：\n\n"
                
                # 列信息
                output += "列信息:\n"
                output += "字段名 | 类型 | 是否为空 | 键 | 默认值 | 额外信息\n"
                output += "-" * 60 + "\n"
                
                for col in columns:
                    output += f"{col['Field']} | {col['Type']} | {col['Null']} | {col['Key']} | {col['Default']} | {col['Extra']}\n"
                
                # 索引信息
                if indexes:
                    output += "\n索引信息:\n"
                    for idx in indexes:
                        output += f"索引名: {idx['Key_name']}, 列: {idx['Column_name']}, 唯一性: {'是' if idx['Non_unique'] == 0 else '否'}\n"
                
                return output
        except Error as e:
            return f"{warning}❌ 获取表结构失败: {str(e)}"
    
    async def handle_show_tables(self) -> str:
        """显示所有表"""
        warning = self.show_dev_warning()
        
        if not self.connection_manager.connection:
            return f"{warning}❌ 请先连接数据库"
        
        try:
            with self.connection_manager.get_connection(self.connection_manager.config) as conn:
                cursor = conn.cursor()
                cursor.execute("SHOW TABLES")
                tables = cursor.fetchall()
                cursor.close()
                
                output = f"{warning}数据库中的表：\n\n"
                for table in tables:
                    output += f"- {table[0]}\n"
                
                return output
        except Error as e:
            return f"{warning}❌ 获取表列表失败: {str(e)}"
    
    async def handle_execute_write_operation(self, sql: str) -> str:
        """执行写操作工具（需要确认）"""
        warning = self.show_dev_warning()
        
        if not self.connection_manager.connection:
            return f"{warning}❌ 请先连接数据库"
        
        # 检查是否为写操作
        write_keywords = ['INSERT', 'UPDATE', 'DELETE', 'CREATE', 'ALTER', 'DROP', 'TRUNCATE']
        is_write_operation = any(sql.strip().upper().startswith(keyword) for keyword in write_keywords)
        
        if not is_write_operation:
            return f"{warning}❌ 检测到这不是写操作语句。请确认您要执行的是INSERT、UPDATE、DELETE、CREATE、ALTER或DROP语句。"
        
        # 返回确认信息
        return f"""{warning}⚠️  危险操作确认 ⚠️

检测到您准备执行写操作：
{sql[:200]}{'...' if len(sql) > 200 else ''}

此操作将修改数据库！
请在客户端中明确确认以下内容：
1. 您理解这是不可逆的操作
2. 您已经在开发环境中
3. 您已经备份了重要数据
4. 您确认要执行此操作

如需继续，请回复 "确认执行" 并重新调用此工具。"""
    
    async def handle_confirmed_write_operation(self, sql: str) -> str:
        """确认执行写操作"""
        warning = self.show_dev_warning()
        
        try:
            with self.connection_manager.get_connection(self.connection_manager.config) as conn:
                cursor = conn.cursor()
                cursor.execute(sql)
                affected_rows = cursor.rowcount
                conn.commit()
                cursor.close()
                
                return f"{warning}✅ 写操作执行成功！\n影响行数: {affected_rows}\nSQL: {sql[:100]}{'...' if len(sql) > 100 else ''}"
        except Error as e:
            return f"{warning}❌ 写操作执行失败: {str(e)}"
    
    async def handle_get_database_info(self) -> str:
        """获取数据库信息"""
        warning = self.show_dev_warning()
        
        if not self.connection_manager.connection:
            return f"{warning}❌ 请先连接数据库"
        
        try:
            with self.connection_manager.get_connection(self.connection_manager.config) as conn:
                cursor = conn.cursor(dictionary=True)
                
                # 数据库基本信息
                cursor.execute("SELECT VERSION() as version, DATABASE() as database, USER() as user")
                basic_info = cursor.fetchone()
                
                # 表统计信息
                cursor.execute("""
                    SELECT 
                        COUNT(*) as table_count,
                        SUM(table_rows) as total_rows,
                        SUM(data_length + index_length) as total_size
                    FROM information_schema.tables 
                    WHERE table_schema = DATABASE()
                """)
                stats = cursor.fetchone()
                
                cursor.close()
                
                output = f"""{warning}数据库信息：

基本连接信息：
- MySQL版本: {basic_info['version']}
- 当前数据库: {basic_info['database']}
- 连接用户: {basic_info['user']}

统计信息：
- 表数量: {stats['table_count']}
- 总行数: {stats['total_rows'] or 0}
- 总大小: {self._format_bytes(stats['total_size'] or 0)}

当前时间: {self._get_current_time()}
"""
                return output
        except Error as e:
            return f"{warning}❌ 获取数据库信息失败: {str(e)}"
    
    def _format_bytes(self, bytes_value: int) -> str:
        """格式化字节大小"""
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if bytes_value < 1024.0:
                return f"{bytes_value:.2f} {unit}"
            bytes_value /= 1024.0
        return f"{bytes_value:.2f} PB"
    
    def _get_current_time(self) -> str:
        """获取当前时间"""
        from datetime import datetime
        return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


# 创建服务器实例
server = MySQLMCPServer()


def main():
    """简单的MCP服务器主函数"""
    print("🟢 MySQL MCP服务器启动中...")
    print("⚠️  此工具仅应在开发环境中使用！")
    print()
    print("📋 可用工具:")
    print("  - connect_database: 连接MySQL数据库")
    print("  - execute_query: 执行SELECT查询")
    print("  - describe_table: 查看表结构")
    print("  - show_tables: 显示所有表")
    print("  - execute_write_operation: 执行写操作（需确认）")
    print("  - confirmed_write_operation: 确认执行写操作")
    print("  - get_database_info: 获取数据库信息")
    print()
    print("💡 使用说明:")
    print("  1. 使用MCP客户端连接此服务器")
    print("  2. 先使用connect_database工具连接数据库")
    print("  3. 然后使用其他工具进行数据库操作")
    print()
    print("🛑 按 Ctrl+C 停止服务器")
    print("-" * 50)
    
    try:
        # 保持服务器运行
        import time
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        print("\n👋 MySQL MCP服务器已停止")


if __name__ == "__main__":
    main()
