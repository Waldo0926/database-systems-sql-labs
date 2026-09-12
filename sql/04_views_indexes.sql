/*
  04_views_indexes.sql
  Practical index and view examples derived from Lab 1.
*/

USE DatabaseSystemsLabs;
GO

/* ---------- Indexes ---------- */
DROP INDEX IF EXISTS IX_Supplier_City ON spj.Supplier;
DROP INDEX IF EXISTS IX_Supply_ProjectPart ON spj.Supply;
GO

CREATE INDEX IX_Supplier_City
    ON spj.Supplier (City)
    INCLUDE (Sname, Status);

CREATE INDEX IX_Supply_ProjectPart
    ON spj.Supply (Jno, Pno)
    INCLUDE (Sno, Qty);
GO

/* ---------- View ---------- */
CREATE OR ALTER VIEW spj.vw_SupplyDetail
AS
SELECT
    x.Sno,
    s.Sname,
    s.City AS SupplierCity,
    x.Pno,
    p.Pname,
    p.Color,
    p.Weight,
    p.City AS PartCity,
    x.Jno,
    j.Jname,
    j.City AS ProjectCity,
    x.Qty
FROM spj.Supply AS x
JOIN spj.Supplier AS s ON s.Sno = x.Sno
JOIN spj.Part AS p ON p.Pno = x.Pno
JOIN spj.Project AS j ON j.Jno = x.Jno;
GO

/* Example view queries. */
SELECT Qty
FROM spj.vw_SupplyDetail
WHERE Sno = 'S1'
ORDER BY Jno, Pno;

SELECT Pno, Pname, Qty
FROM spj.vw_SupplyDetail
WHERE Jno = 'J1'
ORDER BY Pno, Sno;
GO
