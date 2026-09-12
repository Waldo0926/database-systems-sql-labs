# Design notes

## Why SQL Server / T-SQL?

The original lab reports explicitly identified SQL Server as the target environment and used SQL Server-specific concepts such as `inserted`, `deleted`, `DECLARE @variable`, and stored procedures. Some archived snippets also contained MySQL-style syntax. The portfolio version resolves that inconsistency by targeting Microsoft SQL Server only.

## Two schemas instead of three disconnected lab databases

The original labs used databases such as `SY1`, `SY2`, and `SY3`. For a portfolio repository, a single `DatabaseSystemsLabs` database with two schemas is easier to understand and run:

- `spj`: supplier/part/project exercises;
- `Academic`: student/course/enrollment exercises.

This keeps the conceptual separation without duplicating setup.

## Data corrections

The supplier/part/project source material referenced supplier `S1` in `Supply` rows without inserting the supplier itself. The portfolio seed data restores the missing supplier so referential integrity can be enforced.

The later Lab 1 questions also ask about where parts are produced. Therefore the portfolio `Part` table keeps a `City` attribute consistently instead of adding and then immediately dropping it.

Additional academic sample rows were added so grade-distribution and weighted-average examples have meaningful output. They are demonstration data, not personal records.

## Integrity: declarative constraints first

The coursework asked for a trigger that deletes a student's enrollments when the student is deleted. The portfolio implementation uses:

```sql
FOREIGN KEY (...) REFERENCES Academic.Student(...)
    ON DELETE CASCADE
```

This is intentionally different from the original exercise. Referential actions are clearer and safer than a trigger when the requirement is purely referential integrity.

Triggers are still used where they add actual derived-data behavior: maintaining grade distributions, course averages, and weighted averages.

## Multi-row-safe triggers

A common beginner error is assuming `inserted` and `deleted` contain exactly one row. SQL Server triggers are statement-level; both pseudo-tables may contain many rows.

`Academic.trg_Enrollment_RebuildMetrics` first collects distinct affected course and student IDs and then recalculates only those aggregates using set-based statements.

## Cursor exercises

Cursors are included because they were a Lab 3 learning objective. For ordinary aggregate and transformation workloads, set-based SQL is normally preferable because it is more concise and usually more efficient.

The repository therefore separates:

- `06_stored_procedures.sql` — preferred set-based versions;
- `07_cursor_exercises.sql` — correct cursor-based learning versions.

## Public-repository scope

Original `.doc`, `.docx`, `.pdf`, `.ppt`, exam-review files, student IDs, and teacher-provided materials are deliberately excluded. This reduces privacy and copyright risk and keeps the repository focused on demonstrable technical work.
