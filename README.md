# Database Systems SQL Labs

[![Type](https://img.shields.io/badge/Type-Coursework-2563eb?style=for-the-badge)](#)
[![Tech](https://img.shields.io/badge/Tech-T--SQL-7c3aed?style=for-the-badge)](#)
[![License](https://img.shields.io/badge/License-MIT-16a34a?style=for-the-badge)](LICENSE)

[简体中文](README.zh-CN.md)


A cleaned and reproducible SQL Server portfolio project based on undergraduate coursework in **Database Systems (数据库系统概论)**.

The original coursework covered interactive SQL, relational queries, integrity constraints, triggers, stored procedures, and cursors. This repository reorganizes those exercises into a consistent **T-SQL / Microsoft SQL Server** implementation and corrects syntax and design issues in the original lab files.

> **Portfolio note:** this is a retrospective refactor of coursework, not a claim that every script existed in this exact form when the course was originally completed.

## Highlights

- Relational schema design with primary keys, foreign keys, `CHECK` constraints, and referential actions
- DDL and DML operations
- Single-table, join, nested, aggregate, and relational-division-style queries
- Views and practical indexes
- Multi-row-safe SQL Server triggers
- Automatically maintained course averages, grade distributions, percentages, and weighted averages
- Stored procedures using set-based SQL
- Cursor-based versions retained as educational exercises, with modern alternatives documented
- Verification script with executable consistency checks

## Repository structure

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

## Database model

Two schemas keep the course exercises logically separated:

- `spj` — supplier / part / project exercises from the introductory SQL lab
- `Academic` — student / course / enrollment exercises used for triggers and stored procedures

### `spj` schema

```text
Supplier 1 ───< Supply >─── 1 Part
                  │
                  └──────── 1 Project
```

### `Academic` schema

```text
Student 1 ───< Enrollment >─── 1 Course
   │                                  │
   └── StudentWeightedAverage         ├── CourseAverage
                                      └── GradeDistribution
```

## Requirements

- Microsoft SQL Server 2019+ recommended
- SQL Server Management Studio, VS Code with Microsoft SQL Server tooling, or the `sqlcmd` command-line client

The scripts use SQL Server batch separators (`GO`) and T-SQL features such as `inserted` / `deleted` trigger tables.

## Run

### Option 1 — run all scripts with `sqlcmd`

From the repository root:

```bash
sqlcmd -S localhost -E -i run_all.sql
```

For SQL authentication:

```bash
sqlcmd -S localhost -U <username> -P '<password>' -i run_all.sql
```

### Option 2 — run in an SQL editor

Execute these files in order:

1. `sql/00_create_database.sql`
2. `sql/01_schema.sql`
3. `sql/02_seed_data.sql`
4. `sql/03_lab1_queries.sql`
5. `sql/04_views_indexes.sql`
6. `sql/05_triggers.sql`
7. `sql/06_stored_procedures.sql`
8. `sql/07_cursor_exercises.sql`
9. `sql/08_demo.sql`
10. `tests/verification.sql`

## What was corrected from the original coursework?

The archived lab material mixed SQL dialects in places—for example, MySQL-style `FOR EACH ROW` / `SHOW CREATE DATABASE` appeared alongside SQL Server `inserted` / `deleted` pseudo-tables and T-SQL variables. There were also naming mismatches and incomplete statements.

This portfolio version therefore:

- standardizes everything on SQL Server / T-SQL;
- replaces invalid cross joins and incomplete view definitions with explicit joins;
- uses consistent object names;
- makes trigger logic set-based and safe for multi-row statements;
- uses declarative `ON DELETE CASCADE` for student-enrollment cleanup instead of a fragile row-by-row delete trigger;
- preserves cursor exercises for learning while also providing preferred set-based procedures.

See [`docs/design-notes.md`](docs/design-notes.md) for details.

## Example concepts

### Relational division with `NOT EXISTS`

The Lab 1 exercises include the classic query “find projects that use every part supplied by supplier S1.” The refactored solution uses a double `NOT EXISTS`, avoiding the incorrect shortcut of comparing only part counts.

### Trigger-maintained aggregates

`Academic.trg_Enrollment_RebuildMetrics` reacts to inserts, updates, and deletes on enrollment records and refreshes only the affected courses and students. It maintains:

- grade-band counts and percentages;
- average grade by course;
- credit-weighted average by student.

### Cursor vs. set-based SQL

The course included cursor practice. `sql/07_cursor_exercises.sql` keeps working cursor implementations, but the repository also documents why set-based SQL is normally preferred for production workloads.

## Verification

`tests/verification.sql` checks that:

- the supply-detail view matches the base supply table row count;
- stored course averages equal direct calculations;
- grade-distribution totals equal enrollment totals;
- grade percentages sum to approximately 100%;
- weighted averages equal direct credit-weighted calculations;
- grade letters are valid and complete.

A successful run prints:

```text
All verification checks passed.
```

## Coursework mapping

| Original lab | Topic | Portfolio implementation |
| --- | --- | --- |
| Lab 1 | Interactive SQL, DDL/DML, queries, indexes, views | `01`–`04` |
| Lab 2 | Integrity constraints and triggers | `01`, `05` |
| Lab 3 | Stored procedures and cursors | `06`, `07` |

More detail: [`docs/coursework-map.md`](docs/coursework-map.md).

## Privacy and source-material policy

The repository intentionally does **not** include original submitted reports, teacher-provided slides, exam-review PDFs, student identifiers, or other third-party course materials. Only rewritten code and documentation suitable for a public portfolio are included.

## License

MIT License. See [`LICENSE`](LICENSE).
