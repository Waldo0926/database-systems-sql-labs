/*
  07_cursor_exercises.sql
  Correct cursor-based implementations retained for the original Lab 3
  learning objective. Prefer the set-based procedures in 06 for normal use.
*/

USE DatabaseSystemsLabs;
GO

CREATE OR ALTER PROCEDURE Academic.usp_GradeDistribution_Cursor
    @CourseNo VARCHAR(4)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @Grade SMALLINT,
        @N0 INT = 0,
        @N60 INT = 0,
        @N70 INT = 0,
        @N80 INT = 0,
        @N90 INT = 0,
        @Total INT;

    DECLARE grade_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT Grade
        FROM Academic.Enrollment
        WHERE Cno = @CourseNo;

    OPEN grade_cursor;
    FETCH NEXT FROM grade_cursor INTO @Grade;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF @Grade >= 90      SET @N90 += 1;
        ELSE IF @Grade >= 80 SET @N80 += 1;
        ELSE IF @Grade >= 70 SET @N70 += 1;
        ELSE IF @Grade >= 60 SET @N60 += 1;
        ELSE                 SET @N0 += 1;

        FETCH NEXT FROM grade_cursor INTO @Grade;
    END;

    CLOSE grade_cursor;
    DEALLOCATE grade_cursor;

    SET @Total = @N0 + @N60 + @N70 + @N80 + @N90;

    DELETE FROM Academic.GradeDistribution WHERE Cno = @CourseNo;

    IF @Total > 0
    BEGIN
        INSERT INTO Academic.GradeDistribution
            (Cno, BandOrder, Division, StudentCount, Percentage)
        VALUES
            (@CourseNo, 1, '[0,60)',   @N0,  CAST(100.0 * @N0  / @Total AS DECIMAL(6,2))),
            (@CourseNo, 2, '[60,70)',  @N60, CAST(100.0 * @N60 / @Total AS DECIMAL(6,2))),
            (@CourseNo, 3, '[70,80)',  @N70, CAST(100.0 * @N70 / @Total AS DECIMAL(6,2))),
            (@CourseNo, 4, '[80,90)',  @N80, CAST(100.0 * @N80 / @Total AS DECIMAL(6,2))),
            (@CourseNo, 5, '[90,100]', @N90, CAST(100.0 * @N90 / @Total AS DECIMAL(6,2)));
    END;

    SELECT *
    FROM Academic.GradeDistribution
    WHERE Cno = @CourseNo
    ORDER BY BandOrder;
END;
GO

CREATE OR ALTER PROCEDURE Academic.usp_CourseAverages_Cursor
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @CourseNo VARCHAR(4),
        @Average DECIMAL(6,2);

    DECLARE course_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT DISTINCT Cno
        FROM Academic.Enrollment;

    DELETE FROM Academic.CourseAverage;

    OPEN course_cursor;
    FETCH NEXT FROM course_cursor INTO @CourseNo;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @Average = CAST(AVG(CAST(Grade AS DECIMAL(10,2))) AS DECIMAL(6,2))
        FROM Academic.Enrollment
        WHERE Cno = @CourseNo;

        INSERT INTO Academic.CourseAverage (Cno, AvgGrade)
        VALUES (@CourseNo, @Average);

        FETCH NEXT FROM course_cursor INTO @CourseNo;
    END;

    CLOSE course_cursor;
    DEALLOCATE course_cursor;

    SELECT ca.Cno, c.Cname, ca.AvgGrade
    FROM Academic.CourseAverage AS ca
    JOIN Academic.Course AS c ON c.Cno = ca.Cno
    ORDER BY ca.Cno;
END;
GO

CREATE OR ALTER PROCEDURE Academic.usp_GradeLevels_Cursor
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE
        @StudentNo VARCHAR(11),
        @CourseNo VARCHAR(4),
        @Grade SMALLINT,
        @Letter CHAR(1);

    DECLARE enrollment_cursor CURSOR LOCAL FAST_FORWARD FOR
        SELECT Sno, Cno, Grade
        FROM Academic.Enrollment
        ORDER BY Sno, Cno;

    DELETE FROM Academic.GradeLevel;

    OPEN enrollment_cursor;
    FETCH NEXT FROM enrollment_cursor INTO @StudentNo, @CourseNo, @Grade;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @Letter = CASE
            WHEN @Grade >= 90 THEN 'A'
            WHEN @Grade >= 80 THEN 'B'
            WHEN @Grade >= 70 THEN 'C'
            WHEN @Grade >= 60 THEN 'D'
            ELSE 'E'
        END;

        INSERT INTO Academic.GradeLevel (Sno, Cno, GradeLetter)
        VALUES (@StudentNo, @CourseNo, @Letter);

        FETCH NEXT FROM enrollment_cursor INTO @StudentNo, @CourseNo, @Grade;
    END;

    CLOSE enrollment_cursor;
    DEALLOCATE enrollment_cursor;

    SELECT * FROM Academic.GradeLevel ORDER BY Sno, Cno;
END;
GO
