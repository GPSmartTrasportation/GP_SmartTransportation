-- 1. CREATE DATABASE

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'GP_SmartTransportDB')
    DROP DATABASE GP_SmartTransportDB;
GO

CREATE DATABASE GP_SmartTransportDB;
GO

USE GP_SmartTransportDB;
GO



-- 2. REFERENCE TABLES


-- ---------- Roles
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Roles' AND type = 'U')
CREATE TABLE Roles (
    RoleId      INT          NOT NULL,
    RoleName    VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_Roles PRIMARY KEY CLUSTERED (RoleId)
);
GO

-- ---------- VehicleTypes
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'VehicleTypes' AND type = 'U')
CREATE TABLE VehicleTypes (
    VehicleTypeId       INT             NOT NULL,
    TypeName            VARCHAR(50)     NOT NULL,
    PassengerCapacity   INT             NULL,
    MaxCargoWeightKg    DECIMAL(10,2)   NULL,
    CONSTRAINT PK_VehicleTypes PRIMARY KEY CLUSTERED (VehicleTypeId)
);
GO

-- ---------- BusinessDomains
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'BusinessDomains' AND type = 'U')
CREATE TABLE BusinessDomains (
    DomainId    INT          NOT NULL,
    DomainName  VARCHAR(50)  NOT NULL,
    CONSTRAINT PK_BusinessDomains PRIMARY KEY CLUSTERED (DomainId)
);
GO

-- ---------- Governorates
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Governorates' AND type = 'U')
CREATE TABLE Governorates (
    GovernorateId       INT           NOT NULL,
    GovernorateNameAr   NVARCHAR(50)  NULL,
    GovernorateNameEn   VARCHAR(50)   NULL,
    CONSTRAINT PK_Governorates PRIMARY KEY CLUSTERED (GovernorateId)
);
GO

-- ---------- CancellationReasons
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'CancellationReasons' AND type = 'U')
CREATE TABLE CancellationReasons (
    CancellationReasonId    INT            NOT NULL,
    ReasonTitle             VARCHAR(100)   NOT NULL,
    AppliesTo               NVARCHAR(50)   NULL,
    DescriptionAr           NVARCHAR(500)  NULL,
    DescriptionEn           NVARCHAR(500)  NULL,
    CONSTRAINT PK_CancellationReasons PRIMARY KEY CLUSTERED (CancellationReasonId)
);
GO

-- ---------- SubscriptionPlans
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'SubscriptionPlans' AND type = 'U')
CREATE TABLE SubscriptionPlans (
    PlanId           INT             NOT NULL,
    PlanCode         VARCHAR(50)     NOT NULL,
    PlanNameAr       NVARCHAR(100)   NOT NULL,
    PlanNameEn       VARCHAR(100)    NOT NULL,
    MonthlyPriceEGP  DECIMAL(10,2)   NOT NULL,
    DiscountType     VARCHAR(50)     NULL,
    DiscountValue    DECIMAL(10,2)   NULL,
    IsActive         BIT             NOT NULL,
    CONSTRAINT PK_SubscriptionPlans PRIMARY KEY CLUSTERED (PlanId)
);
GO

-- ---------- PromoCodes
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PromoCodes' AND type = 'U')
CREATE TABLE PromoCodes (
    PromoCodeId         INT             NOT NULL,
    Code                VARCHAR(50)     NOT NULL,
    Description         NVARCHAR(255)   NULL,
    DiscountType        VARCHAR(50)     NULL,
    DiscountValue       DECIMAL(10,2)   NULL,
    MaxDiscountAmount   DECIMAL(10,2)   NULL,
    MinRideAmount       DECIMAL(10,2)   NULL,
    ValidFrom           DATE            NULL,
    ValidUntil          DATE            NULL,
    MaxTotalUses        INT             NULL,
    IsActive            BIT             NOT NULL,
    CONSTRAINT PK_PromoCodes PRIMARY KEY CLUSTERED (PromoCodeId)
);
GO



-- 3. CORE IDENTITY TABLES


-- ---------- Users
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Users' AND type = 'U')
CREATE TABLE Users (
    UserId          INT             NOT NULL,
    NationalId      VARCHAR(20)     NULL,
    FullNameAr      NVARCHAR(100)   NULL,
    FullNameEn      VARCHAR(100)    NULL,
    DateOfBirth     DATE            NULL,
    PhoneNumber     VARCHAR(20)     NULL,
    Email           VARCHAR(150)    NULL,
    PasswordHash    VARCHAR(256)    NULL,
    AccountStatus   VARCHAR(20)     NULL,
    CreatedAt       DATETIME        NULL,
    FacebookId      VARCHAR(100)    NULL,
    FacebookUrl     VARCHAR(200)    NULL,
    CONSTRAINT PK_Users PRIMARY KEY CLUSTERED (UserId)
);
GO

-- ---------- Drivers
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Drivers' AND type = 'U')
CREATE TABLE Drivers (
    DriverId                INT             NOT NULL,
    NationalId              VARCHAR(20)     NULL,
    MilitaryServiceStatus   VARCHAR(50)     NULL,
    HireDate                DATE            NULL,
    CurrentRating           DECIMAL(3,2)    NULL,
    CONSTRAINT PK_Drivers PRIMARY KEY CLUSTERED (DriverId)
);
GO

