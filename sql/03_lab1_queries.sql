/*
  03_lab1_queries.sql
  Lab 1 query practice: DML, single-table queries, joins, nested queries,
  aggregation, and relational division.
*/

USE DatabaseSystemsLabs;
GO

/* ---------- DML examples (rolled back so the seed stays reproducible) ---------- */
BEGIN TRANSACTION;

UPDATE spj.Part
SET Color = N'蓝'
WHERE Color = N'红';

UPDATE spj.Supply
SET Sno = 'S3'
WHERE Sno = 'S5' AND Jno = 'J4' AND Pno = 'P6';

ROLLBACK TRANSACTION;
GO

/* ---------- Single-table queries ---------- */
-- 1. Supplier names and cities.
SELECT Sname, City
FROM spj.Supplier
ORDER BY Sno;

-- 2. Part names, colors, and weights.
SELECT Pname, Color, Weight
FROM spj.Part
ORDER BY Pno;

-- 3. Suppliers that supply project J1.
SELECT DISTINCT Sno
FROM spj.Supply
WHERE Jno = 'J1'
ORDER BY Sno;

-- 4. Suppliers that supply part P1 to project J1.
SELECT DISTINCT Sno
FROM spj.Supply
WHERE Jno = 'J1' AND Pno = 'P1'
ORDER BY Sno;
GO

/* ---------- Join queries ---------- */
-- 5. Suppliers providing red parts to project J1.
SELECT DISTINCT s.Sno, s.Sname
FROM spj.Supply AS x
JOIN spj.Supplier AS s ON s.Sno = x.Sno
JOIN spj.Part AS p ON p.Pno = x.Pno
WHERE x.Jno = 'J1'
  AND p.Color = N'红'
ORDER BY s.Sno;

-- 6. Parts used by project J2 and their total quantities.
SELECT p.Pno, p.Pname, SUM(x.Qty) AS TotalQuantity
FROM spj.Supply AS x
JOIN spj.Part AS p ON p.Pno = x.Pno
WHERE x.Jno = 'J2'
GROUP BY p.Pno, p.Pname
ORDER BY p.Pno;

-- 7. Projects using parts produced in Shanghai.
SELECT DISTINCT j.Jno, j.Jname
FROM spj.Supply AS x
JOIN spj.Part AS p ON p.Pno = x.Pno
JOIN spj.Project AS j ON j.Jno = x.Jno
WHERE p.City = N'上海'
ORDER BY j.Jno;
GO

/* ---------- Nested / anti-join queries ---------- */
-- 8. Suppliers providing red parts to project J1 (nested-query version).
SELECT DISTINCT Sno
FROM spj.Supply
WHERE Jno = 'J1'
  AND Pno IN
  (
      SELECT Pno
      FROM spj.Part
      WHERE Color = N'红'
  )
ORDER BY Sno;

-- 9. Projects that do not use any red part supplied by a Tianjin supplier.
SELECT j.Jno, j.Jname
FROM spj.Project AS j
WHERE NOT EXISTS
(
    SELECT 1
    FROM spj.Supply AS x
    JOIN spj.Supplier AS s ON s.Sno = x.Sno
    JOIN spj.Part AS p ON p.Pno = x.Pno
    WHERE x.Jno = j.Jno
      AND s.City = N'天津'
      AND p.Color = N'红'
)
ORDER BY j.Jno;

-- 10. Projects that use every distinct part supplied by S1.
--     This is a relational-division pattern using double NOT EXISTS.
SELECT j.Jno, j.Jname
FROM spj.Project AS j
WHERE NOT EXISTS
(
    SELECT 1
    FROM
    (
        SELECT DISTINCT Pno
        FROM spj.Supply
        WHERE Sno = 'S1'
    ) AS s1parts
    WHERE NOT EXISTS
    (
        SELECT 1
        FROM spj.Supply AS x
        WHERE x.Jno = j.Jno
          AND x.Pno = s1parts.Pno
    )
)
ORDER BY j.Jno;

-- 11. All parts supplied by Shanghai suppliers.
SELECT DISTINCT x.Pno
FROM spj.Supply AS x
WHERE x.Sno IN
(
    SELECT Sno
    FROM spj.Supplier
    WHERE City = N'上海'
)
ORDER BY x.Pno;

-- 12. Projects that use no part produced in Tianjin.
SELECT j.Jno, j.Jname
FROM spj.Project AS j
WHERE NOT EXISTS
(
    SELECT 1
    FROM spj.Supply AS x
    JOIN spj.Part AS p ON p.Pno = x.Pno
    WHERE x.Jno = j.Jno
      AND p.City = N'天津'
)
ORDER BY j.Jno;
GO
