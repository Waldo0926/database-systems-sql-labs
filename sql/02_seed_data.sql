/*
  02_seed_data.sql
  Sample data adapted from the coursework and expanded for meaningful demos.
*/

USE DatabaseSystemsLabs;
GO

/* ---------- Supplier / Part / Project sample data ---------- */
INSERT INTO spj.Supplier (Sno, Sname, Status, City)
VALUES
('S1', N'精益',   20, N'天津'),
('S2', N'盛锡',   10, N'北京'),
('S3', N'东方红', 30, N'北京'),
('S4', N'丰泰盛', 20, N'天津'),
('S5', N'为民',   30, N'上海');

INSERT INTO spj.Part (Pno, Pname, Color, Weight, City)
VALUES
('P1', N'螺母',   N'红', 12, N'上海'),
('P2', N'螺栓',   N'绿', 17, N'北京'),
('P3', N'螺丝刀', N'蓝', 14, N'天津'),
('P4', N'螺丝刀', N'红', 14, N'天津'),
('P5', N'凸轮',   N'蓝', 40, N'上海'),
('P6', N'齿轮',   N'红', 30, N'北京');

INSERT INTO spj.Project (Jno, Jname, City)
VALUES
('J1', N'三建',     N'北京'),
('J2', N'一汽',     N'长春'),
('J3', N'弹簧厂',   N'天津'),
('J4', N'造船厂',   N'天津'),
('J5', N'机车厂',   N'唐山'),
('J6', N'无线电厂', N'常州'),
('J7', N'半导体厂', N'南京');

INSERT INTO spj.Supply (Sno, Pno, Jno, Qty)
VALUES
('S1', 'P1', 'J1', 200),
('S1', 'P1', 'J3', 100),
('S1', 'P1', 'J4', 700),
('S1', 'P2', 'J2', 100),
('S2', 'P3', 'J1', 400),
('S2', 'P3', 'J2', 200),
('S2', 'P3', 'J4', 500),
('S2', 'P3', 'J5', 400),
('S2', 'P5', 'J1', 400),
('S2', 'P5', 'J2', 100),
('S3', 'P1', 'J1', 200),
('S3', 'P3', 'J1', 200),
('S4', 'P5', 'J1', 100),
('S4', 'P6', 'J3', 300),
('S4', 'P6', 'J4', 200),
('S5', 'P2', 'J4', 100),
('S5', 'P3', 'J1', 200),
('S5', 'P6', 'J2', 200),
('S5', 'P6', 'J4', 500);
GO

/* ---------- Academic sample data ---------- */
INSERT INTO Academic.Student (Sno, Sname, Ssex, Sage, Sdept)
VALUES
('201215121', N'李勇', N'男', 20, N'计算机科学'),
('201215122', N'刘晨', N'女', 19, N'计算机科学'),
('201215123', N'王敏', N'女', 18, N'数学'),
('201215124', N'陈晨', N'男', 20, N'信息系统'),
('201215125', N'张立', N'男', 19, N'信息系统'),
('201215126', N'赵明', N'女', 20, N'计算机科学');

/* Insert courses first, then add prerequisite links to avoid ordering problems. */
INSERT INTO Academic.Course (Cno, Cname, PrerequisiteCno, Ccredit)
VALUES
('1', N'数据库',     NULL, 4),
('2', N'离散数学',   NULL, 4),
('3', N'信息系统',   NULL, 4),
('4', N'操作系统',   NULL, 4),
('5', N'数据结构',   NULL, 4),
('6', N'数据处理',   NULL, 2),
('7', N'PASCAL语言', NULL, 4);

UPDATE Academic.Course SET PrerequisiteCno = '5' WHERE Cno IN ('1', '4');
UPDATE Academic.Course SET PrerequisiteCno = '1' WHERE Cno = '3';
UPDATE Academic.Course SET PrerequisiteCno = '2' WHERE Cno = '5';
UPDATE Academic.Course SET PrerequisiteCno = '6' WHERE Cno = '7';

INSERT INTO Academic.Enrollment (Sno, Cno, Grade)
VALUES
('201215121', '1', 92),
('201215121', '2', 85),
('201215121', '3', 88),
('201215122', '2', 90),
('201215122', '3', 80),
('201215122', '5', 76),
('201215123', '1', 68),
('201215123', '2', 95),
('201215123', '5', 84),
('201215124', '1', 59),
('201215124', '2', 72),
('201215124', '4', 65),
('201215125', '2', 61),
('201215125', '4', 78),
('201215125', '5', 88),
('201215126', '1', 81),
('201215126', '2', 55),
('201215126', '3', 91),
('201215126', '5', 93);
GO
