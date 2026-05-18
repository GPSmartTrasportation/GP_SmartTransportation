USE GP_SmartTransportDB;
GO



-- 1. COMPOSITE PRIMARY KEYS ON JUNCTION TABLES


ALTER TABLE UserRoles
    ADD CONSTRAINT PK_UserRoles PRIMARY KEY (UserId, RoleId);
GO

ALTER TABLE VehicleTypePreference
    ADD CONSTRAINT PK_VehicleTypePreference PRIMARY KEY (VehicleTypeId, PreferenceId);
GO



-- 2. UNIQUE CONSTRAINTS


-- ---------- Users
ALTER TABLE Users ADD CONSTRAINT UQ_Users_NationalId UNIQUE (NationalId);
ALTER TABLE Users ADD CONSTRAINT UQ_Users_Email      UNIQUE (Email);
ALTER TABLE Users ADD CONSTRAINT UQ_Users_FacebookId UNIQUE (FacebookId);
GO

-- ---------- Drivers
ALTER TABLE Drivers ADD CONSTRAINT UQ_Drivers_NationalId UNIQUE (NationalId);
GO

-- ---------- DriverLicenses
ALTER TABLE DriverLicenses ADD CONSTRAINT UQ_DriverLicenses_LicenseNumber UNIQUE (LicenseNumber);
GO

-- ---------- BusinessDomains
ALTER TABLE BusinessDomains ADD CONSTRAINT UQ_BusinessDomains_DomainName UNIQUE (DomainName);
GO

-- ---------- SubscriptionPlans
ALTER TABLE SubscriptionPlans ADD CONSTRAINT UQ_SubscriptionPlans_PlanCode UNIQUE (PlanCode);
GO

-- ---------- PromoCodes
ALTER TABLE PromoCodes ADD CONSTRAINT UQ_PromoCodes_Code UNIQUE (Code);
GO

-- ---------- UserWallet
ALTER TABLE UserWallet ADD CONSTRAINT UQ_UserWallet_UserId UNIQUE (UserId);
GO



-- 3. FOREIGN KEY CONSTRAINTS
--    (parents must already exist; tables created in DDL are all in place)


-- ---------- Drivers -> Users (1:1 specialisation)
ALTER TABLE Drivers
    ADD CONSTRAINT FK_Drivers_UserId
        FOREIGN KEY (DriverId) REFERENCES Users (UserId);
GO

-- ---------- UserRoles -> Users / Roles
ALTER TABLE UserRoles
    ADD CONSTRAINT FK_UserRoles_UserId
        FOREIGN KEY (UserId) REFERENCES Users (UserId);
ALTER TABLE UserRoles
    ADD CONSTRAINT FK_UserRoles_RoleId
        FOREIGN KEY (RoleId) REFERENCES Roles (RoleId);
GO

-- ---------- Preferences -> BusinessDomains
ALTER TABLE Preferences
    ADD CONSTRAINT FK_Preferences_DomainId
        FOREIGN KEY (DomainId) REFERENCES BusinessDomains (DomainId);
GO

-- ---------- Vehicles -> VehicleTypes
ALTER TABLE Vehicles
    ADD CONSTRAINT FK_Vehicles_VehicleTypeId
        FOREIGN KEY (VehicleTypeId) REFERENCES VehicleTypes (VehicleTypeId);
GO

-- ---------- VehicleTypePreference -> VehicleTypes / Preferences
ALTER TABLE VehicleTypePreference
    ADD CONSTRAINT FK_VehicleTypePreference_VehicleTypeId
        FOREIGN KEY (VehicleTypeId) REFERENCES VehicleTypes (VehicleTypeId);
ALTER TABLE VehicleTypePreference
    ADD CONSTRAINT FK_VehicleTypePreference_PreferenceId
        FOREIGN KEY (PreferenceId) REFERENCES Preferences (PreferenceId);
GO

-- ---------- DriverLicenses -> Drivers
ALTER TABLE DriverLicenses
    ADD CONSTRAINT FK_DriverLicenses_DriverId
        FOREIGN KEY (DriverId) REFERENCES Drivers (DriverId);
GO

-- ---------- BackgroundChecks -> Drivers
ALTER TABLE BackgroundChecks
    ADD CONSTRAINT FK_BackgroundChecks_DriverId
        FOREIGN KEY (DriverId) REFERENCES Drivers (DriverId);
GO

-- ---------- DriverVehicles -> Drivers / Vehicles
ALTER TABLE DriverVehicles
    ADD CONSTRAINT FK_DriverVehicles_DriverId
        FOREIGN KEY (DriverId) REFERENCES Drivers (DriverId);
ALTER TABLE DriverVehicles
    ADD CONSTRAINT FK_DriverVehicles_VehicleId
        FOREIGN KEY (VehicleId) REFERENCES Vehicles (VehicleId);
