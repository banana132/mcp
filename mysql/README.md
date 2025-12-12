# MySQL MCP服务器 - 开发环境专用

⚠️ **安全警告** ⚠️

此MySQL MCP服务器仅应在开发环境中使用！不应在生产环境中使用此工具。

## 📋 目录

- [功能特性](#功能特性)
- [快速开始](#快速开始)
- [演示模式](#演示模式)
- [Cursor IDE配置](#cursor-ide配置)
- [工具说明](#工具说明)
- [使用示例](#使用示例)
- [安全注意事项](#安全注意事项)
- [常见问题](#常见问题)

## ✨ 功能特性

- **数据库连接管理**: 支持MySQL数据库的安全连接
- **查询执行**: 执行SELECT查询并格式化结果
- **表结构查看**: 获取表的详细结构信息
- **数据库管理**: 显示所有表和数据库统计信息
- **写操作支持**: 支持INSERT、UPDATE、DELETE等写操作（需确认）
- **开发环境专用**: 每次使用都会显示安全警告
- **演示模式**: 无需依赖即可体验所有功能
- **Cursor IDE集成**: 可直接在Cursor中使用所有功能

## 🚀 快速开始

### 1. 安装依赖

```bash
cd /Users/colin/Depots/projects/mcp/mysql
pip install -r requirements.txt
```

### 2. 运行服务器

```bash
./start.sh
```

### 3. 连接数据库

使用以下工具连接您的MySQL数据库：

- **工具**: `connect_database`
- **参数**: host, port, database, username, password

### 4. 开始查询

连接成功后，您可以使用各种工具进行数据库操作。

## 🎭 演示模式

如果您的环境没有安装必要的依赖包，可以先运行演示模式来体验所有功能：

### 运行演示

```bash
python3 demo.py
```

或者通过启动脚本选择演示模式：

```bash
./start.sh
# 选择运行演示模式
```

## 🔧 Cursor IDE配置

要在Cursor IDE中直接使用MySQL MCP服务器，请查看详细配置指南：

👉 **[CURSOR_SETUP.md](CURSOR_SETUP.md)** - 完整的Cursor配置步骤

### 快速配置

1. 打开Cursor设置 (`Cmd/Ctrl + ,`)
2. 搜索 "MCP" 
3. 添加MCP服务器：

```
Name: mysql-mcp-server
Command: python3
Arguments: /Users/colin/Depots/projects/mcp/mysql/mysql_mcp_server.py
Working Directory: /Users/colin/Depots/projects/mcp/mysql
```

4. 重启Cursor

### 在Cursor中使用

配置成功后，在Cursor聊天中直接使用：

```
用户：请帮我查看数据库中的所有表
AI：使用 show_tables 工具...

数据库中的表：
- users
- orders
- products
```

## 🛠️ 工具说明

### connect_database

**功能**: 连接MySQL数据库

**参数**:
- `host` (必需): MySQL服务器地址
- `port` (可选): 端口号，默认3306
- `database` (必需): 数据库名称
- `username` (必需): 用户名
- `password` (必需): 密码
- `charset` (可选): 字符集，默认utf8mb4

**返回**: 连接状态和数据库基本信息

### execute_query

**功能**: 执行SELECT查询

**参数**:
- `query` (必需): SELECT查询语句
- `max_rows` (可选): 最大返回行数，默认1000

**限制**: 只能执行SELECT查询语句

**返回**: 查询结果的格式化表格

### describe_table

**功能**: 获取指定表的结构信息

**参数**:
- `table_name` (必需): 表名

**返回**: 表的列信息、索引信息等

### show_tables

**功能**: 显示当前数据库中的所有表

**参数**: 无

**返回**: 数据库中所有表的列表

### execute_write_operation

**功能**: 执行写操作（INSERT、UPDATE、DELETE等）

**参数**:
- `sql` (必需): 写操作SQL语句

**安全特性**:
- 检测写操作语句
- 要求用户明确确认
- 显示危险操作警告

**返回**: 确认信息，要求用户回复"确认执行"

### confirmed_write_operation

**功能**: 确认执行写操作

**参数**:
- `sql` (必需): 确认要执行的写操作SQL语句

**要求**: 只有在用户明确回复"确认执行"后才能使用

**返回**: 操作执行结果

### get_database_info

**功能**: 获取当前数据库的基本信息和统计信息

**参数**: 无

**返回**: MySQL版本、数据库名、用户、表统计、存储大小等

## 📝 使用示例

### 1. 连接数据库

```json
{
  "tool": "connect_database",
  "arguments": {
    "host": "localhost",
    "port": 3306,
    "database": "myapp_dev",
    "username": "developer",
    "password": "dev123"
  }
}
```

### 2. 查看数据库表

```json
{
  "tool": "show_tables"
}
```

### 3. 查看表结构

```json
{
  "tool": "describe_table",
  "arguments": {
    "table_name": "users"
  }
}
```

### 4. 执行查询

```json
{
  "tool": "execute_query",
  "arguments": {
    "query": "SELECT * FROM users WHERE status = 'active' LIMIT 10",
    "max_rows": 10
  }
}
```

### 5. 执行写操作（需要确认）

```json
{
  "tool": "execute_write_operation",
  "arguments": {
    "sql": "INSERT INTO users (name, email, status) VALUES ('张三', 'zhangsan@example.com', 'active')"
  }
}
```

收到确认提示后，使用：

```json
{
  "tool": "confirmed_write_operation",
  "arguments": {
    "sql": "INSERT INTO users (name, email, status) VALUES ('张三', 'zhangsan@example.com', 'active')"
  }
}
```

### 6. 获取数据库信息

```json
{
  "tool": "get_database_info"
}
```

## ⚠️ 安全注意事项

### 开发环境专用

- ✅ **推荐用途**: 开发、测试、调试
- ❌ **禁止用途**: 生产环境、数据迁移、线上维护

### 数据安全

1. **备份重要数据**: 执行写操作前确保数据已备份
2. **使用测试数据库**: 建议使用专门的开发/测试数据库
3. **权限控制**: 使用具有适当权限的数据库用户
4. **定期检查**: 定期检查数据库操作日志

### 写操作安全流程

1. **初步执行**: 使用`execute_write_operation`工具
2. **确认警告**: 阅读显示的安全警告
3. **明确确认**: 在客户端中明确回复"确认执行"
4. **执行操作**: 使用`confirmed_write_operation`工具
5. **验证结果**: 检查操作结果和影响

### 网络安全

- 仅在受信任的网络环境中使用
- 避免在公共网络中使用
- 使用强密码和SSL连接（如果支持）

## 🔧 配置说明

### 环境变量

您可以使用环境变量来配置数据库连接：

```bash
export MYSQL_HOST=localhost
export MYSQL_PORT=3306
export MYSQL_DATABASE=myapp_dev
export MYSQL_USERNAME=developer
export MYSQL_PASSWORD=dev123
```

### 配置文件

创建`.env`文件来管理敏感信息：

```env
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_DATABASE=myapp_dev
MYSQL_USERNAME=developer
MYSQL_PASSWORD=dev123
```

## ❓ 常见问题

### Q: 连接失败怎么办？

**A**: 检查以下项目：
- MySQL服务是否正在运行
- 主机地址和端口是否正确
- 用户名和密码是否正确
- 网络连接是否正常
- 防火墙设置是否正确

### Q: 查询返回大量数据怎么办？

**A**: 
- 使用`LIMIT`子句限制结果数量
- 使用`max_rows`参数限制返回行数
- 考虑添加WHERE条件缩小查询范围

### Q: 如何查看表的详细结构？

**A**: 使用`describe_table`工具，它会显示：
- 所有列的信息（字段名、类型、是否为空等）
- 主键和索引信息
- 列的默认值和额外信息

### Q: 写操作确认流程是怎样的？

**A**: 
1. 第一次调用`execute_write_operation`会返回确认信息
2. 用户需要在客户端明确回复"确认执行"
3. 然后使用`confirmed_write_operation`执行实际操作

### Q: 可以同时连接多个数据库吗？

**A**: 当前版本不支持同时连接多个数据库。如果需要切换数据库，请重新使用`connect_database`工具连接。

### Q: 如何处理连接超时？

**A**: 
- 检查数据库服务器性能
- 优化查询语句
- 增加连接超时时间设置
- 检查网络延迟

### Q: 支持哪些MySQL版本？

**A**: 支持MySQL 5.7+和MariaDB 10.2+。建议使用较新版本以获得最佳兼容性。

### Q: 演示模式和真实模式有什么区别？

**A**: 
- **演示模式**: 无需安装依赖，使用模拟数据展示功能
- **真实模式**: 需要安装依赖，连接真实数据库执行操作
- 两者功能接口相同，演示模式用于学习和体验

### Q: 如何从演示模式切换到真实模式？

**A**: 
1. 安装依赖：`pip3 install mysql-connector-python pydantic`
2. 运行：`python3 mysql_mcp_server.py`
3. 通过MCP客户端连接使用真实功能

## 📞 技术支持

如果您在使用过程中遇到问题：

1. 首先查看此文档的常见问题部分
2. 运行演示模式了解工具工作方式
3. 检查MySQL服务器的错误日志
4. 确认数据库用户权限设置
5. 验证网络连接和防火墙设置

## 📝 更新日志

### v1.0.0
- 初始版本发布
- 支持MySQL连接和基本查询
- 实现写操作确认机制
- 添加安全警告功能
- 支持表结构查看和数据库信息获取
- 新增演示模式，无需依赖即可体验功能

---

**重要提醒**: 请始终遵守数据安全最佳实践，确保在合适的开发环境中使用此工具。