-- ---------- UserRoles
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'UserRoles' AND type = 'U')
CREATE TABLE UserRoles (
    UserId  INT NOT NULL,
    RoleId  INT NOT NULL
);
GO



-- 4. FLEET & PREFERENCE TABLES


-- ---------- Preferences
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Preferences' AND type = 'U')
CREATE TABLE Preferences (
    PreferenceId    INT             NOT NULL,
    PreferenceName  VARCHAR(100)    NOT NULL,
    DomainId        INT             NOT NULL,
    CONSTRAINT PK_Preferences PRIMARY KEY CLUSTERED (PreferenceId)
);
GO

-- ---------- Vehicles
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Vehicles' AND type = 'U')
CREATE TABLE Vehicles (
    VehicleId           INT             NOT NULL,
    VehicleTypeId       INT             NULL,
    Brand               VARCHAR(100)    NULL,
    ManufactureYear     INT             NULL,
    LicensePlateAr      NVARCHAR(50)    NOT NULL,
    HasAirConditioning  BIT             NULL,
    CONSTRAINT PK_Vehicles PRIMARY KEY CLUSTERED (VehicleId)
);
GO

-- ---------- VehicleTypePreference  
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'VehicleTypePreference' AND type = 'U')
CREATE TABLE VehicleTypePreference (
    VehicleTypeId   INT NOT NULL,
    PreferenceId    INT NOT NULL
);
GO

-- ---------- DriverLicenses
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'DriverLicenses' AND type = 'U')
CREATE TABLE DriverLicenses (
    LicenseId       INT             NOT NULL,
    DriverId        INT             NOT NULL,
    LicenseNumber   VARCHAR(50)     NOT NULL,
    LicenseType     VARCHAR(50)     NULL,
    ExpiryDate      DATE            NOT NULL,
    CONSTRAINT PK_DriverLicenses PRIMARY KEY CLUSTERED (LicenseId)
);
GO

-- ---------- BackgroundChecks
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'BackgroundChecks' AND type = 'U')
CREATE TABLE BackgroundChecks (
    BackgroundCheckId   INT             NOT NULL,
    DriverId            INT             NOT NULL,
    CertificateType     VARCHAR(50)     NULL,
    CheckDate           DATE            NULL,
    Outcome             VARCHAR(20)     NULL,
    ExpiryDate          DATE            NULL,
    CONSTRAINT PK_BackgroundChecks PRIMARY KEY CLUSTERED (BackgroundCheckId)
);
GO

-- ---------- DriverVehicles
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'DriverVehicles' AND type = 'U')
CREATE TABLE DriverVehicles (
    AssignmentId    INT             NOT NULL,
    VehicleId       INT             NOT NULL,
    DriverId        INT             NOT NULL,
    AssignmentType  VARCHAR(50)     NOT NULL,
    StartDate       DATE            NOT NULL,
    EndDate         DATE            NULL,
    CONSTRAINT PK_DriverVehicles PRIMARY KEY CLUSTERED (AssignmentId)
);
GO



-- 5. GEOGRAPHY TABLES   (Governorates -> Cities -> Zones)


-- ---------- Cities
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Cities' AND type = 'U')
CREATE TABLE Cities (
    CityId          SMALLINT        NOT NULL,
    GovernorateId   INT             NOT NULL,
    CityNameAr      NVARCHAR(50)    NOT NULL,
    CityNameEn      VARCHAR(50)     NOT NULL,
    CONSTRAINT PK_Cities PRIMARY KEY CLUSTERED (CityId)
);
GO

-- ---------- Zones
-- NOTE: CityId datatype now matches Cities.CityId (SMALLINT)
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Zones' AND type = 'U')
CREATE TABLE Zones (
    ZoneId      INT             NOT NULL,
    CityId      SMALLINT        NOT NULL,
    ZoneNameAr  NVARCHAR(100)   NOT NULL,
    ZoneNameEn  VARCHAR(100)    NOT NULL,
    IsActive    BIT             NOT NULL,
    CONSTRAINT PK_Zones PRIMARY KEY CLUSTERED (ZoneId)
);
GO



-- 6. OPERATIONS — Sessions (renamed from Shifts)


-- ---------- Sessions   (renamed from Shifts)
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Sessions' AND type = 'U')
CREATE TABLE Sessions (
    SessionId       INT         NOT NULL,
    DriverId        INT         NOT NULL,
    VehicleId       INT         NOT NULL,
    PreferenceId    INT         NOT NULL,
    OnlineAt        DATETIME    NOT NULL,
    OfflineAt       DATETIME    NULL,
    CONSTRAINT PK_Sessions PRIMARY KEY CLUSTERED (SessionId)
);
GO



-- 7. WALLETS & SUBSCRIPTIONS


