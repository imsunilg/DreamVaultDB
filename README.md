# DreamVaultDB

PostgreSQL scripts for DreamVault, a personal dream/goal/investment planning app.

These scripts are provided for reference and for manual setup outside of EF Core. In normal
development, `DreamVaultAPI` applies its own EF Core migrations (`dotnet ef database update`),
which create the same schema described here.

## Scripts (run in order)

| Script | Purpose |
|---|---|
| `01-create-database.sql` | Creates the `DreamVaultDB` database (run against the default `postgres` database) |
| `02-create-schema.sql` | Creates the `DreamVault` schema |
| `03-create-tables.sql` | Creates all tables, primary keys, foreign keys and check constraints |
| `04-create-indexes.sql` | Creates supporting indexes |
| `05-create-functions.sql` | Creates SQL helper functions (weighted avg price, CAGR, future value, inflation-adjusted cost) mirroring `DreamVaultAPI/Calculations/FinanceCalculator.cs` |
| `06-seed-data.sql` | Inserts demo data: 1 user, 6 categories, 7 dreams/goals, sample contributions, 6 stocks with buy/sell transactions, and portfolio snapshots |

## Manual setup

```powershell
psql -U postgres -f 01-create-database.sql
psql -U postgres -d DreamVaultDB -f 02-create-schema.sql
psql -U postgres -d DreamVaultDB -f 03-create-tables.sql
psql -U postgres -d DreamVaultDB -f 04-create-indexes.sql
psql -U postgres -d DreamVaultDB -f 05-create-functions.sql
psql -U postgres -d DreamVaultDB -f 06-seed-data.sql
```

## Schema

All application tables live in the `DreamVault` schema (not `public`):

- `Users`, `Categories`
- `Dreams`, `Goals`, `Contributions`
- `Investments`
- `Stocks`, `StockTransactions`
- `PortfolioSnapshots`

See `DreamVaultDOC/DreamValutDescription.md` for the full product spec these tables implement.
