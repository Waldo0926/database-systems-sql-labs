/*
  08_demo.sql
  Small demonstrations of the cleaned coursework implementation.
*/

USE DatabaseSystemsLabs;
GO

PRINT '--- Supply detail view ---';
SELECT TOP (10) *
FROM spj.vw_SupplyDetail
ORDER BY Jno, Pno, Sno;

PRINT '--- Trigger-maintained course averages ---';
SELECT ca.Cno, c.Cname, ca.AvgGrade
FROM Academic.CourseAverage AS ca
JOIN Academic.Course AS c ON c.Cno = ca.Cno
ORDER BY ca.Cno;

PRINT '--- Grade distribution for Discrete Mathematics (course 2) ---';
EXEC Academic.usp_GradeDistribution @CourseNo = '2';

PRINT '--- Average for Database Systems (course 1) ---';
EXEC Academic.usp_CourseAverage @CourseNo = '1';

PRINT '--- Refresh numeric grades into A-E levels ---';
EXEC Academic.usp_RefreshGradeLevels;
SELECT * FROM Academic.GradeLevel ORDER BY Sno, Cno;

PRINT '--- Student weighted averages maintained by the trigger ---';
SELECT swa.Sno, s.Sname, swa.WeightedAverage
FROM Academic.StudentWeightedAverage AS swa
JOIN Academic.Student AS s ON s.Sno = swa.Sno
ORDER BY swa.Sno;
GO
