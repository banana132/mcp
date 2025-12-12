#!/usr/bin/env python3
"""
MySQL MCP服务器连接测试脚本
用于测试数据库连接和基本功能
"""

import mysql.connector
from mysql.connector import Error
import sys
from datetime import datetime


def test_mysql_connection(host, port, database, username, password, charset='utf8mb4'):
    """测试MySQL连接"""
    print(f"🔍 正在测试MySQL连接...")
    print(f"   主机: {host}:{port}")
    print(f"   数据库: {database}")
    print(f"   用户: {username}")
    print(f"   字符集: {charset}")
    print()
    
    try:
        # 建立连接
        connection = mysql.connector.connect(
            host=host,
            port=port,
            database=database,
            user=username,
            password=password,
            charset=charset,
            use_pure=True
        )
        
        if connection.is_connected():
            cursor = connection.cursor()
            
            # 获取服务器信息
            cursor.execute("SELECT VERSION()")
            version = cursor.fetchone()
            
            cursor.execute("SELECT DATABASE()")
            current_db = cursor.fetchone()
            
            cursor.execute("SELECT USER()")
            current_user = cursor.fetchone()
            
            # 获取表数量
            cursor.execute("SHOW TABLES")
            tables = cursor.fetchall()
            
            print("✅ 连接成功！")
            print()
            print("📊 服务器信息:")
            print(f"   MySQL版本: {version[0]}")
            print(f"   当前数据库: {current_db[0]}")
            print(f"   连接用户: {current_user[0]}")
            print(f"   表数量: {len(tables)}")
            print()
            
            # 显示所有表
            if tables:
                print("📋 数据库中的表:")
                for table in tables:
                    print(f"   - {table[0]}")
                print()
            
            # 测试简单查询
            print("🧪 测试简单查询...")
            try:
                cursor.execute("SELECT NOW() as current_time, VERSION() as mysql_version")
                result = cursor.fetchone()
                print(f"   当前时间: {result[0]}")
                print(f"   查询测试: ✅ 成功")
            except Error as e:
                print(f"   查询测试: ❌ 失败 - {e}")
            
            cursor.close()
            connection.close()
            
            print()
            print("🎉 所有测试通过！MySQL MCP服务器应该可以正常工作。")
            return True
            
    except Error as e:
        print(f"❌ 连接失败: {e}")
        print()
        print("🔧 故障排除建议:")
        print("   1. 检查MySQL服务是否正在运行")
        print("   2. 确认主机地址和端口是否正确")
        print("   3. 验证用户名和密码")
        print("   4. 检查网络连接和防火墙设置")
        print("   5. 确认用户具有访问数据库的权限")
        return False


def interactive_test():
    """交互式测试"""
    print("🔧 MySQL MCP服务器连接测试")
    print("=" * 50)
    print()
    
    # 获取用户输入
    host = input("MySQL主机地址 (默认: localhost): ").strip() or "localhost"
    port = input("端口号 (默认: 3306): ").strip() or "3306"
    database = input("数据库名称: ").strip()
    username = input("用户名: ").strip()
    password = input("密码: ").strip()
    charset = input("字符集 (默认: utf8mb4): ").strip() or "utf8mb4"
    
    if not all([database, username, password]):
        print("❌ 错误：数据库名、用户名和密码为必填项！")
        return
    
    try:
        port = int(port)
    except ValueError:
        print("❌ 错误：端口号必须是数字！")
        return
    
    print()
    test_mysql_connection(host, port, database, username, password, charset)


def main():
    """主函数"""
    if len(sys.argv) >= 6:
        # 命令行参数模式
        host = sys.argv[1]
        port = int(sys.argv[2])
        database = sys.argv[3]
        username = sys.argv[4]
        password = sys.argv[5]
        charset = sys.argv[6] if len(sys.argv) > 6 else 'utf8mb4'
        
        test_mysql_connection(host, port, database, username, password, charset)
    else:
        # 交互式模式
        interactive_test()


if __name__ == "__main__":
    main()
