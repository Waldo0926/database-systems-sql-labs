/*
  05_triggers.sql
  Lab 2 refactor: a set-based, multi-row-safe trigger maintains derived metrics.
*/

USE DatabaseSystemsLabs;
GO

CREATE OR ALTER TRIGGER Academic.trg_Enrollment_RebuildMetrics
ON Academic.Enrollment
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @AffectedCourses TABLE
    (
        Cno VARCHAR(4) PRIMARY KEY
    );

    DECLARE @AffectedStudents TABLE
    (
        Sno VARCHAR(11) PRIMARY KEY
    );

    INSERT INTO @AffectedCourses (Cno)
    SELECT Cno FROM inserted
    UNION
    SELECT Cno FROM deleted;

    INSERT INTO @AffectedStudents (Sno)
    SELECT Sno FROM inserted
    UNION
    SELECT Sno FROM deleted;

    /* ----- Course average ----- */
    DELETE ca
    FROM Academic.CourseAverage AS ca
    JOIN @AffectedCourses AS a ON a.Cno = ca.Cno;

    INSERT INTO Academic.CourseAverage (Cno, AvgGrade)
    SELECT
        e.Cno,
        CAST(AVG(CAST(e.Grade AS DECIMAL(10,2))) AS DECIMAL(6,2))
    FROM Academic.Enrollment AS e
    JOIN @AffectedCourses AS a ON a.Cno = e.Cno
    GROUP BY e.Cno;

    /* ----- Grade-band counts and percentages ----- */
    DELETE gd
    FROM Academic.GradeDistribution AS gd
    JOIN @AffectedCourses AS a ON a.Cno = gd.Cno;

    ;WITH Bands AS
    (
        SELECT 1 AS BandOrder, '[0,60)' AS Division, 0 AS MinGrade, 60 AS MaxExclusive
        UNION ALL SELECT 2, '[60,70)', 60, 70
        UNION ALL SELECT 3, '[70,80)', 70, 80
        UNION ALL SELECT 4, '[80,90)', 80, 90
        UNION ALL SELECT 5, '[90,100]', 90, 101
    ),
    Totals AS
    (
        SELECT e.Cno, COUNT(*) AS TotalStudents
        FROM Academic.Enrollment AS e
        JOIN @AffectedCourses AS a ON a.Cno = e.Cno
        GROUP BY e.Cno
    )
    INSERT INTO Academic.GradeDistribution
        (Cno, BandOrder, Division, StudentCount, Percentage)
    SELECT
        t.Cno,
        b.BandOrder,
        b.Division,
        SUM(CASE WHEN e.Grade >= b.MinGrade AND e.Grade < b.MaxExclusive THEN 1 ELSE 0 END),
        CAST(
            100.0 * SUM(CASE WHEN e.Grade >= b.MinGrade AND e.Grade < b.MaxExclusive THEN 1 ELSE 0 END)
            / NULLIF(t.TotalStudents, 0)
            AS DECIMAL(6,2)
        )
    FROM Totals AS t
    CROSS JOIN Bands AS b
    JOIN Academic.Enrollment AS e ON e.Cno = t.Cno
    GROUP BY t.Cno, t.TotalStudents, b.BandOrder, b.Division, b.MinGrade, b.MaxExclusive;

    /* ----- Student credit-weighted average ----- */
    DELETE swa
    FROM Academic.StudentWeightedAverage AS swa
    JOIN @AffectedStudents AS a ON a.Sno = swa.Sno;

    INSERT INTO Academic.StudentWeightedAverage (Sno, WeightedAverage)
    SELECT
        e.Sno,
        CAST(
            SUM(CAST(e.Grade AS DECIMAL(12,2)) * c.Ccredit)
            / NULLIF(SUM(c.Ccredit), 0)
            AS DECIMAL(6,2)
        )
    FROM Academic.Enrollment AS e
    JOIN Academic.Course AS c ON c.Cno = e.Cno
    JOIN @AffectedStudents AS a ON a.Sno = e.Sno
    GROUP BY e.Sno;
END;
GO

/* Seed data existed before the trigger was created. A no-op update initializes
   the derived tables and also demonstrates that the trigger handles many rows. */
UPDATE Academic.Enrollment
SET Grade = Grade;
GO
