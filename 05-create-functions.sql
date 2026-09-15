-- DreamVault :: 05-create-functions.sql
-- A few pure calculation helpers kept in the database for ad-hoc SQL reporting.
-- The API's Calculations/FinanceCalculator.cs is the source of truth used by the application;
-- these mirror the same formulas for anyone querying the database directly.

SET search_path TO "DreamVault";

-- Quantity-weighted average buy price for a stock, based on BUY transactions only.
CREATE OR REPLACE FUNCTION "fn_StockWeightedAvgPrice"(p_stock_id INTEGER)
RETURNS NUMERIC(18,4) AS $$
DECLARE
    v_total_qty   NUMERIC(18,4);
    v_total_cost  NUMERIC(18,4);
BEGIN
    SELECT COALESCE(SUM("Quantity"), 0),
           COALESCE(SUM("Quantity" * "PricePerShare"), 0)
    INTO v_total_qty, v_total_cost
    FROM "StockTransactions"
    WHERE "StockId" = p_stock_id AND "TransactionType" = 'BUY';

    IF v_total_qty = 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND(v_total_cost / v_total_qty, 4);
END;
$$ LANGUAGE plpgsql;

-- Net held quantity for a stock (BUY - SELL, ignoring corporate actions for simplicity).
CREATE OR REPLACE FUNCTION "fn_StockNetQuantity"(p_stock_id INTEGER)
RETURNS NUMERIC(18,4) AS $$
DECLARE
    v_bought NUMERIC(18,4);
    v_sold   NUMERIC(18,4);
BEGIN
    SELECT COALESCE(SUM("Quantity"), 0) INTO v_bought
    FROM "StockTransactions" WHERE "StockId" = p_stock_id AND "TransactionType" = 'BUY';

    SELECT COALESCE(SUM("Quantity"), 0) INTO v_sold
    FROM "StockTransactions" WHERE "StockId" = p_stock_id AND "TransactionType" = 'SELL';

    RETURN v_bought - v_sold;
END;
$$ LANGUAGE plpgsql;

-- CAGR = (FinalValue / InitialValue) ^ (1 / years) - 1, expressed as a percentage.
CREATE OR REPLACE FUNCTION "fn_Cagr"(p_initial NUMERIC, p_final NUMERIC, p_years NUMERIC)
RETURNS NUMERIC(9,4) AS $$
BEGIN
    IF p_initial <= 0 OR p_years <= 0 THEN
        RETURN 0;
    END IF;

    RETURN ROUND((POWER(p_final / p_initial, 1.0 / p_years) - 1) * 100, 4);
END;
$$ LANGUAGE plpgsql;

-- Future value of a lump sum: FV = PV * (1 + r)^n  (r = annual rate as a fraction, n = years)
CREATE OR REPLACE FUNCTION "fn_FutureValueLumpSum"(p_principal NUMERIC, p_annual_rate NUMERIC, p_years NUMERIC)
RETURNS NUMERIC(18,2) AS $$
BEGIN
    RETURN ROUND(p_principal * POWER(1 + p_annual_rate, p_years), 2);
END;
$$ LANGUAGE plpgsql;

-- Future value of a monthly SIP with monthly compounding.
-- monthly_rate = annual_rate / 12 ; months = duration in months.
CREATE OR REPLACE FUNCTION "fn_FutureValueSip"(p_monthly_amount NUMERIC, p_annual_rate NUMERIC, p_months INTEGER)
RETURNS NUMERIC(18,2) AS $$
DECLARE
    v_monthly_rate NUMERIC;
BEGIN
    IF p_months <= 0 THEN
        RETURN 0;
    END IF;

    v_monthly_rate := p_annual_rate / 12.0;

    IF v_monthly_rate = 0 THEN
        RETURN ROUND(p_monthly_amount * p_months, 2);
    END IF;

    RETURN ROUND(
        p_monthly_amount * ((POWER(1 + v_monthly_rate, p_months) - 1) / v_monthly_rate) * (1 + v_monthly_rate),
        2
    );
END;
$$ LANGUAGE plpgsql;

-- Inflation-adjusted future cost: FutureCost = CurrentCost * (1 + inflation)^years
CREATE OR REPLACE FUNCTION "fn_InflationAdjustedCost"(p_current_cost NUMERIC, p_inflation_rate NUMERIC, p_years NUMERIC)
RETURNS NUMERIC(18,2) AS $$
BEGIN
    RETURN ROUND(p_current_cost * POWER(1 + p_inflation_rate, p_years), 2);
END;
$$ LANGUAGE plpgsql;
