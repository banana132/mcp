# 🔧 Cursor IDE 中配置 MySQL MCP服务器

本指南将帮助您在Cursor IDE中配置MySQL MCP服务器，以便直接在IDE中使用数据库工具。

## 📋 前置要求

- ✅ 已安装MySQL MCP服务器
- ✅ Cursor IDE (最新版本)
- ✅ Python 3.7+ 已安装
- ✅ MySQL依赖包已安装（如果使用真实模式）

## 🚀 配置步骤

### 方法一：通过Cursor设置界面配置（推荐）

#### 1. 打开Cursor设置

- 打开Cursor IDE
- 按 `Cmd/Ctrl + ,` 打开设置
- 或者点击左下角设置图标 → Settings

#### 2. 找到MCP设置

在设置面板中：
- 搜索 "MCP" 
- 或导航到 `Extensions` → `Model Context Protocol`

#### 3. 添加MCP服务器

1. 点击 "Add MCP Server" 或 "+" 按钮
2. 填写配置信息：

```
Name: mysql-mcp-server
Command: python3
Arguments: /Users/colin/Depots/projects/mcp/mysql/mysql_mcp_server.py
Working Directory: /Users/colin/Depots/projects/mcp/mysql
Environment Variables:
  PYTHONPATH=/Users/colin/Depots/projects/mcp/mysql
```

#### 4. 保存并重启

- 点击 "Save" 或 "Apply"
- 重启Cursor IDE以使配置生效

### 方法二：手动配置文件

#### 1. 创建MCP配置文件

在您的用户目录下创建或编辑MCP配置文件：

**macOS/Linux:**
```bash
~/.cursor/settings.json
```

**Windows:**
```cmd
%APPDATA%\Cursor\settings.json
```

#### 2. 添加配置内容

```json
{
  "mcpServers": {
    "mysql-mcp-server": {
      "command": "python3",
      "args": ["/Users/colin/Depots/projects/mcp/mysql/mysql_mcp_server.py"],
      "cwd": "/Users/colin/Depots/projects/mcp/mysql",
      "env": {
        "PYTHONPATH": "/Users/colin/Depots/projects/mcp/mysql"
      }
    }
  }
}
```

#### 3. 重启Cursor

重启Cursor IDE以加载新的MCP配置。

## 🧪 验证配置

### 检查MCP服务器状态

1. 打开Cursor的聊天窗口（`Cmd/Ctrl + L`）
2. 输入命令检查MCP服务器状态：

```
/status
```

或者测试连接：

```
连接到数据库: host=localhost, database=test, username=test, password=test
```

### 确认可用工具

成功配置后，您应该能看到以下7个MySQL工具：

1. `connect_database` - 连接数据库
2. `execute_query` - 执行查询
3. `describe_table` - 查看表结构
4. `show_tables` - 显示所有表
5. `execute_write_operation` - 执行写操作
6. `confirmed_write_operation` - 确认执行写操作
7. `get_database_info` - 获取数据库信息

## 💡 使用示例

### 在Cursor聊天中使用

```
用户：请帮我连接开发数据库
AI：好的，我来帮您连接数据库。

请提供以下信息：
- MySQL主机地址 (默认: localhost)
- 数据库名称
- 用户名
- 密码

用户：localhost, myapp_dev, dev_user, dev123
AI：使用 connect_database 工具连接数据库...
✅ 数据库连接成功！
MySQL版本: 8.0.35
主机: localhost:3306
数据库: myapp_dev
```

### 直接调用工具

```
用户：查看数据库中的所有表
AI：使用 show_tables 工具...

数据库中的表：
- users
- orders
- products
- categories
- reviews
```

## ⚠️ 配置注意事项

### 路径问题

- 确保 `args` 中的路径是绝对路径
- `cwd` 指定为MySQL服务器脚本所在目录
- 如果路径包含空格，需要用引号包围

### Python环境

- 确保Python 3在系统PATH中可访问
- 如果使用虚拟环境，需要激活虚拟环境
- 检查依赖包是否正确安装

### 权限问题

- 确保Python脚本有执行权限
- 确保数据库用户具有适当权限
- 检查防火墙设置

### 安全考虑

