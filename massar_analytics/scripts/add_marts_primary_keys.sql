/*
  GP Smart Transportation — add PRIMARY KEY constraints on marts (gold) tables.
  Run in SSMS against GP_SmartTransportDWH after dbt build completes.

  Step 1: Run the inspection block and review output.
  Step 2: Run the PK block (uncomment BEGIN TRANSACTION if you want a single rollback).
*/

USE [GP_SmartTransportDWH];
GO

/* =============================================================================
   STEP 1 — Inspect PK columns, data types, and indexes
   ============================================================================= */
DECLARE @pk_map TABLE (
    table_name  sysname NOT NULL,
    pk_column   sysname NOT NULL
);

INSERT INTO @pk_map (table_name, pk_column) VALUES
    (N'dim_date',                    N'date_key'),
    (N'dim_time',                    N'time_key'),
    (N'dim_user',                    N'user_key'),
    (N'dim_driver',                  N'driver_key'),
    (N'dim_vehicle',                 N'vehicle_key'),
    (N'dim_preference',              N'preference_key'),
    (N'dim_geography',               N'zone_key'),
    (N'dim_subscription_plan',       N'plan_key'),
    (N'dim_promo_code',              N'promo_code_key'),
    (N'dim_cancellation_reason',     N'cancellation_reason_key'),
    (N'fact_rides',                  N'ride_key'),
    (N'fact_payments',               N'payment_key'),
    (N'fact_sessions',               N'session_key'),
    (N'fact_ride_ratings',           N'rating_key'),
    (N'fact_user_subscriptions',     N'user_subscription_key'),
    (N'fact_promo_code_redemptions', N'redemption_key');

-- Column types and nullability
SELECT
    m.table_name,
    m.pk_column,
    c.is_nullable,
    ty.name AS data_type,
    c.max_length,
    c.precision,
    c.scale
FROM @pk_map AS m
INNER JOIN sys.tables AS t
    ON t.name = m.table_name
INNER JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
   AND s.name = N'marts'
INNER JOIN sys.columns AS c
    ON c.object_id = t.object_id
   AND c.name = m.pk_column
INNER JOIN sys.types AS ty
    ON ty.user_type_id = c.user_type_id
ORDER BY m.table_name;

-- Existing primary keys and columnstore indexes
SELECT
    s.name AS schema_name,
    t.name AS table_name,
    i.name AS index_name,
    i.type_desc,
    i.is_primary_key
FROM sys.indexes AS i
INNER JOIN sys.tables AS t
    ON t.object_id = i.object_id
INNER JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
WHERE s.name = N'marts'
  AND (
        i.is_primary_key = 1
        OR i.type = 5  /* columnstore */
      )
ORDER BY t.name, i.name;
GO

/* =============================================================================
   STEP 2 — Add NOT NULL + NONCLUSTERED PRIMARY KEY (safe with columnstore)
   ============================================================================= */
SET NOCOUNT ON;

DECLARE @pk_map TABLE (
    table_name  sysname NOT NULL,
    pk_column   sysname NOT NULL
);

INSERT INTO @pk_map (table_name, pk_column) VALUES
    (N'dim_date',                    N'date_key'),
    (N'dim_time',                    N'time_key'),
    (N'dim_user',                    N'user_key'),
    (N'dim_driver',                  N'driver_key'),
    (N'dim_vehicle',                 N'vehicle_key'),
    (N'dim_preference',              N'preference_key'),
    (N'dim_geography',               N'zone_key'),
    (N'dim_subscription_plan',       N'plan_key'),
    (N'dim_promo_code',              N'promo_code_key'),
    (N'dim_cancellation_reason',     N'cancellation_reason_key'),
    (N'fact_rides',                  N'ride_key'),
    (N'fact_payments',               N'payment_key'),
    (N'fact_sessions',               N'session_key'),
    (N'fact_ride_ratings',           N'rating_key'),
    (N'fact_user_subscriptions',     N'user_subscription_key'),
    (N'fact_promo_code_redemptions', N'redemption_key');

DECLARE
    @table_name   sysname,
    @pk_column    sysname,
    @object_id    int,
    @type_decl    nvarchar(128),
    @sql          nvarchar(max),
    @constraint   sysname;

DECLARE pk_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT table_name, pk_column
    FROM @pk_map
    ORDER BY table_name;

