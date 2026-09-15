-- DreamVault :: 01-create-database.sql
-- Creates the DreamVaultDB database.
-- Run this connected to the default 'postgres' database as a superuser (e.g. psql -U postgres).

SELECT 'CREATE DATABASE "DreamVaultDB"'
WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'DreamVaultDB')
\gexec
