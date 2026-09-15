-- DreamVault :: 03-create-tables.sql
-- Run connected to the DreamVaultDB database, after 02-create-schema.sql.

SET search_path TO "DreamVault";

-- ============================================================
-- Roles
-- ============================================================
CREATE TABLE IF NOT EXISTS "Roles" (
    "RoleId"      SERIAL PRIMARY KEY,
    "RoleName"    VARCHAR(20) NOT NULL UNIQUE
        CHECK ("RoleName" IN ('Admin', 'User')),
    "Description" VARCHAR(200),
    "CreatedDate" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Users
-- ============================================================
CREATE TABLE IF NOT EXISTS "Users" (
    "UserId"              SERIAL PRIMARY KEY,
    "Username"            VARCHAR(100) NOT NULL UNIQUE,
    "Email"               VARCHAR(200) NOT NULL UNIQUE,
    "FirstName"           VARCHAR(100) NOT NULL,
    "LastName"            VARCHAR(100),
    "PasswordHash"        VARCHAR(500) NOT NULL,
    "RoleId"              INTEGER NOT NULL REFERENCES "Roles" ("RoleId"),
    "IsActive"            BOOLEAN NOT NULL DEFAULT TRUE,
    "IsLocked"            BOOLEAN NOT NULL DEFAULT FALSE,
    "FailedLoginCount"    INTEGER NOT NULL DEFAULT 0,
    "LastFailedLoginDate" TIMESTAMP,
    "LastLoginDate"       TIMESTAMP,
    "IsDeleted"           BOOLEAN NOT NULL DEFAULT FALSE,
    "DeletedDate"         TIMESTAMP,
    "DeletedBy"           INTEGER,
    "CreatedDate"         TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedDate"         TIMESTAMP NOT NULL DEFAULT NOW(),
    "CreatedBy"           INTEGER,
    "UpdatedBy"           INTEGER
);

-- ============================================================
-- LoginLogs
-- ============================================================
CREATE TABLE IF NOT EXISTS "LoginLogs" (
    "LoginLogId"       SERIAL PRIMARY KEY,
    "UserId"           INTEGER REFERENCES "Users" ("UserId") ON DELETE SET NULL,
    "Username"         VARCHAR(100) NOT NULL,
    "LoginDateTime"    TIMESTAMP NOT NULL DEFAULT NOW(),
    "LogoutDateTime"   TIMESTAMP,
    "Success"          BOOLEAN NOT NULL,
    "FailureReason"    VARCHAR(200),
    "IpAddress"        VARCHAR(64),
    "UserAgent"        VARCHAR(500),
    "Device"           VARCHAR(50),
    "Browser"          VARCHAR(50),
    "OperatingSystem"  VARCHAR(50),
    "CreatedDate"      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- AuditLogs
-- ============================================================
CREATE TABLE IF NOT EXISTS "AuditLogs" (
    "AuditLogId"  SERIAL PRIMARY KEY,
    "UserId"      INTEGER REFERENCES "Users" ("UserId") ON DELETE SET NULL,
    "Action"      VARCHAR(50) NOT NULL,
    "EntityName"  VARCHAR(50),
    "EntityId"    VARCHAR(50),
    "Description" VARCHAR(1000),
    "OldValue"    VARCHAR(2000),
    "NewValue"    VARCHAR(2000),
    "IpAddress"   VARCHAR(64),
    "UserAgent"   VARCHAR(500),
    "CreatedDate" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Categories
-- ============================================================
CREATE TABLE IF NOT EXISTS "Categories" (
    "CategoryId"  SERIAL PRIMARY KEY,
    "Name"        VARCHAR(100) NOT NULL UNIQUE,
    "Description" VARCHAR(300),
    "IsActive"    BOOLEAN NOT NULL DEFAULT TRUE,
    "CreatedDate" TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Dreams
-- ============================================================
CREATE TABLE IF NOT EXISTS "Dreams" (
    "DreamId"              SERIAL PRIMARY KEY,
    "UserId"               INTEGER NOT NULL REFERENCES "Users" ("UserId") ON DELETE CASCADE,
    "Name"                 VARCHAR(200) NOT NULL,
    "Description"          VARCHAR(1000),
    "CategoryId"           INTEGER REFERENCES "Categories" ("CategoryId") ON DELETE SET NULL,
    "Priority"             VARCHAR(20)  NOT NULL DEFAULT 'Medium'
        CHECK ("Priority" IN ('Critical', 'High', 'Medium', 'Low')),
    "Status"               VARCHAR(20)  NOT NULL DEFAULT 'Wishlist'
        CHECK ("Status" IN ('Wishlist', 'Planned', 'Active', 'OnTrack', 'AtRisk', 'Completed', 'Cancelled')),
    "TargetAmount"         NUMERIC(18,2) NOT NULL CHECK ("TargetAmount" > 0),
    "CurrentAmount"        NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("CurrentAmount" >= 0),
    "MonthlyContribution"  NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("MonthlyContribution" >= 0),
    "ExpectedReturnRate"   NUMERIC(5,2)  NOT NULL DEFAULT 10 CHECK ("ExpectedReturnRate" BETWEEN 0 AND 100),
    "InflationRate"        NUMERIC(5,2)  NOT NULL DEFAULT 6  CHECK ("InflationRate" BETWEEN 0 AND 50),
    "StartDate"            DATE NOT NULL DEFAULT CURRENT_DATE,
    "TargetDate"           DATE NOT NULL,
    "CompletedDate"        DATE,
    "ImageUrl"             VARCHAR(500),
    "Notes"                VARCHAR(2000),
    "CreatedDate"          TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedDate"          TIMESTAMP NOT NULL DEFAULT NOW(),
    CONSTRAINT "CK_Dreams_TargetAfterStart" CHECK ("TargetDate" > "StartDate")
);

-- ============================================================
-- Goals (financial-goal detail attached to a Dream)
-- ============================================================
CREATE TABLE IF NOT EXISTS "Goals" (
    "GoalId"              SERIAL PRIMARY KEY,
    "DreamId"             INTEGER NOT NULL REFERENCES "Dreams" ("DreamId") ON DELETE CASCADE,
    "TargetAmount"        NUMERIC(18,2) NOT NULL CHECK ("TargetAmount" > 0),
    "CurrentAmount"       NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("CurrentAmount" >= 0),
    "MonthlyContribution" NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("MonthlyContribution" >= 0),
    "ExpectedReturnRate"  NUMERIC(5,2)  NOT NULL DEFAULT 10 CHECK ("ExpectedReturnRate" BETWEEN 0 AND 100),
    "InflationRate"       NUMERIC(5,2)  NOT NULL DEFAULT 6  CHECK ("InflationRate" BETWEEN 0 AND 50),
    "TargetDate"          DATE NOT NULL,
    "Status"              VARCHAR(20) NOT NULL DEFAULT 'OnTrack'
        CHECK ("Status" IN ('OnTrack', 'AtRisk', 'Behind', 'Achieved')),
    "CreatedDate"         TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedDate"         TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Contributions (manual savings deposits towards a Dream)
-- ============================================================
CREATE TABLE IF NOT EXISTS "Contributions" (
    "ContributionId"   SERIAL PRIMARY KEY,
    "DreamId"          INTEGER NOT NULL REFERENCES "Dreams" ("DreamId") ON DELETE CASCADE,
    "ContributionDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "Amount"           NUMERIC(18,2) NOT NULL CHECK ("Amount" > 0),
    "Notes"            VARCHAR(500),
    "CreatedDate"      TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Investments (generic SIP-style investment buckets, not stock-specific)
-- ============================================================
CREATE TABLE IF NOT EXISTS "Investments" (
    "InvestmentId"        SERIAL PRIMARY KEY,
    "Name"                VARCHAR(200) NOT NULL,
    "InvestmentType"      VARCHAR(50) NOT NULL DEFAULT 'MutualFund'
        CHECK ("InvestmentType" IN ('MutualFund', 'FixedDeposit', 'PPF', 'Bond', 'Cash', 'Other')),
    "InitialAmount"       NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("InitialAmount" >= 0),
    "MonthlyContribution" NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("MonthlyContribution" >= 0),
    "ExpectedReturnRate"  NUMERIC(5,2)  NOT NULL DEFAULT 10 CHECK ("ExpectedReturnRate" BETWEEN 0 AND 100),
    "StartDate"           DATE NOT NULL DEFAULT CURRENT_DATE,
    "TargetDate"          DATE,
    "Notes"               VARCHAR(1000),
    "CreatedDate"         TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedDate"         TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- Stocks
-- ============================================================
CREATE TABLE IF NOT EXISTS "Stocks" (
    "StockId"      SERIAL PRIMARY KEY,
    "Symbol"       VARCHAR(30) NOT NULL UNIQUE,
    "CompanyName"  VARCHAR(200) NOT NULL,
    "Sector"       VARCHAR(100),
    "CurrentPrice" NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("CurrentPrice" >= 0),
    "Notes"        VARCHAR(1000),
    "CreatedDate"  TIMESTAMP NOT NULL DEFAULT NOW(),
    "UpdatedDate"  TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- StockTransactions
-- ============================================================
CREATE TABLE IF NOT EXISTS "StockTransactions" (
    "TransactionId"   SERIAL PRIMARY KEY,
    "StockId"         INTEGER NOT NULL REFERENCES "Stocks" ("StockId") ON DELETE CASCADE,
    "TransactionType" VARCHAR(20) NOT NULL
        CHECK ("TransactionType" IN ('BUY', 'SELL', 'BONUS', 'SPLIT', 'DIVIDEND')),
    "TransactionDate" DATE NOT NULL DEFAULT CURRENT_DATE,
    "Quantity"        NUMERIC(18,4) NOT NULL CHECK ("Quantity" > 0),
    "PricePerShare"   NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("PricePerShare" >= 0),
    "Brokerage"       NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("Brokerage" >= 0),
    "Taxes"           NUMERIC(18,2) NOT NULL DEFAULT 0 CHECK ("Taxes" >= 0),
    "Notes"           VARCHAR(500),
    "CreatedDate"     TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- PortfolioSnapshots (periodic point-in-time portfolio totals)
-- ============================================================
CREATE TABLE IF NOT EXISTS "PortfolioSnapshots" (
    "SnapshotId"     SERIAL PRIMARY KEY,
    "SnapshotDate"   DATE NOT NULL DEFAULT CURRENT_DATE,
    "TotalInvested"  NUMERIC(18,2) NOT NULL DEFAULT 0,
    "PortfolioValue" NUMERIC(18,2) NOT NULL DEFAULT 0,
    "ProfitLoss"     NUMERIC(18,2) NOT NULL DEFAULT 0,
    "CreatedDate"    TIMESTAMP NOT NULL DEFAULT NOW()
);