OPEN pk_cursor;
FETCH NEXT FROM pk_cursor INTO @table_name, @pk_column;

-- BEGIN TRANSACTION;  /* optional: wrap all changes in one transaction */

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @object_id = OBJECT_ID(QUOTENAME(N'marts') + N'.' + QUOTENAME(@table_name));

    IF @object_id IS NULL
    BEGIN
        RAISERROR(N'Table marts.%s not found. Run dbt build first.', 16, 1, @table_name);
        FETCH NEXT FROM pk_cursor INTO @table_name, @pk_column;
        CONTINUE;
    END

    SELECT @type_decl =
        CASE
            WHEN ty.name IN (N'varchar', N'char', N'varbinary', N'binary')
                THEN ty.name + N'(' +
                    CASE
                        WHEN c.max_length = -1 THEN N'max'
                        ELSE CAST(c.max_length AS nvarchar(10))
                    END + N')'
            WHEN ty.name IN (N'nvarchar', N'nchar')
                THEN ty.name + N'(' +
                    CASE
                        WHEN c.max_length = -1 THEN N'max'
                        ELSE CAST(c.max_length / 2 AS nvarchar(10))
                    END + N')'
            WHEN ty.name IN (N'decimal', N'numeric')
                THEN ty.name + N'(' + CAST(c.precision AS nvarchar(10)) + N',' + CAST(c.scale AS nvarchar(10)) + N')'
            ELSE ty.name
        END
    FROM sys.columns AS c
    INNER JOIN sys.types AS ty
        ON ty.user_type_id = c.user_type_id
    WHERE c.object_id = @object_id
      AND c.name = @pk_column;

    IF @type_decl IS NULL
    BEGIN
        RAISERROR(N'Column marts.%s.%s not found.', 16, 1, @table_name, @pk_column);
        FETCH NEXT FROM pk_cursor INTO @table_name, @pk_column;
        CONTINUE;
    END

    SET @constraint = N'PK_' + @table_name;

    /* Drop existing primary key */
    SELECT @sql = N'ALTER TABLE ' + QUOTENAME(N'marts') + N'.' + QUOTENAME(@table_name)
        + N' DROP CONSTRAINT ' + QUOTENAME(kc.name) + N';'
    FROM sys.key_constraints AS kc
    WHERE kc.parent_object_id = @object_id
      AND kc.type = N'PK';

    IF @sql IS NOT NULL
        EXEC sys.sp_executesql @sql;

    SET @sql = NULL;

    /* Enforce NOT NULL using the column's current type */
    SET @sql = N'ALTER TABLE ' + QUOTENAME(N'marts') + N'.' + QUOTENAME(@table_name)
        + N' ALTER COLUMN ' + QUOTENAME(@pk_column) + N' ' + @type_decl + N' NOT NULL;';
    EXEC sys.sp_executesql @sql;

    /* Add nonclustered PK (works if a columnstore index exists) */
    SET @sql = N'ALTER TABLE ' + QUOTENAME(N'marts') + N'.' + QUOTENAME(@table_name)
        + N' ADD CONSTRAINT ' + QUOTENAME(@constraint)
        + N' PRIMARY KEY NONCLUSTERED (' + QUOTENAME(@pk_column) + N');';
    EXEC sys.sp_executesql @sql;

    PRINT N'Added PK on marts.' + @table_name + N' (' + @pk_column + N')';

    FETCH NEXT FROM pk_cursor INTO @table_name, @pk_column;
END

CLOSE pk_cursor;
DEALLOCATE pk_cursor;

-- COMMIT TRANSACTION;

/* =============================================================================
   STEP 3 — Verify
   ============================================================================= */
SELECT
    s.name AS schema_name,
    t.name AS table_name,
    kc.name AS pk_name,
    col.name AS pk_column
FROM sys.key_constraints AS kc
INNER JOIN sys.tables AS t
    ON t.object_id = kc.parent_object_id
INNER JOIN sys.schemas AS s
    ON s.schema_id = t.schema_id
INNER JOIN sys.index_columns AS ic
    ON ic.object_id = kc.parent_object_id
   AND ic.index_id = kc.unique_index_id
INNER JOIN sys.columns AS col
    ON col.object_id = ic.object_id
   AND col.column_id = ic.column_id
WHERE s.name = N'marts'
  AND kc.type = N'PK'
ORDER BY t.name;
GO