GO

-- ---------- Cities -> Governorates
ALTER TABLE Cities
    ADD CONSTRAINT FK_Cities_GovernorateId
        FOREIGN KEY (GovernorateId) REFERENCES Governorates (GovernorateId);
GO

-- ---------- Zones -> Cities
ALTER TABLE Zones
    ADD CONSTRAINT FK_Zones_CityId
        FOREIGN KEY (CityId) REFERENCES Cities (CityId);
GO

-- ---------- Sessions -> Drivers / Vehicles / Preferences
ALTER TABLE Sessions
    ADD CONSTRAINT FK_Sessions_DriverId
        FOREIGN KEY (DriverId) REFERENCES Drivers (DriverId);
ALTER TABLE Sessions
    ADD CONSTRAINT FK_Sessions_VehicleId
        FOREIGN KEY (VehicleId) REFERENCES Vehicles (VehicleId);
ALTER TABLE Sessions
    ADD CONSTRAINT FK_Sessions_PreferenceId
        FOREIGN KEY (PreferenceId) REFERENCES Preferences (PreferenceId);
GO

-- ---------- UserWallet -> Users
ALTER TABLE UserWallet
    ADD CONSTRAINT FK_UserWallet_UserId
        FOREIGN KEY (UserId) REFERENCES Users (UserId);
GO

-- ---------- UserSubscriptions -> Users / SubscriptionPlans
ALTER TABLE UserSubscriptions
    ADD CONSTRAINT FK_UserSubscriptions_UserId
        FOREIGN KEY (UserId) REFERENCES Users (UserId);
ALTER TABLE UserSubscriptions
    ADD CONSTRAINT FK_UserSubscriptions_PlanId
        FOREIGN KEY (PlanId) REFERENCES SubscriptionPlans (PlanId);
GO

-- ---------- Rides -> Users / Sessions / Zones (pickup, dropoff)
ALTER TABLE Rides
    ADD CONSTRAINT FK_Rides_UserId
        FOREIGN KEY (UserId) REFERENCES Users (UserId);
ALTER TABLE Rides
    ADD CONSTRAINT FK_Rides_SessionId
        FOREIGN KEY (SessionId) REFERENCES Sessions (SessionId);
ALTER TABLE Rides
    ADD CONSTRAINT FK_Rides_PickupZoneId
        FOREIGN KEY (PickupZoneId) REFERENCES Zones (ZoneId);
ALTER TABLE Rides
    ADD CONSTRAINT FK_Rides_DropoffZoneId
        FOREIGN KEY (DropoffZoneId) REFERENCES Zones (ZoneId);
GO

-- ---------- RideStatusHistory -> Rides / CancellationReasons
ALTER TABLE RideStatusHistory
    ADD CONSTRAINT FK_RideStatusHistory_RideId
        FOREIGN KEY (RideId) REFERENCES Rides (RideId);
ALTER TABLE RideStatusHistory
    ADD CONSTRAINT FK_RideStatusHistory_CancellationReasonId
        FOREIGN KEY (CancellationReasonId) REFERENCES CancellationReasons (CancellationReasonId);
GO

-- ---------- RideRatings -> Rides
ALTER TABLE RideRatings
    ADD CONSTRAINT FK_RideRatings_RideId
        FOREIGN KEY (RideId) REFERENCES Rides (RideId);
GO

-- ---------- PromoCodeRedemptions -> PromoCodes / Users / Rides
ALTER TABLE PromoCodeRedemptions
    ADD CONSTRAINT FK_PromoCodeRedemptions_PromoCodeId
        FOREIGN KEY (PromoCodeId) REFERENCES PromoCodes (PromoCodeId);
ALTER TABLE PromoCodeRedemptions
    ADD CONSTRAINT FK_PromoCodeRedemptions_UserId
        FOREIGN KEY (UserId) REFERENCES Users (UserId);
ALTER TABLE PromoCodeRedemptions
    ADD CONSTRAINT FK_PromoCodeRedemptions_RideId
        FOREIGN KEY (RideId) REFERENCES Rides (RideId);
GO

-- ---------- Payments -> Users / Rides / PromoCodeRedemptions / UserSubscriptions
ALTER TABLE Payments
    ADD CONSTRAINT FK_Payments_UserId
        FOREIGN KEY (UserId) REFERENCES Users (UserId);
ALTER TABLE Payments
    ADD CONSTRAINT FK_Payments_RideId
        FOREIGN KEY (RideId) REFERENCES Rides (RideId);
ALTER TABLE Payments
    ADD CONSTRAINT FK_Payments_PromoCodeRedemptionId
        FOREIGN KEY (PromoCodeRedemptionId) REFERENCES PromoCodeRedemptions (RedemptionId);
