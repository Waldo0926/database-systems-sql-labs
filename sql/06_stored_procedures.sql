/*
  06_stored_procedures.sql
  Preferred set-based stored procedures for the Lab 3 requirements.
*/

USE DatabaseSystemsLabs;
GO

CREATE OR ALTER PROCEDURE Academic.usp_GradeDistribution
    @CourseNo VARCHAR(4)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Academic.Course WHERE Cno = @CourseNo)
        THROW 50001, 'Course does not exist.', 1;

    ;WITH Bands AS
    (
        SELECT 1 AS BandOrder, '[0,60)' AS Division, 0 AS MinGrade, 60 AS MaxExclusive
        UNION ALL SELECT 2, '[60,70)', 60, 70
        UNION ALL SELECT 3, '[70,80)', 70, 80
        UNION ALL SELECT 4, '[80,90)', 80, 90
        UNION ALL SELECT 5, '[90,100]', 90, 101
    ),
    Total AS
    (
        SELECT COUNT(*) AS N
        FROM Academic.Enrollment
        WHERE Cno = @CourseNo
    )
    SELECT
        @CourseNo AS Cno,
        b.Division,
        COUNT(e.Sno) AS StudentCount,
        CAST(100.0 * COUNT(e.Sno) / NULLIF(t.N, 0) AS DECIMAL(6,2)) AS Percentage
    FROM Bands AS b
    CROSS JOIN Total AS t
    LEFT JOIN Academic.Enrollment AS e
        ON e.Cno = @CourseNo
       AND e.Grade >= b.MinGrade
       AND e.Grade < b.MaxExclusive
    GROUP BY b.BandOrder, b.Division, t.N
    ORDER BY b.BandOrder;
END;
GO

CREATE OR ALTER PROCEDURE Academic.usp_CourseAverage
    @CourseNo VARCHAR(4)
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM Academic.Course WHERE Cno = @CourseNo)
        THROW 50002, 'Course does not exist.', 1;

    SELECT
        c.Cno,
        c.Cname,
        CAST(AVG(CAST(e.Grade AS DECIMAL(10,2))) AS DECIMAL(6,2)) AS AvgGrade
    FROM Academic.Course AS c
    LEFT JOIN Academic.Enrollment AS e ON e.Cno = c.Cno
    WHERE c.Cno = @CourseNo
    GROUP BY c.Cno, c.Cname;
END;
GO

CREATE OR ALTER PROCEDURE Academic.usp_RefreshGradeLevels
    @StudentNo VARCHAR(11) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @StudentNo IS NOT NULL
       AND NOT EXISTS (SELECT 1 FROM Academic.Student WHERE Sno = @StudentNo)
        THROW 50003, 'Student does not exist.', 1;

    DELETE gl
    FROM Academic.GradeLevel AS gl
    WHERE @StudentNo IS NULL OR gl.Sno = @StudentNo;

    INSERT INTO Academic.GradeLevel (Sno, Cno, GradeLetter)
    SELECT
        e.Sno,
        e.Cno,
        CASE
            WHEN e.Grade >= 90 THEN 'A'
            WHEN e.Grade >= 80 THEN 'B'
            WHEN e.Grade >= 70 THEN 'C'
            WHEN e.Grade >= 60 THEN 'D'
            ELSE 'E'
        END
    FROM Academic.Enrollment AS e
    WHERE @StudentNo IS NULL OR e.Sno = @StudentNo;
END;
GO
