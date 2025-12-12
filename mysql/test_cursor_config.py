#!/usr/bin/env python3
"""
Cursor MCP配置测试脚本
验证MySQL MCP服务器是否正确配置并在Cursor中可用
"""

import os
import sys
import json
import subprocess
from pathlib import Path


def test_python_environment():
    """测试Python环境"""
    print("🐍 检查Python环境...")
    
    try:
        # 检查Python版本
        python_version = sys.version.split()[0]
        print(f"   Python版本: {python_version}")
        
        # 检查必要模块
        modules_to_check = ['json', 'os', 'sys', 'subprocess']
        for module in modules_to_check:
            try:
                __import__(module)
                print(f"   ✅ {module} 模块可用")
            except ImportError:
                print(f"   ❌ {module} 模块缺失")
                return False
        
        return True
    except Exception as e:
        print(f"   ❌ Python环境检查失败: {e}")
        return False


def test_mcp_server_file():
    """测试MCP服务器文件"""
    print("\n📁 检查MCP服务器文件...")
    
    server_file = Path(__file__).parent / "mysql_mcp_server.py"
    
    if not server_file.exists():
        print(f"   ❌ 找不到服务器文件: {server_file}")
        return False
    
    print(f"   ✅ 服务器文件存在: {server_file}")
    
    # 检查文件权限
    if os.access(server_file, os.R_OK):
        print(f"   ✅ 服务器文件可读")
    else:
        print(f"   ❌ 服务器文件不可读")
        return False
    
    return True


def test_cursor_config():
    """测试Cursor配置"""
    print("\n🔧 检查Cursor配置...")
    
    # 检查配置文件是否存在
    config_files = [
        Path.home() / ".cursor" / "settings.json",
        Path(os.environ.get('APPDATA', '')) / "Cursor" / "settings.json"
    ]
    
    config_found = False
    for config_file in config_files:
        if config_file.exists():
            print(f"   ✅ 找到配置文件: {config_file}")
            config_found = True
            
            try:
                with open(config_file, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if 'mysql-mcp-server' in content:
                        print(f"   ✅ MCP服务器配置已添加")
                    else:
                        print(f"   ⚠️  MCP服务器配置未找到")
                        
            except Exception as e:
                print(f"   ❌ 读取配置文件失败: {e}")
            
            break
    
    if not config_found:
        print(f"   ⚠️  未找到Cursor配置文件")
        print(f"   💡 建议手动创建配置文件或通过UI添加")
    
    return True


def test_demo_functionality():
    """测试演示功能"""
    print("\n🎭 测试演示功能...")
    
    try:
        # 检查demo文件
        demo_file = Path(__file__).parent / "demo.py"
        if not demo_file.exists():
            print(f"   ❌ 找不到演示文件")
            return False
        
        print(f"   ✅ 演示文件存在")
        
        # 尝试导入演示模块
        sys.path.insert(0, str(demo_file.parent))
        
        # 检查演示类是否存在
        from demo import MySQLMCPDemo
        demo = MySQLMCPDemo()
        
        # 测试基本功能
        result = demo.handle_connect_database("test", database="test", username="test", password="test")
        if "连接成功" in result:
            print(f"   ✅ 演示功能正常工作")
            return True
        else:
            print(f"   ❌ 演示功能异常")
            return False
            
    except Exception as e:
        print(f"   ❌ 演示功能测试失败: {e}")
        return False


def test_dependencies():
    """测试依赖包"""
    print("\n📦 检查依赖包...")
    
    dependencies = {
        'mysql.connector': 'mysql-connector-python',
        'pydantic': 'pydantic'
    }
    
    missing_deps = []
    
    for module, package in dependencies.items():
        try:
            __import__(module)
            print(f"   ✅ {package} 已安装")
        except ImportError:
            print(f"   ❌ {package} 未安装")
            missing_deps.append(package)
    
    if missing_deps:
        print(f"\n   💡 安装缺失的依赖:")
        print(f"   pip3 install {' '.join(missing_deps)}")
        print(f"   或者运行: ./start.sh 选择安装依赖")
    
    return len(missing_deps) == 0


def generate_cursor_config():
    """生成Cursor配置示例"""
    print("\n📝 生成Cursor配置示例...")
    
    mysql_dir = Path(__file__).parent.absolute()
    
    config = {
        "mcpServers": {
            "mysql-mcp-server": {
                "command": "python3",
                "args": [str(mysql_dir / "mysql_mcp_server.py")],
                "cwd": str(mysql_dir),
                "env": {
                    "PYTHONPATH": str(mysql_dir)
                }
            }
        }
    }
    
    print(f"\n💡 Cursor配置示例 (保存到 ~/.cursor/settings.json):")
    print("=" * 60)
    print(json.dumps(config, indent=2, ensure_ascii=False))
    print("=" * 60)


def main():
    """主测试函数"""
    print("🧪 MySQL MCP服务器 - Cursor配置测试")
    print("=" * 50)
    
    tests = [
        ("Python环境", test_python_environment),
        ("MCP服务器文件", test_mcp_server_file),
        ("Cursor配置", test_cursor_config),
        ("演示功能", test_demo_functionality),
        ("依赖包", test_dependencies),
    ]
    
    results = {}
    
    for test_name, test_func in tests:
        try:
            results[test_name] = test_func()
        except Exception as e:
            print(f"   ❌ {test_name}测试异常: {e}")
            results[test_name] = False
    
    # 生成配置示例
    generate_cursor_config()
    
    # 总结
    print("\n" + "=" * 50)
    print("📊 测试总结:")
    
    all_passed = True
    for test_name, passed in results.items():
        status = "✅ 通过" if passed else "❌ 失败"
        print(f"   {test_name}: {status}")
        if not passed:
            all_passed = False
    
    print("\n" + "=" * 50)
    
    if all_passed:
        print("🎉 所有测试通过！MySQL MCP服务器已准备好在Cursor中使用。")
        print("\n📋 接下来:")
        print("1. 在Cursor中配置MCP服务器（见CURSOR_SETUP.md）")
        print("2. 重启Cursor IDE")
        print("3. 在聊天中测试MySQL工具")
    else:
        print("⚠️  部分测试失败，请检查上述错误信息。")
        print("\n🔧 建议:")
        print("1. 先运行演示模式: python3 demo.py")
        print("2. 安装缺失的依赖")
        print("3. 查看CURSOR_SETUP.md获取详细配置指南")
    
    print("\n🛑 按 Ctrl+C 退出")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n👋 测试结束")