ALTER TABLE Payments
    ADD CONSTRAINT FK_Payments_SubscriptionId
        FOREIGN KEY (SubscriptionId) REFERENCES UserSubscriptions (UserSubscriptionId);
GO



-- 4. CHECK CONSTRAINTS (business rules)


-- ---------- Users
ALTER TABLE Users ADD CONSTRAINT CK_Users_AccountStatus
    CHECK (AccountStatus IN ('Active', 'Inactive'));
GO

-- ---------- Roles
ALTER TABLE Roles ADD CONSTRAINT CK_Roles_RoleName
    CHECK (RoleName IN ('Passenger', 'Driver'));
GO

-- ---------- Drivers
ALTER TABLE Drivers ADD CONSTRAINT CK_Drivers_MilitaryServiceStatus
    CHECK (MilitaryServiceStatus IN ('Completed', 'Exempted', 'Postponed', 'N/A'));
GO

ALTER TABLE Drivers ADD CONSTRAINT CK_Drivers_HireDate
    CHECK (HireDate <= CAST(GETDATE() AS DATE));
GO

ALTER TABLE Drivers ADD CONSTRAINT CK_Drivers_CurrentRating
    CHECK (CurrentRating BETWEEN 1.0 AND 5.0);
GO

-- ---------- BusinessDomains
ALTER TABLE BusinessDomains ADD CONSTRAINT CK_BusinessDomains_DomainName
    CHECK (DomainName IN ('Mobility', 'Carrier', 'Freight'));
GO

-- ---------- Preferences
ALTER TABLE Preferences ADD CONSTRAINT CK_Preferences_DomainMatch CHECK (
    (DomainId = 1 AND PreferenceName IN ('Economy', 'Comfort', 'VIP', 'Luxury'))
    OR
    (DomainId = 2 AND PreferenceName IN ('Economy', 'Express', 'Secure'))
    OR
    (DomainId = 3 AND PreferenceName IN ('Standard', 'Heavy', 'Specialty'))
);
GO

-- ---------- VehicleTypes
ALTER TABLE VehicleTypes ADD CONSTRAINT CK_VehicleTypes_TypeName
    CHECK (TypeName IN ('Scooter', 'Sedan', 'Motorcycle', 'PickupTruck', 'HalfTruck'));
GO

ALTER TABLE VehicleTypes ADD CONSTRAINT CK_VehicleTypes_PassengerCapacity
    CHECK (PassengerCapacity BETWEEN 1 AND 10);
GO

ALTER TABLE VehicleTypes ADD CONSTRAINT CK_VehicleTypes_MaxCargoWeightKg
    CHECK (MaxCargoWeightKg >= 0);
GO

-- ---------- DriverLicenses
ALTER TABLE DriverLicenses ADD CONSTRAINT CK_DriverLicenses_LicenseType
    CHECK (LicenseType IN ('Private', 'Truck', 'Motorcycle'));
GO

-- ---------- BackgroundChecks
ALTER TABLE BackgroundChecks ADD CONSTRAINT CK_BackgroundChecks_CertificateType
    CHECK (CertificateType IN ('Criminal Background Check'));
GO

ALTER TABLE BackgroundChecks ADD CONSTRAINT CK_BackgroundChecks_Outcome
    CHECK (Outcome IN ('Passed', 'Failed'));
GO

-- ---------- DriverVehicles
ALTER TABLE DriverVehicles ADD CONSTRAINT CK_DriverVehicles_AssignmentType
    CHECK (AssignmentType IN ('Owned', 'Rented', 'Platform Owned', 'Other'));
GO

-- ---------- CancellationReasons
ALTER TABLE CancellationReasons ADD CONSTRAINT CK_CancellationReasons_AppliesTo
    CHECK (AppliesTo IN ('Passenger', 'Driver', 'System', 'Any'));
GO

-- ---------- Rides
ALTER TABLE Rides ADD CONSTRAINT CK_Rides_CurrentStatus
    CHECK (CurrentStatus IN ('Requested', 'Accepted', 'Completed', 'Cancelled'));
GO

ALTER TABLE Rides ADD CONSTRAINT CK_Rides_ExpectedTimes
    CHECK (ExpectedEndTime >= ExpectedStartTime);
GO

ALTER TABLE Rides ADD CONSTRAINT CK_Rides_ActualTimes
    CHECK (ActualEndTime >= ActualStartTime);
GO

ALTER TABLE Rides ADD CONSTRAINT CK_Rides_StartTime
    CHECK (ActualStartTime >= ExpectedStartTime);
GO

ALTER TABLE Rides ADD CONSTRAINT CK_Rides_PassengerCount
    CHECK (PassengerCount BETWEEN 1 AND 10);
GO

ALTER TABLE Rides ADD CONSTRAINT CK_Rides_CargoWeightKg
    CHECK (CargoWeightKg >= 0);
