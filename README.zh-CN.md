# 数据库系统 SQL 实验

这是一个基于本科 **《数据库系统概论》** 课程实验重新整理的 SQL Server 作品集项目。

原课程实验覆盖交互式 SQL、关系查询、完整性约束、触发器、存储过程和游标。本仓库没有直接把旧作业原封不动上传，而是将代码统一为 **Microsoft SQL Server / T-SQL**，并修复了原实验材料中的语法混用、命名不一致和不完整语句。

> **说明：** 本仓库是对旧课程作业的回顾性整理与重构，并不表示所有代码在当年提交时就已经是当前形式。

## 主要内容

- 主键、外键、`CHECK` 约束和参照完整性
- DDL / DML 基础操作
- 单表查询、连接查询、嵌套查询、聚合查询
- `NOT EXISTS` 实现关系除法类查询
- 视图与索引
- 支持多行操作的 SQL Server Trigger
- 自动维护课程平均分、成绩区间统计、百分比和学生加权平均分
- 基于集合操作的存储过程
- 为课程学习目的保留的 Cursor 版本
- 可执行的一致性验证脚本

## 目录

```text
database-systems-sql-labs/
├── README.md
├── README.zh-CN.md
├── LICENSE
├── run_all.sql
├── sql/
│   ├── 00_create_database.sql
│   ├── 01_schema.sql
│   ├── 02_seed_data.sql
│   ├── 03_lab1_queries.sql
│   ├── 04_views_indexes.sql
│   ├── 05_triggers.sql
│   ├── 06_stored_procedures.sql
│   ├── 07_cursor_exercises.sql
│   └── 08_demo.sql
├── tests/
│   └── verification.sql
└── docs/
    ├── coursework-map.md
    └── design-notes.md
```

## 如何运行

推荐 Microsoft SQL Server 2019 或更新版本。

如果安装了 `sqlcmd`，在仓库根目录执行：

```bash
sqlcmd -S localhost -E -i run_all.sql
```

也可以在 SSMS、VS Code 的 Microsoft SQL Server 工具或其他支持 SQL Server 的编辑器中按照文件编号顺序执行。

## 为什么重新整理？

原实验代码中存在 SQL 方言混用，例如 MySQL 风格的：

```sql
FOR EACH ROW
SHOW CREATE DATABASE
```

同时又使用了 SQL Server 的：

```sql
inserted
deleted
DECLARE @variable
```

因此公开 GitHub 仓库时直接上传原始文件并不合适。本版本主要完成了以下修复：

- 全部统一为 T-SQL；
- 修复 View、Index 和 Trigger 中的对象名错误；
- 用明确的 `JOIN` 替代不正确的笛卡尔连接；
- Trigger 改为支持一次影响多行数据的集合式实现；
- 学生删除后的选课数据清理使用外键 `ON DELETE CASCADE`；
- Cursor 作为课程知识点保留，同时补充更适合实际工程的集合式实现。

详见 [`docs/design-notes.md`](docs/design-notes.md)。

## 与原课程实验对应关系

| 原实验 | 主要知识点 | 当前仓库 |
| --- | --- | --- |
| 实验一 | SQL、DDL/DML、查询、索引、视图 | `01`–`04` |
| 实验二 | 完整性控制、触发器 | `01`、`05` |
| 实验三 | 存储过程、游标 | `06`、`07` |

## 公开仓库隐私处理

本仓库不会上传原始实验报告、教师课件、复习资料、学号等个人信息或可能属于第三方的课程材料，只保留经过重新整理的代码和说明文档。

## License

MIT License。
