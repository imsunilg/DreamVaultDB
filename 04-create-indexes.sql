-- DreamVault :: 04-create-indexes.sql

SET search_path TO "DreamVault";

CREATE INDEX IF NOT EXISTS "IX_Dreams_UserId"          ON "Dreams" ("UserId");
CREATE INDEX IF NOT EXISTS "IX_Dreams_CategoryId"       ON "Dreams" ("CategoryId");
CREATE INDEX IF NOT EXISTS "IX_Dreams_Status"           ON "Dreams" ("Status");
CREATE INDEX IF NOT EXISTS "IX_Dreams_TargetDate"       ON "Dreams" ("TargetDate");

CREATE INDEX IF NOT EXISTS "IX_Goals_DreamId"           ON "Goals" ("DreamId");
CREATE INDEX IF NOT EXISTS "IX_Goals_Status"            ON "Goals" ("Status");

CREATE INDEX IF NOT EXISTS "IX_Contributions_DreamId"   ON "Contributions" ("DreamId");
CREATE INDEX IF NOT EXISTS "IX_Contributions_Date"      ON "Contributions" ("ContributionDate");

CREATE INDEX IF NOT EXISTS "IX_StockTransactions_StockId" ON "StockTransactions" ("StockId");
CREATE INDEX IF NOT EXISTS "IX_StockTransactions_Date"    ON "StockTransactions" ("TransactionDate");
CREATE INDEX IF NOT EXISTS "IX_StockTransactions_Type"    ON "StockTransactions" ("TransactionType");

CREATE INDEX IF NOT EXISTS "IX_PortfolioSnapshots_Date"   ON "PortfolioSnapshots" ("SnapshotDate");

CREATE UNIQUE INDEX IF NOT EXISTS "UX_Stocks_Symbol"      ON "Stocks" ("Symbol");