GO

ALTER TABLE Rides ADD CONSTRAINT CK_Rides_ReceiverPhone
    CHECK (LEN(ReceiverPhone) >= 10);
GO

-- ---------- RideStatusHistory
ALTER TABLE RideStatusHistory ADD CONSTRAINT CK_RideStatusHistory_Status
    CHECK (Status IN ('Requested', 'Accepted', 'Completed', 'Cancelled'));
GO

-- ---------- RideRatings
ALTER TABLE RideRatings ADD CONSTRAINT CK_RideRatings_Score
    CHECK (Score BETWEEN 1 AND 5);
GO

-- ---------- SubscriptionPlans
ALTER TABLE SubscriptionPlans ADD CONSTRAINT CK_SubscriptionPlans_DiscountType
    CHECK (DiscountType IS NULL OR DiscountType IN ('Percentage', 'Amount'));
GO

ALTER TABLE SubscriptionPlans ADD CONSTRAINT CK_SubscriptionPlans_DiscountValue
    CHECK (DiscountValue >= 0);
GO

ALTER TABLE SubscriptionPlans ADD CONSTRAINT CK_SubscriptionPlans_MonthlyPriceEGP
    CHECK (MonthlyPriceEGP >= 0);
GO

-- ---------- PromoCodes
ALTER TABLE PromoCodes ADD CONSTRAINT CK_PromoCodes_DiscountType
    CHECK (DiscountType IN ('Percentage', 'Amount'));
GO

ALTER TABLE PromoCodes ADD CONSTRAINT CK_PromoCodes_DiscountValue
    CHECK (DiscountValue > 0);
GO

ALTER TABLE PromoCodes ADD CONSTRAINT CK_PromoCodes_MaxTotalUses
    CHECK (MaxTotalUses > 0);
GO

ALTER TABLE PromoCodes ADD CONSTRAINT CK_PromoCodes_ValidDates
    CHECK (ValidUntil >= ValidFrom);
GO

-- ---------- PromoCodeRedemptions
ALTER TABLE PromoCodeRedemptions ADD CONSTRAINT CK_PromoCodeRedemptions_DiscountAmount
    CHECK (DiscountAmountApplied >= 0);
GO

-- ---------- UserSubscriptions
-- LockedDiscountType is now nullable; allow NULL in the check.
ALTER TABLE UserSubscriptions ADD CONSTRAINT CK_UserSubscriptions_Status
    CHECK (Status IN ('Active', 'Expired', 'Cancelled'));
GO

ALTER TABLE UserSubscriptions ADD CONSTRAINT CK_UserSubscriptions_Dates
    CHECK (EndDate >= StartDate);
GO

ALTER TABLE UserSubscriptions ADD CONSTRAINT CK_UserSubscriptions_LockedDiscountType
    CHECK (LockedDiscountType IS NULL OR LockedDiscountType IN ('Percentage', 'Amount'));
GO

ALTER TABLE UserSubscriptions ADD CONSTRAINT CK_UserSubscriptions_AutoRenew
    CHECK (AutoRenew IN (0, 1));
GO

-- ---------- UserWallet
ALTER TABLE UserWallet ADD CONSTRAINT CK_UserWallet_Balance
    CHECK (Balance >= 0);
GO

-- ---------- Payments
ALTER TABLE Payments ADD CONSTRAINT CK_Payments_Status
    CHECK (Status IN ('Pending', 'Completed', 'Failed', 'Refunded'));
GO

-- Refund rows must carry non-positive amounts; everything else non-negative.
ALTER TABLE Payments ADD CONSTRAINT CK_Payments_AmountSignByStatus CHECK (
    (Status = 'Refunded' AND
        Amount                      <= 0 AND
        DriverEarningAmount         <= 0 AND
        PlatformCommissionAmount    <= 0 AND
        SubscriptionDiscountAmount  <= 0 AND
        PromoDiscountAmount         <= 0)
    OR
    (Status <> 'Refunded' AND
        Amount                      >= 0 AND
        DriverEarningAmount         >= 0 AND
        PlatformCommissionAmount    >= 0 AND
        SubscriptionDiscountAmount  >= 0 AND
        PromoDiscountAmount         >= 0)
);
GO



-- 5. FILTERED UNIQUE INDEXES (only-one-active rules)


-- A vehicle can have at most one open DriverVehicles assignment at a time.
CREATE UNIQUE INDEX UX_DriverVehicles_OneActivePerVehicle
    ON DriverVehicles (VehicleId)
    WHERE EndDate IS NULL;
GO

-- A driver can have at most one open Session at a time.
CREATE UNIQUE INDEX UX_Sessions_OneActivePerDriver
    ON Sessions (DriverId)
    WHERE OfflineAt IS NULL;
GO

