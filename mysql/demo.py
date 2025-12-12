#!/usr/bin/env python3
"""
MySQL MCP服务器演示版本
这个版本不需要外部依赖，可以直接运行查看功能演示
"""

import json
from datetime import datetime


class MySQLMCPDemo:
    """MySQL MCP服务器演示类"""
    
    def __init__(self):
        self.dev_warning_shown = False
        self.database_connected = False
        self.connection_info = {}
    
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
    
    def handle_connect_database(self, host, port=3306, database="", username="", password="", charset="utf8mb4"):
        """演示连接数据库"""
        warning = self.show_dev_warning()
        
        if not all([host, database, username]):
            return f"{warning}❌ 错误：缺少必要的连接参数。请提供host、database、username和password。"
        
        # 模拟连接成功
        self.database_connected = True
        self.connection_info = {
            'host': host,
            'port': port,
            'database': database,
            'username': username,
            'charset': charset
        }
        
        return f"""{warning}✅ 数据库连接成功！（演示模式）
MySQL版本: 8.0.35
主机: {host}:{port}
数据库: {database}
字符集: {charset}

📝 注意：这是演示模式，实际使用需要安装 mysql-connector-python
"""
    
    def handle_execute_query(self, query, max_rows=1000):
        """演示执行查询"""
        warning = self.show_dev_warning()
        
        if not self.database_connected:
            return f"{warning}❌ 请先连接数据库"
        
        # 安全检查：只允许SELECT语句
        query_upper = query.strip().upper()
        if not query_upper.startswith('SELECT'):
            return f"{warning}❌ 此工具只允许执行SELECT查询语句。如需执行写操作，请使用相应的写操作工具。"
        
        # 模拟查询结果
        if 'users' in query.lower():
            results = [
                {'id': 1, 'name': '张三', 'email': 'zhangsan@example.com', 'status': 'active'},
                {'id': 2, 'name': '李四', 'email': 'lisi@example.com', 'status': 'active'},
                {'id': 3, 'name': '王五', 'email': 'wangwu@example.com', 'status': 'inactive'}
            ]
        elif 'orders' in query.lower():
            results = [
                {'order_id': 1001, 'user_id': 1, 'amount': 299.99, 'status': 'completed'},
                {'order_id': 1002, 'user_id': 2, 'amount': 159.50, 'status': 'pending'},
                {'order_id': 1003, 'user_id': 1, 'amount': 89.99, 'status': 'shipped'}
            ]
        else:
            results = [
                {'result': '查询执行成功', 'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
            ]
        
        # 限制返回行数
        results = results[:max_rows]
        
        output = f"{warning}查询成功！返回 {len(results)} 行数据：\n\n"
        
        if results:
            columns = list(results[0].keys())
            output += " | ".join(columns) + "\n"
            output += "-" * (len(" | ".join(columns))) + "\n"
            
            for row in results:
                values = [str(row[col]) for col in columns]
                output += " | ".join(values) + "\n"
        
        return output
    
    def handle_describe_table(self, table_name):
        """演示获取表结构"""
        warning = self.show_dev_warning()
        
        if not self.database_connected:
            return f"{warning}❌ 请先连接数据库"
        
        # 模拟表结构信息
        if table_name.lower() == 'users':
            columns_info = [
                {'Field': 'id', 'Type': 'int(11)', 'Null': 'NO', 'Key': 'PRI', 'Default': 'NULL', 'Extra': 'auto_increment'},
                {'Field': 'name', 'Type': 'varchar(100)', 'Null': 'NO', 'Key': '', 'Default': 'NULL', 'Extra': ''},
                {'Field': 'email', 'Type': 'varchar(255)', 'Null': 'NO', 'Key': 'UNI', 'Default': 'NULL', 'Extra': ''},
                {'Field': 'status', 'Type': 'enum("active","inactive")', 'Null': 'NO', 'Key': '', 'Default': 'active', 'Extra': ''},
                {'Field': 'created_at', 'Type': 'timestamp', 'Null': 'NO', 'Key': '', 'Default': 'current_timestamp()', 'Extra': ''}
            ]
        elif table_name.lower() == 'orders':
            columns_info = [
                {'Field': 'order_id', 'Type': 'int(11)', 'Null': 'NO', 'Key': 'PRI', 'Default': 'NULL', 'Extra': 'auto_increment'},
                {'Field': 'user_id', 'Type': 'int(11)', 'Null': 'NO', 'Key': 'MUL', 'Default': 'NULL', 'Extra': ''},
                {'Field': 'amount', 'Type': 'decimal(10,2)', 'Null': 'NO', 'Key': '', 'Default': '0.00', 'Extra': ''},
                {'Field': 'status', 'Type': 'enum("pending","processing","shipped","completed","cancelled")', 'Null': 'NO', 'Key': '', 'Default': 'pending', 'Extra': ''},
                {'Field': 'created_at', 'Type': 'timestamp', 'Null': 'NO', 'Key': '', 'Default': 'current_timestamp()', 'Extra': ''}
            ]
        else:
            columns_info = [
                {'Field': 'id', 'Type': 'int(11)', 'Null': 'NO', 'Key': 'PRI', 'Default': 'NULL', 'Extra': 'auto_increment'},
                {'Field': 'name', 'Type': 'varchar(255)', 'Null': 'YES', 'Key': '', 'Default': 'NULL', 'Extra': ''},
                {'Field': 'created_at', 'Type': 'timestamp', 'Null': 'NO', 'Key': '', 'Default': 'current_timestamp()', 'Extra': ''}
            ]
        
        output = f"{warning}表 {table_name} 结构信息：\n\n"
        
        # 列信息
        output += "列信息:\n"
        output += "字段名 | 类型 | 是否为空 | 键 | 默认值 | 额外信息\n"
        output += "-" * 60 + "\n"
        
        for col in columns_info:
            output += f"{col['Field']} | {col['Type']} | {col['Null']} | {col['Key']} | {col['Default']} | {col['Extra']}\n"
        
        return output
    
    def handle_show_tables(self):
        """演示显示所有表"""
        warning = self.show_dev_warning()
        
        if not self.database_connected:
            return f"{warning}❌ 请先连接数据库"
        
        # 模拟表列表
        tables = ['users', 'orders', 'products', 'categories', 'reviews']
        
        output = f"{warning}数据库中的表：\n\n"
        for table in tables:
            output += f"- {table}\n"
        
        return output
    
    def handle_execute_write_operation(self, sql):
        """演示执行写操作"""
        warning = self.show_dev_warning()
        
        if not self.database_connected:
            return f"{warning}❌ 请先连接数据库"
        
        # 检查是否为写操作
        write_keywords = ['INSERT', 'UPDATE', 'DELETE', 'CREATE', 'ALTER', 'DROP', 'TRUNCATE']
        is_write_operation = any(sql.strip().upper().startswith(keyword) for keyword in write_keywords)
        
        if not is_write_operation:
            return f"{warning}❌ 检测到这不是写操作语句。请确认您要执行的是INSERT、UPDATE、DELETE、CREATE、ALTER或DROP语句。"
        
        return f"""{warning}⚠️  危险操作确认 ⚠️

检测到您准备执行写操作：
{sql[:200]}{'...' if len(sql) > 200 else ''}

此操作将修改数据库！
请在客户端中明确确认以下内容：
1. 您理解这是不可逆的操作
2. 您已经在开发环境中
3. 您已经备份了重要数据
4. 您确认要执行此操作

如需继续，请回复 "确认执行" 并重新调用此工具。

📝 注意：这是演示模式，实际执行需要连接真实数据库。"""
    
    def handle_confirmed_write_operation(self, sql):
        """演示确认执行写操作"""
        warning = self.show_dev_warning()
        
        return f"""{warning}✅ 写操作执行成功！（演示模式）
影响行数: 1
SQL: {sql[:100]}{'...' if len(sql) > 100 else ''}

📝 注意：这是演示模式，实际执行需要连接真实数据库并安装依赖。"""
    
    def handle_get_database_info(self):
        """演示获取数据库信息"""
        warning = self.show_dev_warning()
        
        if not self.database_connected:
            return f"{warning}❌ 请先连接数据库"
        
        return f"""{warning}数据库信息：

基本连接信息：
- MySQL版本: 8.0.35
- 当前数据库: {self.connection_info.get('database', 'unknown')}
- 连接用户: {self.connection_info.get('username', 'unknown')}

统计信息：
- 表数量: 5
- 总行数: 1,247
- 总大小: 2.45 MB

当前时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

📝 注意：这是演示模式，实际信息需要连接真实数据库。"""


def main():
    """主演示函数"""
    print("🟢 MySQL MCP服务器演示版")
    print("=" * 50)
    print()
    
    demo = MySQLMCPDemo()
    
    print("🚀 开始演示功能...")
    print()
    
    # 演示1：连接数据库
    print("1️⃣ 演示连接数据库")
    result = demo.handle_connect_database(
        host="localhost",
        database="demo_db",
        username="demo_user",
        password="demo_pass"
    )
    print(result)
    print()
    
    # 演示2：显示表
    print("2️⃣ 演示显示所有表")
    result = demo.handle_show_tables()
    print(result)
    print()
    
    # 演示3：查看表结构
    print("3️⃣ 演示查看表结构")
    result = demo.handle_describe_table("users")
    print(result)
    print()
    
    # 演示4：执行查询
    print("4️⃣ 演示执行查询")
    result = demo.handle_execute_query("SELECT * FROM users WHERE status = 'active' LIMIT 3")
    print(result)
    print()
    
    # 演示5：写操作确认
    print("5️⃣ 演示写操作确认")
    result = demo.handle_execute_write_operation("INSERT INTO users (name, email) VALUES ('测试用户', 'test@example.com')")
    print(result)
    print()
    
    # 演示6：确认写操作
    print("6️⃣ 演示确认执行写操作")
    result = demo.handle_confirmed_write_operation("INSERT INTO users (name, email) VALUES ('测试用户', 'test@example.com')")
    print(result)
    print()
    
    # 演示7：数据库信息
    print("7️⃣ 演示获取数据库信息")
    result = demo.handle_get_database_info()
    print(result)
    print()
    
    print("=" * 50)
    print("🎉 演示完成！")
    print()
    print("📋 要使用真实功能，请：")
    print("1. 安装依赖：pip3 install mysql-connector-python pydantic")
    print("2. 运行：python3 mysql_mcp_server.py")
    print("3. 通过MCP客户端连接使用")
    print()
    print("🛑 按 Ctrl+C 退出")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n👋 演示结束")