-- ---------- UserWallet
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'UserWallet' AND type = 'U')
CREATE TABLE UserWallet (
    WalletId    INT             NOT NULL,
    UserId      INT             NOT NULL,
    Balance     DECIMAL(12,2)   NOT NULL,
    Currency    CHAR(3)         NOT NULL DEFAULT 'EGP',
    UpdatedAt   DATETIME        NOT NULL,
    CONSTRAINT PK_UserWallet PRIMARY KEY CLUSTERED (WalletId)
);
GO

-- ---------- UserSubscriptions
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'UserSubscriptions' AND type = 'U')
CREATE TABLE UserSubscriptions (
    UserSubscriptionId      INT             NOT NULL,
    UserId                  INT             NOT NULL,
    PlanId                  INT             NOT NULL,
    StartDate               DATE            NULL,
    EndDate                 DATE            NULL,
    NextRenewalDate         DATE            NULL,
    Status                  VARCHAR(50)     NULL,
    AutoRenew               BIT             NULL,
    LockedMonthlyPriceEGP   DECIMAL(10,2)   NULL,
    LockedDiscountType      VARCHAR(50)     NULL,
    LockedDiscountValue     DECIMAL(10,2)   NULL,
    CancelledAt             DATETIME        NULL,
    CONSTRAINT PK_UserSubscriptions PRIMARY KEY CLUSTERED (UserSubscriptionId)
);
GO



-- 8. RIDES & RELATED HISTORY


-- ---------- Rides
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Rides' AND type = 'U')
CREATE TABLE Rides (
    RideId              INT             NOT NULL,
    UserId              INT             NOT NULL,
    SessionId           INT             NOT NULL,
    PickupZoneId        INT             NOT NULL,
    DropoffZoneId       INT             NOT NULL,
    CurrentStatus       VARCHAR(50)     NULL,
    ExpectedStartTime   DATETIME        NULL,
    ExpectedEndTime     DATETIME        NULL,
    ActualStartTime     DATETIME        NULL,
    ActualEndTime       DATETIME        NULL,
    PassengerCount      INT             NULL,
    CargoWeightKg       DECIMAL(10,2)   NULL,
    CargoType           VARCHAR(50)     NULL,
    ReceiverName        NVARCHAR(50)    NULL,
    ReceiverPhone       VARCHAR(20)     NULL,
    CONSTRAINT PK_Rides PRIMARY KEY CLUSTERED (RideId)
);
GO

-- ---------- RideStatusHistory
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'RideStatusHistory' AND type = 'U')
CREATE TABLE RideStatusHistory (
    StatusHistoryId         INT             NOT NULL,
    RideId                  INT             NOT NULL,
    Status                  VARCHAR(50)     NOT NULL,
    ChangedAt               DATETIME        NOT NULL,
    CancellationReasonId    INT             NULL,
    CONSTRAINT PK_RideStatusHistory PRIMARY KEY CLUSTERED (StatusHistoryId)
);
GO

-- ---------- RideRatings
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'RideRatings' AND type = 'U')
CREATE TABLE RideRatings (
    RatingId    INT             NOT NULL,
    RideId      INT             NOT NULL,
    RaterRole   VARCHAR(50)     NULL,
    Score       INT             NULL,
    Comment     NVARCHAR(500)   NULL,
    CreatedAt   DATETIME        NULL,
    CONSTRAINT PK_RideRatings PRIMARY KEY CLUSTERED (RatingId)
);
GO



-- 9. PROMO CODE REDEMPTIONS  (depends on PromoCodes, Users, Rides)


-- ---------- PromoCodeRedemptions
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'PromoCodeRedemptions' AND type = 'U')
CREATE TABLE PromoCodeRedemptions (
    RedemptionId            INT             NOT NULL,
    PromoCodeId             INT             NOT NULL,
    UserId                  INT             NOT NULL,
    RideId                  INT             NOT NULL,
    DiscountAmountApplied   DECIMAL(10,2)   NOT NULL,
    RedeemedAt              DATETIME        NOT NULL,
    CONSTRAINT PK_PromoCodeRedemptions PRIMARY KEY CLUSTERED (RedemptionId)
);
GO



-- 10. PAYMENTS  (depends on Users, Rides, PromoCodeRedemptions, UserSubscriptions)


-- ---------- Payments
IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'Payments' AND type = 'U')
CREATE TABLE Payments (
    PaymentId                   INT             NOT NULL,
    UserId                      INT             NOT NULL,
    RideId                      INT             NULL,
    PromoCodeRedemptionId       INT             NULL,
    SubscriptionId              INT             NULL,
    PaymentType                 VARCHAR(50)     NULL,
    Status                      VARCHAR(50)     NULL,
    Amount                      DECIMAL(10,2)   NULL,
    DriverEarningAmount         DECIMAL(10,2)   NULL,
    PlatformCommissionAmount    DECIMAL(10,2)   NULL,
    SubscriptionDiscountAmount  DECIMAL(10,2)   NULL,
    PromoDiscountAmount         DECIMAL(10,2)   NULL,
    OccurredAt                  DATETIME        NULL,
    CONSTRAINT PK_Payments PRIMARY KEY CLUSTERED (PaymentId)
);
GO