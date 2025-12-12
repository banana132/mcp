# 🚀 MySQL MCP服务器 - 快速开始指南

欢迎使用MySQL MCP服务器！本指南将帮助您在5分钟内快速启动并运行。

## 📋 前置要求

- Python 3.7+
- MySQL 5.7+ 或 MariaDB 10.2+
- 可访问的MySQL数据库
- Cursor IDE (可选，用于IDE集成)

## ⚡ 快速启动

### 步骤1: 安装依赖

```bash
cd /Users/colin/Depots/projects/mcp/mysql
pip install -r requirements.txt
```

### 步骤2: 测试配置

```bash
# 验证配置是否正确
python3 test_cursor_config.py

# 测试数据库连接（可选）
python3 test_connection.py
```

### 步骤3: 启动服务器

#### 选项A: 使用启动脚本（推荐）

```bash
chmod +x start.sh
./start.sh
```

#### 选项B: 直接运行

```bash
# 真实模式（需要依赖）
python3 mysql_mcp_server.py

# 演示模式（无需依赖）
python3 demo.py
```

## 🔧 Cursor IDE 配置

要在Cursor中直接使用MySQL工具，请按以下步骤配置：

### 方法1: UI配置（推荐）

1. **打开Cursor设置**
   - 按 `Cmd/Ctrl + ,` 打开设置
   - 搜索 "MCP"

2. **添加MCP服务器**
   - 点击 "Add MCP Server" 或 "+"
   - 填写配置：
     ```
     Name: mysql-mcp-server
     Command: python3
     Arguments: /Users/colin/Depots/projects/mcp/mysql/mysql_mcp_server.py
     Working Directory: /Users/colin/Depots/projects/mcp/mysql
     ```

3. **重启Cursor**
   - 重启IDE使配置生效

### 方法2: 手动配置

在 `~/.cursor/settings.json` 中添加：

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

## 🔗 第一次连接

### 在Cursor聊天中使用

```
用户：请帮我连接开发数据库
AI：好的，我来帮您连接数据库。请提供连接信息：
- MySQL主机地址
- 数据库名称
- 用户名
- 密码

用户：localhost, myapp_dev, dev_user, dev123
```

或者直接使用工具：

```json
{
  "tool": "connect_database",
  "arguments": {
    "host": "localhost",
    "port": 3306,
    "database": "your_database_name",
    "username": "your_username",
    "password": "your_password"
  }
}
```

## 🧪 基本操作

### 1. 查看数据库中的表

```
用户：显示所有表
AI：使用 show_tables 工具...

数据库中的表：
- users
- orders
- products
```

### 2. 查看表结构

```
用户：查看users表的结构
AI：使用 describe_table 工具...

表 users 结构信息：
字段名 | 类型 | 是否为空 | 键 | 默认值 | 额外信息
------------------------------------------------------------
id | int(11) | NO | PRI | NULL | auto_increment
name | varchar(100) | NO | | NULL | 
email | varchar(255) | NO | UNI | NULL | 
...
```

### 3. 执行查询

```
用户：查询前10个活跃用户
AI：使用 execute_query 工具...

SELECT * FROM users WHERE status = 'active' LIMIT 10

查询成功！返回 10 行数据：
id | name | email | status
1 | 张三 | zhangsan@example.com | active
2 | 李四 | lisi@example.com | active
...
```

### 4. 执行写操作（需要确认）

```
用户：插入新用户
AI：使用 execute_write_operation 工具...

INSERT INTO users (name, email, status) VALUES ('新用户', 'new@example.com', 'active')

⚠️  危险操作确认 ⚠️
检测到您准备执行写操作...

请确认：
1. 您理解这是不可逆的操作
2. 您已经在开发环境中
3. 您已经备份了重要数据
4. 您确认要执行此操作

如需继续，请回复 "确认执行"
```

## ⚠️ 重要提醒

- **仅用于开发环境**：此工具不应在生产环境中使用
- **数据安全**：执行写操作前请确保已备份数据
- **权限控制**：使用具有适当权限的数据库用户

## 🆘 遇到问题？

### 快速诊断

```bash
# 运行配置测试
python3 test_cursor_config.py

# 运行演示模式
python3 demo.py

# 检查启动脚本
./start.sh
```

### 常见问题

1. **依赖缺失**：运行 `./start.sh` 选择安装依赖
2. **连接失败**：使用 `python3 test_connection.py` 测试连接
3. **Cursor配置**：查看 [CURSOR_SETUP.md](CURSOR_SETUP.md) 详细指南
4. **其他问题**：查看 [README.md](README.md) 完整文档

### 工具验证

配置成功后，您应该能看到以下7个工具：

1. `connect_database` - 连接数据库
2. `execute_query` - 执行查询
3. `describe_table` - 查看表结构
4. `show_tables` - 显示所有表
5. `execute_write_operation` - 执行写操作（需确认）
6. `confirmed_write_operation` - 确认执行写操作
7. `get_database_info` - 获取数据库信息

## 📚 更多资源

- 完整文档：[README.md](README.md)
- Cursor配置：[CURSOR_SETUP.md](CURSOR_SETUP.md)
- 配置示例：[config.example.py](config.example.py)
- 测试工具：[test_cursor_config.py](test_cursor_config.py)

---

🎉 **恭喜！您现在可以开始在Cursor中使用MySQL MCP服务器了！**
