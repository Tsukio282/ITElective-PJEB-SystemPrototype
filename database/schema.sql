/* ============================================================
   Online Campus Event Management System
   Target DBMS : Microsoft SQL Server (T-SQL)
   Normal form : 3NF
   File        : /database/schema.sql
   Tables      : Roles, Programs, Categories, Venues,
                 Users, Events, Registrations
   ============================================================ */

IF DB_ID(N'CampusEvents') IS NULL
    CREATE DATABASE CampusEvents;
GO

USE CampusEvents;
GO

/* ---------- Re-runnable: drop children before parents ---------- */
DROP TABLE IF EXISTS dbo.Registrations;
DROP TABLE IF EXISTS dbo.Events;
DROP TABLE IF EXISTS dbo.Users;
DROP TABLE IF EXISTS dbo.Venues;
DROP TABLE IF EXISTS dbo.Categories;
DROP TABLE IF EXISTS dbo.Programs;
DROP TABLE IF EXISTS dbo.Roles;
GO

/* ============================================================
   LOOKUP TABLES
   ============================================================ */

CREATE TABLE dbo.Roles (
    RoleId    TINYINT      IDENTITY(1,1) NOT NULL,
    RoleName  NVARCHAR(30) NOT NULL,
    CONSTRAINT PK_Roles          PRIMARY KEY CLUSTERED (RoleId),
    CONSTRAINT UQ_Roles_RoleName UNIQUE (RoleName),
    CONSTRAINT CK_Roles_RoleName_NotBlank
        CHECK (LEN(LTRIM(RTRIM(RoleName))) > 0)
);
GO

CREATE TABLE dbo.Programs (
    ProgramId    INT           IDENTITY(1,1) NOT NULL,
    ProgramName  NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Programs             PRIMARY KEY CLUSTERED (ProgramId),
    CONSTRAINT UQ_Programs_ProgramName UNIQUE (ProgramName),
    CONSTRAINT CK_Programs_ProgramName_NotBlank
        CHECK (LEN(LTRIM(RTRIM(ProgramName))) > 0)
);
GO

CREATE TABLE dbo.Categories (
    CategoryId    INT          IDENTITY(1,1) NOT NULL,
    CategoryName  NVARCHAR(50) NOT NULL,
    CONSTRAINT PK_Categories               PRIMARY KEY CLUSTERED (CategoryId),
    CONSTRAINT UQ_Categories_CategoryName  UNIQUE (CategoryName),
    CONSTRAINT CK_Categories_CategoryName_NotBlank
        CHECK (LEN(LTRIM(RTRIM(CategoryName))) > 0)
);
GO

CREATE TABLE dbo.Venues (
    VenueId    INT           IDENTITY(1,1) NOT NULL,
    VenueName  NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Venues           PRIMARY KEY CLUSTERED (VenueId),
    CONSTRAINT UQ_Venues_VenueName UNIQUE (VenueName),
    CONSTRAINT CK_Venues_VenueName_NotBlank
        CHECK (LEN(LTRIM(RTRIM(VenueName))) > 0)
);
GO

/* ============================================================
   CORE TABLES
   ============================================================ */

CREATE TABLE dbo.Users (
    UserId     INT           IDENTITY(1,1) NOT NULL,
    RoleId     TINYINT       NOT NULL,
    ProgramId  INT           NULL,            -- NULL for administrators
    FullName   NVARCHAR(100) NOT NULL,
    Email      NVARCHAR(254) NOT NULL,
    CreatedAt  DATETIME2(0)  NOT NULL
        CONSTRAINT DF_Users_CreatedAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Users        PRIMARY KEY CLUSTERED (UserId),
    CONSTRAINT UQ_Users_Email  UNIQUE (Email),
    CONSTRAINT FK_Users_Roles
        FOREIGN KEY (RoleId) REFERENCES dbo.Roles (RoleId)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Users_Programs
        FOREIGN KEY (ProgramId) REFERENCES dbo.Programs (ProgramId)
        ON DELETE SET NULL
        ON UPDATE NO ACTION,
    CONSTRAINT CK_Users_FullName_MinLength
        CHECK (LEN(LTRIM(RTRIM(FullName))) >= 2),
    CONSTRAINT CK_Users_Email_Format
        CHECK (Email LIKE '%_@_%._%' AND Email NOT LIKE '% %')
);
GO

CREATE TABLE dbo.Events (
    EventId        INT           IDENTITY(1,1) NOT NULL,
    CategoryId     INT           NOT NULL,
    VenueId        INT           NOT NULL,
    Title          NVARCHAR(150) NOT NULL,
    Description    NVARCHAR(500) NULL,
    StartDateTime  DATETIME2(0)  NOT NULL,
    Capacity       INT           NOT NULL,
    CONSTRAINT PK_Events PRIMARY KEY CLUSTERED (EventId),
    CONSTRAINT FK_Events_Categories
        FOREIGN KEY (CategoryId) REFERENCES dbo.Categories (CategoryId)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Events_Venues
        FOREIGN KEY (VenueId) REFERENCES dbo.Venues (VenueId)
        ON DELETE NO ACTION
        ON UPDATE NO ACTION,
    CONSTRAINT CK_Events_Title_NotBlank
        CHECK (LEN(LTRIM(RTRIM(Title))) > 0),
    CONSTRAINT CK_Events_Capacity_Positive
        CHECK (Capacity > 0)
);
GO

CREATE TABLE dbo.Registrations (
    RegistrationId  INT          IDENTITY(1,1) NOT NULL,
    UserId          INT          NOT NULL,
    EventId         INT          NOT NULL,
    RegisteredAt    DATETIME2(0) NOT NULL
        CONSTRAINT DF_Registrations_RegisteredAt DEFAULT SYSUTCDATETIME(),
    CONSTRAINT PK_Registrations PRIMARY KEY CLUSTERED (RegistrationId),
    CONSTRAINT UQ_Registrations_User_Event UNIQUE (UserId, EventId),
    CONSTRAINT FK_Registrations_Users
        FOREIGN KEY (UserId) REFERENCES dbo.Users (UserId)
        ON DELETE CASCADE
        ON UPDATE NO ACTION,
    CONSTRAINT FK_Registrations_Events
        FOREIGN KEY (EventId) REFERENCES dbo.Events (EventId)
        ON DELETE CASCADE
        ON UPDATE NO ACTION
);
GO

/* ============================================================
   NONCLUSTERED INDEXES ON EVERY FOREIGN KEY COLUMN
   ============================================================ */

CREATE NONCLUSTERED INDEX IX_Users_RoleId
    ON dbo.Users (RoleId);
GO
CREATE NONCLUSTERED INDEX IX_Users_ProgramId
    ON dbo.Users (ProgramId);
GO
CREATE NONCLUSTERED INDEX IX_Events_CategoryId
    ON dbo.Events (CategoryId);
GO
CREATE NONCLUSTERED INDEX IX_Events_VenueId
    ON dbo.Events (VenueId);
GO
CREATE NONCLUSTERED INDEX IX_Registrations_UserId
    ON dbo.Registrations (UserId);
GO
CREATE NONCLUSTERED INDEX IX_Registrations_EventId
    ON dbo.Registrations (EventId);
GO
