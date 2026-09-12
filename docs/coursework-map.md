# Coursework map

This document maps the original **Database Systems (数据库系统概论)** labs to the cleaned portfolio implementation.

## Lab 1 — Interactive SQL operations

Original objectives:

- create and modify relational tables;
- insert, update, and delete data;
- write single-table queries;
- write join queries;
- write nested queries;
- create and remove indexes;
- create, query, and remove views.

Portfolio implementation:

- `sql/01_schema.sql`
- `sql/02_seed_data.sql`
- `sql/03_lab1_queries.sql`
- `sql/04_views_indexes.sql`

Notable correction: the original “projects using every part supplied by S1” query compared only counts. The portfolio version uses the correct double-`NOT EXISTS` relational-division pattern.

## Lab 2 — Integrity constraints and triggers

Original objectives:

- enforce valid student/course/enrollment data;
- maintain grade-distribution counts;
- maintain average grades;
- remove enrollments when a student is deleted;
- calculate grade-band percentages;
- calculate credit-weighted averages.

Portfolio implementation:

- integrity constraints: `sql/01_schema.sql`
- aggregate-maintenance trigger: `sql/05_triggers.sql`
- student/enrollment cleanup: declarative `ON DELETE CASCADE` in `sql/01_schema.sql`

The trigger is deliberately set-based. SQL Server triggers fire once per statement, not once per row, so production-quality trigger code must correctly handle multiple rows in `inserted` and `deleted`.

## Lab 3 — Stored procedures and cursors

Original objectives:

- count grade bands using stored procedures/cursors;
- calculate course averages;
- convert numeric grades into A–E grade levels.

Portfolio implementation:

- preferred set-based procedures: `sql/06_stored_procedures.sql`
- cursor exercises: `sql/07_cursor_exercises.sql`

Both are included so the repository demonstrates the original learning objective while also showing the preferred engineering approach.
