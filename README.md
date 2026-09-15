# DreamVaultDB

PostgreSQL scripts for DreamVault, a personal dream/goal/investment planning app with
authentication, roles, and an admin user-management module.

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
| `06-seed-data.sql` | Inserts demo data: Admin/User roles, 2 users (see below), 6 categories, 7 dreams/goals, sample contributions, 6 stocks with buy/sell transactions, and portfolio snapshots |

`Users.PasswordHash` is hashed with ASP.NET Core Identity's `PasswordHasher<T>` (PBKDF2) — the
seed script's hashes correspond to these demo logins (used against `DreamVaultAPI`'s `/api/auth/login`,
which authenticates by **username**, not email):

| Role  | Username | Password |
|---|---|---|
| Admin | `admin` | `Admin@123` |
| User  | `demo` | `Demo@123` |

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

- `Roles`, `Users` — RBAC: `Users.RoleId` → `Roles.RoleId`. Users also carry `IsActive`/`IsLocked`
  (login gating), a failed-login counter (auto-lock after 5 consecutive failures), and soft-delete
  columns (`IsDeleted`/`DeletedDate`/`DeletedBy`) so deleted accounts vanish from user lists while
  their login/audit history stays intact.
- `LoginLogs` — every login attempt (success or failure), with reason, IP, and parsed browser/OS/device.
- `AuditLogs` — admin and data-mutation actions (user CRUD, role changes, password resets, dream/stock changes).
- `Categories`
- `Dreams`, `Goals`, `Contributions` — owned per-user via `Dreams.UserId`.
- `Investments`
- `Stocks`, `StockTransactions` — a single shared portfolio (not per-user); Admin-managed, read-only for `User` accounts.
- `PortfolioSnapshots`

See `DreamVaultDOC/DreamValutDescription.md` for the full product spec these tables implement.
