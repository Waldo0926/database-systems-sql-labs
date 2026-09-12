/*
  verification.sql
  Lightweight executable checks for the portfolio database.
*/

USE DatabaseSystemsLabs;
GO

SET NOCOUNT ON;

/* Ensure grade-level output exists for verification. */
EXEC Academic.usp_RefreshGradeLevels;

/* 1. The detail view must preserve the Supply row count. */
IF (SELECT COUNT(*) FROM spj.vw_SupplyDetail)
   <> (SELECT COUNT(*) FROM spj.Supply)
    THROW 51001, 'Verification failed: supply-detail view row count mismatch.', 1;

/* 2. Trigger-maintained course averages must equal direct calculations. */
IF EXISTS
(
    SELECT 1
    FROM
    (
        SELECT Cno,
               CAST(AVG(CAST(Grade AS DECIMAL(10,2))) AS DECIMAL(6,2)) AS ExpectedAvg
        FROM Academic.Enrollment
        GROUP BY Cno
    ) AS expected
    FULL OUTER JOIN Academic.CourseAverage AS actual
        ON actual.Cno = expected.Cno
    WHERE expected.Cno IS NULL
       OR actual.Cno IS NULL
       OR expected.ExpectedAvg <> actual.AvgGrade
)
    THROW 51002, 'Verification failed: course average mismatch.', 1;

/* 3. Grade-band counts must sum to the enrollment count for each course. */
IF EXISTS
(
    SELECT e.Cno
    FROM Academic.Enrollment AS e
    LEFT JOIN
    (
        SELECT Cno, SUM(StudentCount) AS DistributionCount
        FROM Academic.GradeDistribution
        GROUP BY Cno
    ) AS d ON d.Cno = e.Cno
    GROUP BY e.Cno, d.DistributionCount
    HAVING COUNT(*) <> ISNULL(d.DistributionCount, -1)
)
    THROW 51003, 'Verification failed: grade-distribution count mismatch.', 1;

/* 4. Percentages should total approximately 100% (rounding allowed). */
IF EXISTS
(
    SELECT Cno
    FROM Academic.GradeDistribution
    GROUP BY Cno
    HAVING ABS(SUM(Percentage) - 100.0) > 0.05
)
    THROW 51004, 'Verification failed: grade percentages do not sum to 100%.', 1;

/* 5. Weighted averages must equal direct credit-weighted calculations. */
IF EXISTS
(
    SELECT 1
    FROM
    (
        SELECT
            e.Sno,
            CAST(
                SUM(CAST(e.Grade AS DECIMAL(12,2)) * c.Ccredit)
                / NULLIF(SUM(c.Ccredit), 0)
                AS DECIMAL(6,2)
            ) AS ExpectedWeightedAverage
        FROM Academic.Enrollment AS e
        JOIN Academic.Course AS c ON c.Cno = e.Cno
        GROUP BY e.Sno
    ) AS expected
    FULL OUTER JOIN Academic.StudentWeightedAverage AS actual
        ON actual.Sno = expected.Sno
    WHERE expected.Sno IS NULL
       OR actual.Sno IS NULL
       OR expected.ExpectedWeightedAverage <> actual.WeightedAverage
)
    THROW 51005, 'Verification failed: student weighted average mismatch.', 1;

/* 6. Grade levels must be complete and valid. */
IF (SELECT COUNT(*) FROM Academic.GradeLevel)
   <> (SELECT COUNT(*) FROM Academic.Enrollment)
    THROW 51006, 'Verification failed: grade-level row count mismatch.', 1;

IF EXISTS
(
    SELECT 1
    FROM Academic.GradeLevel
    WHERE GradeLetter NOT IN ('A', 'B', 'C', 'D', 'E')
)
    THROW 51007, 'Verification failed: invalid grade letter.', 1;

PRINT 'All verification checks passed.';
GO
