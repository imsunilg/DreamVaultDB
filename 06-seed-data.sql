-- DreamVault :: 06-seed-data.sql
-- Realistic demo data for a single personal user. All amounts in INR.

SET search_path TO "DreamVault";

-- ============================================================
-- Users
-- Demo login credentials (change these after first login):
--   Admin: sunilbgadakari@gmail.com / Admin@123
--   User:  demo.user@dreamvault.local / User@123
-- Password hashes below are ASP.NET Core Identity PasswordHasher<T> output (PBKDF2).
-- ============================================================
INSERT INTO "Users" ("Name", "Email", "PasswordHash", "Role")
SELECT 'Sunil Gadakari', 'sunilbgadakari@gmail.com',
       'AQAAAAIAAYagAAAAEEawUmfFpezawjOy3DaioUfMRjwgvsLRY5RCw8SanPdM7xGKPtIaH4T3uOQMdlU1qg==',
       'Admin'
WHERE NOT EXISTS (SELECT 1 FROM "Users" WHERE "Email" = 'sunilbgadakari@gmail.com');

INSERT INTO "Users" ("Name", "Email", "PasswordHash", "Role")
SELECT 'Demo User', 'demo.user@dreamvault.local',
       'AQAAAAIAAYagAAAAEHtMMjYczKx9XALVZdeo1NZDbeOAGxU3llzSAD3TMcZBg3zXnxZ4L84B/mQKtTJpMg==',
       'User'
WHERE NOT EXISTS (SELECT 1 FROM "Users" WHERE "Email" = 'demo.user@dreamvault.local');

-- ============================================================
-- Categories
-- ============================================================
INSERT INTO "Categories" ("Name", "Description")
SELECT v."Name", v."Description" FROM (VALUES
    ('Vehicles',  'Bikes, cars and other vehicles'),
    ('Property',  'Home, land and real estate'),
    ('Lifestyle', 'Travel, electronics and other lifestyle purchases'),
    ('Financial', 'Emergency fund, retirement and investment corpus goals'),
    ('Family',    'Education, marriage and other family goals'),
    ('Custom',    'User-defined dreams')
) AS v("Name", "Description")
WHERE NOT EXISTS (SELECT 1 FROM "Categories" c WHERE c."Name" = v."Name");

-- ============================================================
-- Dreams (7 demo dreams)
-- ============================================================
INSERT INTO "Dreams"
    ("UserId", "Name", "Description", "CategoryId", "Priority", "Status",
     "TargetAmount", "CurrentAmount", "MonthlyContribution", "ExpectedReturnRate", "InflationRate",
     "StartDate", "TargetDate")
SELECT
    (SELECT "UserId" FROM "Users" WHERE "Email" = 'sunilbgadakari@gmail.com'),
    v."Name", v."Description",
    (SELECT "CategoryId" FROM "Categories" WHERE "Name" = v."CategoryName"),
    v."Priority", v."Status", v."TargetAmount", v."CurrentAmount", v."MonthlyContribution",
    v."ExpectedReturnRate", v."InflationRate", v."StartDate", v."TargetDate"
FROM (VALUES
    ('Dream Bike', 'Premium 350cc motorcycle', 'Vehicles', 'High', 'Active',
        300000, 75000, 10000, 10, 5, DATE '2025-01-01', DATE '2028-12-31'),
    ('Dream Car', 'Mid-size SUV for the family', 'Vehicles', 'High', 'Active',
        2500000, 400000, 25000, 11, 6, DATE '2024-06-01', DATE '2030-06-30'),
    ('Dream Home', '3BHK apartment in the city', 'Property', 'Critical', 'Active',
        10000000, 1500000, 50000, 12, 6, DATE '2023-01-01', DATE '2033-01-01'),
    ('International Vacation', 'Two-week Europe trip', 'Lifestyle', 'Medium', 'Active',
        400000, 120000, 15000, 8, 5, DATE '2025-06-01', DATE '2027-06-01'),
    ('Gaming PC', 'High-end custom gaming rig', 'Lifestyle', 'Low', 'Active',
        180000, 60000, 8000, 7, 4, DATE '2025-09-01', DATE '2026-12-31'),
    ('Emergency Fund', 'Six months of household expenses', 'Financial', 'Critical', 'Active',
        600000, 350000, 15000, 6, 5, DATE '2023-01-01', DATE '2026-12-31'),
    ('Retirement Corpus', 'Long-term retirement investment corpus', 'Financial', 'Critical', 'Active',
        50000000, 3500000, 40000, 12, 6, DATE '2020-01-01', DATE '2050-01-01')
) AS v("Name", "Description", "CategoryName", "Priority", "Status",
       "TargetAmount", "CurrentAmount", "MonthlyContribution", "ExpectedReturnRate", "InflationRate",
       "StartDate", "TargetDate")
