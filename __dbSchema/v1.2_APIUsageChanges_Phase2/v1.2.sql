#1. Drop unused table
Drop table APIQuotaLimit;

#2. Modifications to APIRoutePrice
ALTER TABLE APIRoutePrice
MODIFY COLUMN BasePricePerCall DECIMAL(8,2)  NOT NULL;

#3. Add new column 
ALTER TABLE APIRouteSubscription
ADD COLUMN EndDate DATETIME NULL;

#4 New tables for Billing
CREATE TABLE IF NOT EXISTS APICustomerPricing (
	APICustomerPricingId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    APINameId INT NOT NULL REFERENCES APIName,
    APIRouteId INT NOT NULL REFERENCES APIRoute,
    APICustomerId INT NOT NULL REFERENCES APICustomer,
    APIPricingTierId INT NOT NULL REFERENCES APIPricingTier,
    DiscountAmountPerCall DECIMAL(8,2) NULL,
    DiscountPercentPerCall DECIMAL(4,2)  NULL,
    SellingPricePerCall DECIMAL(8,2) NOT NULL,
    StartDate TIMESTAMP NOT NULL,
    EndDate TIMESTAMP NULL,
    CONSTRAINT UK_APICustomerPricing_PricePerRoute UNIQUE(APICustomerId, APINameId, APIRouteId, APIPricingTierId, IsActive)
);


CREATE TABLE IF NOT EXISTS APIRoutePricingTierMap (
	APIRoutePricingTierMapId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    APIRouteId INT NOT NULL REFERENCES APIRoutePrice,
    APIPricingTierId INT NOT NULL REFERENCES APIPricingTier,
    BasePricePerCall DECIMAL(8,2) NOT NULL,
    CONSTRAINT UK_APIPricingTier UNIQUE(APIRouteId, APIPricingTierId)
);

CREATE TABLE IF NOT EXISTS APIPricingTier (
	APIPricingTierId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    CONSTRAINT UK_APIPricingTier UNIQUE(Name)
);

INSERT INTO APIPricingTier(Name) VALUES ('TIER1');
INSERT INTO APIPricingTier(Name) VALUES ('TIER2');
INSERT INTO APIPricingTier(Name) VALUES ('TIER3');


#5 Log more details to the APIUsage table
ALTER TABLE APIUsage
ADD COLUMN RequestData JSON NULL;

ALTER TABLE APIUsage
ADD COLUMN ResponseData BLOB NULL;

ALTER TABLE APIUsage
ADD COLUMN ModifiedBy varchar(100) NULL;

#5 Log more details to the APIError table
ALTER TABLE APIError
ADD COLUMN RequestData JSON NULL;

ALTER TABLE APIError
ADD COLUMN ResponseData BLOB NULL;

ALTER TABLE APIError
ADD COLUMN ModifiedBy varchar(100) NULL;