- 不要在配置文件中硬编码数据库密码
- 使用环境变量管理敏感信息
- 定期更新数据库密码

## 🔧 故障排除

### 常见问题

#### 1. MCP服务器启动失败

**错误信息**: "Failed to start MCP server"

**解决方案**:
- 检查Python路径是否正确
- 确认依赖包已安装
- 检查脚本文件是否存在且有执行权限
- 查看Cursor控制台日志获取详细错误

#### 2. 工具不可用

**问题**: 在聊天中看不到MySQL工具

**解决方案**:
- 重启Cursor IDE
- 检查MCP配置是否正确保存
- 确认MCP服务器进程正在运行
- 检查聊天面板是否启用了MCP工具

#### 3. 连接数据库失败

**问题**: 连接MySQL时提示连接失败

**解决方案**:
- 检查MySQL服务是否正在运行
- 验证连接参数（主机、端口、用户名、密码）
- 确认数据库用户权限
- 检查网络连接和防火墙设置

#### 4. 依赖包缺失

**问题**: 提示 "ModuleNotFoundError"

**解决方案**:
```bash
cd /Users/colin/Depots/projects/mcp/mysql
pip3 install mysql-connector-python pydantic
```

### 调试步骤

#### 1. 手动测试服务器

```bash
cd /Users/colin/Depots/projects/mcp/mysql
python3 mysql_mcp_server.py
```

#### 2. 检查Python环境

```bash
which python3
python3 --version
python3 -c "import mysql.connector; print('OK')"
```

#### 3. 查看日志

- Cursor控制台日志
- 系统终端输出
- MySQL服务器错误日志

## 📁 配置文件示例

### 完整配置示例

```json
{
  "mcpServers": {
    "mysql-mcp-server": {
      "command": "python3",
      "args": ["/Users/colin/Depots/projects/mcp/mysql/mysql_mcp_server.py"],
      "cwd": "/Users/colin/Depots/projects/mcp/mysql",
      "env": {
        "PYTHONPATH": "/Users/colin/Depots/projects/mcp/mysql",
        "MYSQL_HOST": "localhost",
        "MYSQL_PORT": "3306"
      }
    }
  },
  "chat.tools.enabled": true,
  "mcpServers.enabled": true
}
```

### 环境变量配置

您也可以使用环境变量来管理数据库连接：

```bash
# 在启动Cursor前设置环境变量
export MYSQL_HOST=localhost
export MYSQL_PORT=3306
export MYSQL_DATABASE=myapp_dev
export MYSQL_USERNAME=dev_user
export MYSQL_PASSWORD=dev123
```

然后在配置中引用这些变量：

```json
{
  "mcpServers": {
    "mysql-mcp-server": {
      "command": "python3",
      "args": ["/Users/colin/Depots/projects/mcp/mysql/mysql_mcp_server.py"],
      "cwd": "/Users/colin/Depots/projects/mcp/mysql",
      "env": {
        "MYSQL_HOST": "${MYSQL_HOST}",
        "MYSQL_PORT": "${MYSQL_PORT}",
        "MYSQL_DATABASE": "${MYSQL_DATABASE}",
        "MYSQL_USERNAME": "${MYSQL_USERNAME}",
        "MYSQL_PASSWORD": "${MYSQL_PASSWORD}"
      }
    }
  }
}
```

## 🎯 使用技巧

### 1. 快捷操作

- 使用 `Cmd/Ctrl + L` 打开聊天
- 输入数据库相关问题，AI会自动调用相应工具
- 利用自然语言描述您需要的数据库操作

### 2. 安全最佳实践

- 使用演示模式学习和测试功能
- 在开发环境中使用测试数据库
- 定期备份重要数据
- 写操作前仔细确认SQL语句

### 3. 效率提升

- 预先准备常用查询语句
- 建立数据库连接后可以连续执行多个查询
- 使用表结构查看功能了解数据库设计

## 📞 支持

如果配置过程中遇到问题：

1. 首先查看此文档的故障排除部分
2. 运行演示模式验证工具功能
3. 检查MySQL服务器和依赖安装
4. 查看Cursor官方文档了解MCP配置

---

**配置成功后，您就可以在Cursor IDE中直接使用MySQL数据库工具了！** 🎉
