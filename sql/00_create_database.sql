/*
  Database Systems SQL Labs
  00_create_database.sql
  Target: Microsoft SQL Server 2019+
*/

USE master;
GO

IF DB_ID(N'DatabaseSystemsLabs') IS NULL
BEGIN
    CREATE DATABASE DatabaseSystemsLabs;
END;
GO

USE DatabaseSystemsLabs;
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'spj')
    EXEC(N'CREATE SCHEMA spj AUTHORIZATION dbo;');
GO

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = N'Academic')
    EXEC(N'CREATE SCHEMA Academic AUTHORIZATION dbo;');
GO
