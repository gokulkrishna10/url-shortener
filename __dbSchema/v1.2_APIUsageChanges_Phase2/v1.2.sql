#1. Drop unused table
Drop table APIQuotaLimit;

#2. Modifications to APIRoutePrice
ALTER TABLE APIRoutePrice
MODIFY COLUMN BasePricePerCall DECIMAL(8,2)  NOT NULL;

#3. Add new column 
ALTER TABLE APIRouteSubscription
ADD COLUMN EndDate DATETIME NULL;

#4 New table for Customer Level Pricing
CREATE TABLE IF NOT EXISTS APICustomerPricing (
	APICustomerPricingId INT NOT NULL AUTO_INCREMENT,
    APINameId INT NOT NULL,
    APICustomerId INT NOT NULL,
    APIRoutePriceId INT NOT NULL,
    DiscountAmountPerCall DECIMAL(8,2) NULL,
    DiscountPercentPerCall DECIMAL(4,2)  NULL,
    SellingPricePerCall DECIMAL(8,2) NOT NULL,
    CONSTRAINT PK_APICustomerPricing PRIMARY KEY (APICustomerPricingId),
    CONSTRAINT FK_APICustomerPricing_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APICustomerPricing_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId),
    CONSTRAINT FK_APICustomerPricing_APIRoutePriceId FOREIGN KEY (APIRoutePriceId) REFERENCES APIRoutePrice(APIRoutePriceId)
);