WHERE NOT EXISTS (SELECT 1 FROM "Dreams" d WHERE d."Name" = v."Name");

-- ============================================================
-- Goals (one goal per dream, mirroring the dream's financial plan)
-- ============================================================
INSERT INTO "Goals"
    ("DreamId", "TargetAmount", "CurrentAmount", "MonthlyContribution", "ExpectedReturnRate", "InflationRate",
     "TargetDate", "Status")
SELECT d."DreamId", d."TargetAmount", d."CurrentAmount", d."MonthlyContribution", d."ExpectedReturnRate",
       d."InflationRate", d."TargetDate", 'OnTrack'
FROM "Dreams" d
WHERE NOT EXISTS (SELECT 1 FROM "Goals" g WHERE g."DreamId" = d."DreamId");

-- ============================================================
-- Contributions (sample savings history for a couple of dreams)
-- ============================================================
INSERT INTO "Contributions" ("DreamId", "ContributionDate", "Amount", "Notes")
SELECT (SELECT "DreamId" FROM "Dreams" WHERE "Name" = 'Dream Bike'), DATE '2025-02-05', 10000, 'Monthly SIP'
WHERE NOT EXISTS (SELECT 1 FROM "Contributions" WHERE "DreamId" = (SELECT "DreamId" FROM "Dreams" WHERE "Name" = 'Dream Bike') AND "ContributionDate" = DATE '2025-02-05');

INSERT INTO "Contributions" ("DreamId", "ContributionDate", "Amount", "Notes")
SELECT (SELECT "DreamId" FROM "Dreams" WHERE "Name" = 'Dream Bike'), DATE '2025-03-05', 10000, 'Monthly SIP'
WHERE NOT EXISTS (SELECT 1 FROM "Contributions" WHERE "DreamId" = (SELECT "DreamId" FROM "Dreams" WHERE "Name" = 'Dream Bike') AND "ContributionDate" = DATE '2025-03-05');

INSERT INTO "Contributions" ("DreamId", "ContributionDate", "Amount", "Notes")
SELECT (SELECT "DreamId" FROM "Dreams" WHERE "Name" = 'Emergency Fund'), DATE '2025-01-10', 15000, 'Monthly deposit'
WHERE NOT EXISTS (SELECT 1 FROM "Contributions" WHERE "DreamId" = (SELECT "DreamId" FROM "Dreams" WHERE "Name" = 'Emergency Fund') AND "ContributionDate" = DATE '2025-01-10');

INSERT INTO "Contributions" ("DreamId", "ContributionDate", "Amount", "Notes")
SELECT (SELECT "DreamId" FROM "Dreams" WHERE "Name" = 'Emergency Fund'), DATE '2025-02-10', 15000, 'Monthly deposit'
WHERE NOT EXISTS (SELECT 1 FROM "Contributions" WHERE "DreamId" = (SELECT "DreamId" FROM "Dreams" WHERE "Name" = 'Emergency Fund') AND "ContributionDate" = DATE '2025-02-10');

-- ============================================================
-- Stocks (6 demo stocks)
-- ============================================================
INSERT INTO "Stocks" ("Symbol", "CompanyName", "Sector", "CurrentPrice")
SELECT v."Symbol", v."CompanyName", v."Sector", v."CurrentPrice" FROM (VALUES
    ('RELIANCE',  'Reliance Industries Ltd',        'Energy',  2950),
    ('TCS',       'Tata Consultancy Services Ltd',  'IT',      4150),
    ('INFY',      'Infosys Ltd',                    'IT',      1850),
    ('HDFCBANK',  'HDFC Bank Ltd',                  'Banking', 1720),
    ('ICICIBANK', 'ICICI Bank Ltd',                 'Banking', 1290),
    ('ITC',       'ITC Ltd',                         'FMCG',    465)
) AS v("Symbol", "CompanyName", "Sector", "CurrentPrice")
WHERE NOT EXISTS (SELECT 1 FROM "Stocks" s WHERE s."Symbol" = v."Symbol");

-- ============================================================
-- StockTransactions
-- ============================================================
INSERT INTO "StockTransactions" ("StockId", "TransactionType", "TransactionDate", "Quantity", "PricePerShare", "Brokerage", "Taxes")
SELECT (SELECT "StockId" FROM "Stocks" WHERE "Symbol" = v."Symbol"), v."TransactionType", v."TransactionDate", v."Quantity", v."PricePerShare", v."Brokerage", v."Taxes"
FROM (VALUES
    ('RELIANCE',  'BUY',  DATE '2023-02-10', 10, 2400, 40, 12),
    ('RELIANCE',  'BUY',  DATE '2023-08-15', 20, 2500, 60, 24),
    ('RELIANCE',  'BUY',  DATE '2024-03-05', 15, 2350, 45, 18),
    ('TCS',       'BUY',  DATE '2023-01-20', 5,  3300, 35, 10),
    ('TCS',       'BUY',  DATE '2023-09-10', 8,  3500, 55, 16),
    ('TCS',       'SELL', DATE '2024-06-01', 3,  3800, 25, 8),
    ('INFY',      'BUY',  DATE '2022-11-05', 25, 1400, 70, 20),
    ('INFY',      'BUY',  DATE '2023-07-22', 15, 1550, 45, 14),
    ('HDFCBANK',  'BUY',  DATE '2023-04-12', 30, 1550, 90, 28),
    ('HDFCBANK',  'BUY',  DATE '2024-01-18', 20, 1600, 65, 20),
    ('ICICIBANK', 'BUY',  DATE '2022-09-01', 40, 980,  80, 24),
    ('ICICIBANK', 'BUY',  DATE '2023-12-11', 25, 1100, 55, 18),
    ('ITC',       'BUY',  DATE '2023-03-15', 100, 380, 75, 22),
    ('ITC',       'BUY',  DATE '2023-10-02', 50,  410, 40, 12)
) AS v("Symbol", "TransactionType", "TransactionDate", "Quantity", "PricePerShare", "Brokerage", "Taxes")
WHERE NOT EXISTS (
    SELECT 1 FROM "StockTransactions" t
    JOIN "Stocks" s2 ON s2."StockId" = t."StockId"
    WHERE s2."Symbol" = v."Symbol" AND t."TransactionDate" = v."TransactionDate" AND t."TransactionType" = v."TransactionType" AND t."Quantity" = v."Quantity"
);

-- ============================================================
-- PortfolioSnapshots (a few historical points for the growth chart)
-- ============================================================
INSERT INTO "PortfolioSnapshots" ("SnapshotDate", "TotalInvested", "PortfolioValue", "ProfitLoss")
SELECT v."SnapshotDate", v."TotalInvested", v."PortfolioValue", v."PortfolioValue" - v."TotalInvested"
FROM (VALUES
    (DATE '2024-01-01', 1500000, 1650000),
    (DATE '2024-06-01', 1850000, 2050000),
    (DATE '2025-01-01', 2200000, 2600000),
    (DATE '2025-06-01', 2500000, 3050000)
) AS v("SnapshotDate", "TotalInvested", "PortfolioValue")
WHERE NOT EXISTS (SELECT 1 FROM "PortfolioSnapshots" p WHERE p."SnapshotDate" = v."SnapshotDate");
