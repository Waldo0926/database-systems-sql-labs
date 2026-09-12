/*
  01_schema.sql
  Rebuilds the two schemas used by the lab portfolio.
*/

USE DatabaseSystemsLabs;
GO

/* ---------- Drop derived objects first so this file is rerunnable ---------- */
DROP VIEW IF EXISTS spj.vw_SupplyDetail;
GO

DROP TABLE IF EXISTS Academic.GradeLevel;
DROP TABLE IF EXISTS Academic.StudentWeightedAverage;
DROP TABLE IF EXISTS Academic.GradeDistribution;
DROP TABLE IF EXISTS Academic.CourseAverage;
DROP TABLE IF EXISTS Academic.Enrollment;
DROP TABLE IF EXISTS Academic.Course;
DROP TABLE IF EXISTS Academic.Student;

DROP TABLE IF EXISTS spj.Supply;
DROP TABLE IF EXISTS spj.Project;
DROP TABLE IF EXISTS spj.Part;
DROP TABLE IF EXISTS spj.Supplier;
GO

/* ---------- Lab 1: supplier / part / project ---------- */
CREATE TABLE spj.Supplier
(
    Sno       VARCHAR(10)   NOT NULL,
    Sname     NVARCHAR(40)  NOT NULL,
    Status    SMALLINT      NOT NULL,
    City      NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_Supplier PRIMARY KEY (Sno),
    CONSTRAINT CK_Supplier_Status CHECK (Status >= 0)
);

CREATE TABLE spj.Part
(
    Pno       VARCHAR(10)   NOT NULL,
    Pname     NVARCHAR(40)  NOT NULL,
    Color     NVARCHAR(20)  NOT NULL,
    Weight    SMALLINT      NOT NULL,
    City      NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_Part PRIMARY KEY (Pno),
    CONSTRAINT CK_Part_Weight CHECK (Weight > 0)
);

CREATE TABLE spj.Project
(
    Jno       VARCHAR(10)   NOT NULL,
    Jname     NVARCHAR(60)  NOT NULL,
    City      NVARCHAR(40)  NOT NULL,
    CONSTRAINT PK_Project PRIMARY KEY (Jno)
);

CREATE TABLE spj.Supply
(
    Sno       VARCHAR(10)   NOT NULL,
    Pno       VARCHAR(10)   NOT NULL,
    Jno       VARCHAR(10)   NOT NULL,
    Qty       INT           NOT NULL,
    CONSTRAINT PK_Supply PRIMARY KEY (Sno, Pno, Jno),
    CONSTRAINT CK_Supply_Qty CHECK (Qty > 0),
    CONSTRAINT FK_Supply_Supplier FOREIGN KEY (Sno)
        REFERENCES spj.Supplier (Sno),
    CONSTRAINT FK_Supply_Part FOREIGN KEY (Pno)
        REFERENCES spj.Part (Pno),
    CONSTRAINT FK_Supply_Project FOREIGN KEY (Jno)
        REFERENCES spj.Project (Jno)
);
GO

/* ---------- Labs 2-3: student / course / enrollment ---------- */
CREATE TABLE Academic.Student
(
    Sno       VARCHAR(11)   NOT NULL,
    Sname     NVARCHAR(40)  NOT NULL,
    Ssex      NCHAR(1)      NULL,
    Sage      SMALLINT      NULL,
    Sdept     NVARCHAR(60)  NULL,
    CONSTRAINT PK_Student PRIMARY KEY (Sno),
    CONSTRAINT UQ_Student_Name UNIQUE (Sname),
    CONSTRAINT CK_Student_Age CHECK (Sage IS NULL OR Sage BETWEEN 15 AND 100)
);

CREATE TABLE Academic.Course
(
    Cno             VARCHAR(4)    NOT NULL,
    Cname           NVARCHAR(60)  NOT NULL,
    PrerequisiteCno VARCHAR(4)    NULL,
    Ccredit         SMALLINT      NOT NULL,
    CONSTRAINT PK_Course PRIMARY KEY (Cno),
    CONSTRAINT UQ_Course_Name UNIQUE (Cname),
    CONSTRAINT CK_Course_Credit CHECK (Ccredit > 0),
    CONSTRAINT FK_Course_Prerequisite FOREIGN KEY (PrerequisiteCno)
        REFERENCES Academic.Course (Cno)
);

CREATE TABLE Academic.Enrollment
(
    Sno       VARCHAR(11)  NOT NULL,
    Cno       VARCHAR(4)   NOT NULL,
    Grade     SMALLINT     NOT NULL,
    CONSTRAINT PK_Enrollment PRIMARY KEY (Sno, Cno),
    CONSTRAINT CK_Enrollment_Grade CHECK (Grade BETWEEN 0 AND 100),
    CONSTRAINT FK_Enrollment_Student FOREIGN KEY (Sno)
        REFERENCES Academic.Student (Sno)
        ON DELETE CASCADE,
    CONSTRAINT FK_Enrollment_Course FOREIGN KEY (Cno)
        REFERENCES Academic.Course (Cno)
);

CREATE TABLE Academic.CourseAverage
(
    Cno       VARCHAR(4)   NOT NULL,
    AvgGrade  DECIMAL(6,2) NOT NULL,
    CONSTRAINT PK_CourseAverage PRIMARY KEY (Cno),
    CONSTRAINT FK_CourseAverage_Course FOREIGN KEY (Cno)
        REFERENCES Academic.Course (Cno)
        ON DELETE CASCADE
);

CREATE TABLE Academic.GradeDistribution
(
    Cno          VARCHAR(4)    NOT NULL,
    BandOrder    TINYINT       NOT NULL,
    Division     VARCHAR(12)   NOT NULL,
    StudentCount INT           NOT NULL,
    Percentage   DECIMAL(6,2)  NOT NULL,
    CONSTRAINT PK_GradeDistribution PRIMARY KEY (Cno, BandOrder),
    CONSTRAINT CK_GradeDistribution_Count CHECK (StudentCount >= 0),
    CONSTRAINT CK_GradeDistribution_Percentage CHECK (Percentage BETWEEN 0 AND 100),
    CONSTRAINT FK_GradeDistribution_Course FOREIGN KEY (Cno)
        REFERENCES Academic.Course (Cno)
        ON DELETE CASCADE
);

CREATE TABLE Academic.StudentWeightedAverage
(
    Sno             VARCHAR(11)  NOT NULL,
    WeightedAverage DECIMAL(6,2) NOT NULL,
    CONSTRAINT PK_StudentWeightedAverage PRIMARY KEY (Sno),
    CONSTRAINT FK_StudentWeightedAverage_Student FOREIGN KEY (Sno)
        REFERENCES Academic.Student (Sno)
        ON DELETE CASCADE
);

CREATE TABLE Academic.GradeLevel
(
    Sno         VARCHAR(11) NOT NULL,
    Cno         VARCHAR(4)  NOT NULL,
    GradeLetter CHAR(1)     NOT NULL,
    CONSTRAINT PK_GradeLevel PRIMARY KEY (Sno, Cno),
    CONSTRAINT CK_GradeLevel_Letter CHECK (GradeLetter IN ('A', 'B', 'C', 'D', 'E')),
    CONSTRAINT FK_GradeLevel_Student FOREIGN KEY (Sno)
        REFERENCES Academic.Student (Sno)
        ON DELETE CASCADE,
    CONSTRAINT FK_GradeLevel_Course FOREIGN KEY (Cno)
        REFERENCES Academic.Course (Cno)
);
GO
