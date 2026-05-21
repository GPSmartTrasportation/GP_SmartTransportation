USE [GP_SmartTransportDWH];
GO

----> DIMENSIONS 

ALTER TABLE marts.dim_date
    ALTER COLUMN date_key int NOT NULL;
ALTER TABLE marts.dim_date
    ADD CONSTRAINT PK_dim_date PRIMARY KEY NONCLUSTERED (date_key);
GO

ALTER TABLE marts.dim_time
    ALTER COLUMN time_key int NOT NULL;
ALTER TABLE marts.dim_time
    ADD CONSTRAINT PK_dim_time PRIMARY KEY NONCLUSTERED (time_key);
GO

ALTER TABLE marts.dim_user
    ALTER COLUMN user_key varchar(50) NOT NULL;
ALTER TABLE marts.dim_user
    ADD CONSTRAINT PK_dim_user PRIMARY KEY NONCLUSTERED (user_key);
GO

ALTER TABLE marts.dim_driver
    ALTER COLUMN driver_key varchar(50) NOT NULL;
ALTER TABLE marts.dim_driver
    ADD CONSTRAINT PK_dim_driver PRIMARY KEY NONCLUSTERED (driver_key);
GO

ALTER TABLE marts.dim_vehicle
    ALTER COLUMN vehicle_key varchar(50) NOT NULL;
ALTER TABLE marts.dim_vehicle
    ADD CONSTRAINT PK_dim_vehicle PRIMARY KEY NONCLUSTERED (vehicle_key);
GO

ALTER TABLE marts.dim_preference
    ALTER COLUMN preference_key varchar(50) NOT NULL;
ALTER TABLE marts.dim_preference
    ADD CONSTRAINT PK_dim_preference PRIMARY KEY NONCLUSTERED (preference_key);
GO

ALTER TABLE marts.dim_geography
    ALTER COLUMN zone_key varchar(50) NOT NULL;
ALTER TABLE marts.dim_geography
    ADD CONSTRAINT PK_dim_geography PRIMARY KEY NONCLUSTERED (zone_key);
GO

ALTER TABLE marts.dim_subscription_plan
    ALTER COLUMN plan_key varchar(50) NOT NULL;
ALTER TABLE marts.dim_subscription_plan
    ADD CONSTRAINT PK_dim_subscription_plan PRIMARY KEY NONCLUSTERED (plan_key);
GO

ALTER TABLE marts.dim_promo_code
    ALTER COLUMN promo_code_key varchar(50) NOT NULL;
ALTER TABLE marts.dim_promo_code
    ADD CONSTRAINT PK_dim_promo_code PRIMARY KEY NONCLUSTERED (promo_code_key);
GO

ALTER TABLE marts.dim_cancellation_reason
    ALTER COLUMN cancellation_reason_key varchar(50) NOT NULL;
ALTER TABLE marts.dim_cancellation_reason
    ADD CONSTRAINT PK_dim_cancellation_reason PRIMARY KEY NONCLUSTERED (cancellation_reason_key);
GO

----> FACTS


ALTER TABLE marts.fact_rides
    ALTER COLUMN ride_key varchar(50) NOT NULL;
ALTER TABLE marts.fact_rides
    ADD CONSTRAINT PK_fact_rides PRIMARY KEY NONCLUSTERED (ride_key);
GO

ALTER TABLE marts.fact_payments
    ALTER COLUMN payment_key varchar(50) NOT NULL;
ALTER TABLE marts.fact_payments
    ADD CONSTRAINT PK_fact_payments PRIMARY KEY NONCLUSTERED (payment_key);
GO

ALTER TABLE marts.fact_sessions
    ALTER COLUMN session_key varchar(50) NOT NULL;
ALTER TABLE marts.fact_sessions
    ADD CONSTRAINT PK_fact_sessions PRIMARY KEY NONCLUSTERED (session_key);
GO

ALTER TABLE marts.fact_ride_ratings
    ALTER COLUMN rating_key varchar(50) NOT NULL;
ALTER TABLE marts.fact_ride_ratings
    ADD CONSTRAINT PK_fact_ride_ratings PRIMARY KEY NONCLUSTERED (rating_key);
GO

ALTER TABLE marts.fact_user_subscriptions
    ALTER COLUMN user_subscription_key varchar(50) NOT NULL;
ALTER TABLE marts.fact_user_subscriptions
    ADD CONSTRAINT PK_fact_user_subscriptions PRIMARY KEY NONCLUSTERED (user_subscription_key);
GO

ALTER TABLE marts.fact_promo_code_redemptions
    ALTER COLUMN redemption_key varchar(50) NOT NULL;
ALTER TABLE marts.fact_promo_code_redemptions
    ADD CONSTRAINT PK_fact_promo_code_redemptions PRIMARY KEY NONCLUSTERED (redemption_key);
GO
