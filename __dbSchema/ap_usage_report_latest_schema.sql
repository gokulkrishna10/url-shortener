/*
--Connetion details
server: openenergy.crjdegsnxmp2.eu-west-1.rds.amazonaws.com
Schema : api_usage_report_dev
userName:  api_usasge_report_devuser
password: 891f5b0d-6873-4b5f-a0ae-9b890ed0739d

--Connetion details
Host : oeprodrds.crjdegsnxmp2.eu-west-1.rds.amazonaws.com
Schema : api_usage_report_prod
userName:  api_usasge_report_produser
password: be293b19-5ab2-4cf6-9f4b-85d574e898b9


DESIGN DECISIONS:
1. Pricing Plan:
Chose to follow a simple plan where we define the pricing only for the PayAsYouGo plan. All the other plans follow
a discuont scheme basd on the BasePrice defined for PayAsYouGo plan.


*/


USE api_usage_report_dev;

/* ====================================================================================================
Description: This table contains data for an API Customer

*/

CREATE TABLE IF NOT EXISTS APICustomer (
	APICustomerId INT NOT NULL AUTO_INCREMENT,
    APIKey VARCHAR(100) NOT NULL,
    CustomerName VARCHAR(50) NOT NULL,
    LegalName VARCHAR(100) NOT NULL,
	Address VARCHAR(500) NULL,
    Email VARCHAR(255) NOT NULL,
    IsActive TINYINT NOT NULL,
	CreateDate DATETIME NOT NULL DEFAULT NOW(),
	UpdateDate DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_APICustomer PRIMARY KEY (APICustomerId) 
);



/* ====================================================================================================
Description: This table contains the APIName details

*/

CREATE TABLE IF NOT EXISTS APIName (
	APINameId INT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    DisplayName VARCHAR(100) NOT NULL,
    Description VARCHAR(200) NOT NULL,
	CreateDate DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_APIName PRIMARY KEY (APINameid),
    CONSTRAINT UK_APIName_APIName UNIQUE(Name),
    CONSTRAINT UK_APIName_APIName UNIQUE(Name),
    CONSTRAINT UK_APIName_DisplayName UNIQUE(DisplayName)
);


/* ====================================================================================================
Description: This table stores the APIRoutes for monetization. One API will have a single entry with EndPointName as "/"
. If another endpoint need a special pricing, another entry will be created for that endpoint only.

NOTES:
1. 
EndpointName = / or specific endpointName, / - if you have same metering for all the Endpoints
			   Check for specific end point and if not existing, look for -> /
*/

CREATE TABLE IF NOT EXISTS APIRoute (
	APIRouteId INT NOT NULL AUTO_INCREMENT,
    APINameId INT NOT NULL,
    APIVersion VARCHAR(10) NULL,
    EndpointName VARCHAR(200) NOT NULL,
    CONSTRAINT PK_APIRoute PRIMARY KEY (APIRouteId),
    CONSTRAINT FK_APIRoute_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT UK_APIRoute UNIQUE(APINameId, APIVersion, EndpointName)
);



/* ====================================================================================================
Description: This table stores the Pricing Discount types

PlanDuration : Daily, Weekly, Monthly
DiscountPercent - Represents discusounts from the base price which is PayAsYouGoPrice
*/

CREATE TABLE IF NOT EXISTS APIPricingPlan (
	APIPricingPlanId INT NOT NULL AUTO_INCREMENT,
	Name VARCHAR(100) NOT NULL,
    Description VARCHAR(200) NOT NULL,
    Unit VARCHAR(50) NOT NULL,
    PlanDuration VARCHAR(30) NOT NULL,
    Quantity INT NOT NULL,
    DiscountPercent DECIMAL(4,2) NOT NULL,
    CONSTRAINT PK_APIPricingPlan PRIMARY KEY (APIPricingPlanId),
    CONSTRAINT UK_APIPricingPlan_Name UNIQUE(Name)
);
/*

INSERT INTO APIPricingPlan(Name, Description, Unit,PlanDuration, Quantity, DiscountPercent)
VALUES ('PayAsYouGo', 'PayAsYouGo', 'Nos','N/A', 0,0);
INSERT INTO APIPricingPlan(Name, Description, Unit, PlanDuration, Quantity, DiscountPercent)
VALUES ('Bronze', 'Volume Purchase', 'Nos','Monthly', 1000000, 5);
INSERT INTO APIPricingPlan(Name, Description, Unit, PlanDuration, Quantity, DiscountPercent)
VALUES ('Silver', 'Volume Purchase', 'Nos','Monthly', 2000000, 7);
INSERT INTO APIPricingPlan(Name, Description, Unit, PlanDuration, Quantity, DiscountPercent)
VALUES ('SavingPlan1000', 'Pay Upfront Purchase', 'Pounds','Monthly', 1000, 4);
INSERT INTO APIPricingPlan(Name, Description, Unit, PlanDuration, Quantity, DiscountPercent)
VALUES ('SavingPlan2000', 'Pay Upfront Purchase', 'Pounds','Monthly', 2000, 5);

*/

/* ====================================================================================================
Description: THis table stores the price for a RouteId.
When we enter price for an API, we only add the price for :APIPricingModelId = 1, which is the Base Price.
The other pricing plans have get discounts defined on them with respect to the base price.
APIPricingPlanId - Has to be 1 always, as we are recoding the BasePricePerCall here for base plan - PayAsYouGoPlan
BasePricePerCall - Price at the API Level common for all clients
                - Unit - pence
*/
CREATE TABLE IF NOT EXISTS APIRoutePrice (
	APIRoutePriceId INT NOT NULL AUTO_INCREMENT,
	APIRouteId INT NOT NULL,
    APIPricingPlanId INT NOT NULL,
    BasePricePerCall DECIMAL(8,2)  NOT NULL,
    CONSTRAINT PK_APIRoutePrice PRIMARY KEY (APIRoutePriceId),
    CONSTRAINT UK_APIRoutePrice UNIQUE(APIRouteId, APIPricingPlanId),
    CONSTRAINT FK_APIRoutePrice_APIRouteId FOREIGN KEY (APIRouteId) REFERENCES APIRoute(APIRouteId),
    CONSTRAINT FK_APIRoutePrice_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId)
);

/* ====================================================================================================
Description: This table contains data for an APISubscription for a (API+Customer). 
A subscription has a StartDate and endDate, endDate can be NULL.

NOTE that if an API has multiple chargeable endpoints, only one entry is made in this table.
But each endpoint will have an entry in : APICustomerPricing

When the Customer changes plan, which will be allowed only from Next month, the EndDate will be updated 
a new Subscription will be started, with a new PricinglanId.
Need an new enpoint to implemen this details : ChangeSubscription()

IMPORTANT NOTE: INSERT A NEW ENTRY when the pricing plan changes for a customer, so that we can track
the history and can be tracked. Also can be used to re-create past invoices.
*/

CREATE TABLE IF NOT EXISTS APIRouteSubscription(
	APIRouteSubscriptionId INT NOT NULL AUTO_INCREMENT,
	APICustomerId INT NOT NULL,
    APINameId INT NOT NULL,
    APIPricingPlanId INT NOT NULL DEFAULT 1,
    IsActive TINYINT NOT NULL,
	StartDate DATETIME NOT NULL DEFAULT NOW(),
    EndDate DATETIME NULL,
    CONSTRAINT PK_APIRouteSubscription PRIMARY KEY (APIRouteSubscriptionId),
    CONSTRAINT FK_APIRouteSubscription_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APISubscription_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId),
    CONSTRAINT FK_APIRouteSubscription_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId),
    CONSTRAINT UK_APIRouteSubscription_Covering UNIQUE(APICustomerId, APINameId, APIPricingPlanId)
);

/* ====================================================================================================
Description: This table stores the pricing at the customer level
DiscountPerCall - Unit pence
SellingPricePerCall = BasePricePerCall - DiscountAmountPerCall OR 
                    if DiscountAmountPerCall = NA
                        = BasePricePerCall - BasePricePerCall*DiscountPercentPerCall*100

NOTE: The discount could be negative to sell at a higer price than vase price
*/
CREATE TABLE IF NOT EXISTS APICustomerPricing (
	APICustomerPricingId INT NOT NULL AUTO_INCREMENT,
    APIRoute_PricingTier_MapId INT NOT NULL REFERENCES APIRoute_PricingTier_Map,
    APINameId INT NOT NULL,
    APICustomerId INT NOT NULL,
    APIRoutePriceId INT NOT NULL,
    CONSTRAINT PK_APICustomerPricing PRIMARY KEY (APICustomerPricingId),
    CONSTRAINT FK_APICustomerPricing_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APICustomerPricing_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId),
    CONSTRAINT FK_APICustomerPricing_APIRoutePriceId FOREIGN KEY (APIRoutePriceId) REFERENCES APIRoutePrice(APIRoutePriceId)
);

CREATE TABLE IF NOT EXISTS APIRoute_PricingTier_Map (
	APIRoute_PricingTier_MapId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    APIRoutePriceId INT NOT NULL REFERENCES APIRoutePrice,
    APIPricingTierId INT NOT NULL REFERENCES APIPricingTier,
    SellingPricePerCall DECIMAL(8,2) NOT NULL,
    CONSTRAINT UK_APIPricingTier UNIQUE(APIRoutePriceId, APIPricingTierId)
);

CREATE TABLE IF NOT EXISTS APIPricingTier (
	APIPricingTierId INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(30) NOT NULL,
    CONSTRAINT UK_APIPricingTier UNIQUE(Name)
);

INSERT INTO APIPricingTier(Name) VALUES ('TIER1');
INSERT INTO APIPricingTier(Name) VALUES ('TIER2');
INSERT INTO APIPricingTier(Name) VALUES ('TIER3');


#TBD: Invoice API rules
 

/* ===============================================PHASE 3=====================================================
Description: This table stores the details of Quota Based Price Plans
This table is applicable only if the Customer has chosen a PricingPlan
other than PayAsYouGo. In that case customers usage (number or pounds)
will be recorded in column : TotalQuotaUsage

Workflow changes:
1. At the time of entering usage, need to increment usage here
2. If the usage is reaching limits, need to issue warning emails
    - We need to define business rules for chaning the subscription plan
2. Need to reset the usage on the first day of the month 

*/
CREATE TABLE IF NOT EXISTS APISubscriptionLimit (
	APISubscriptionLimitId INT NOT NULL AUTO_INCREMENT,
    APIRouteSubscriptionId INT NOT NULL,
	TotalQuotaUsage DECIMAL(8,2) NOT NULL,
    CONSTRAINT PK_APISubscriptionLimit PRIMARY KEY (APIQuotaLimitId),
    CONSTRAINT FK_APISubscriptionLimit_APIRouteSubscriptionId FOREIGN KEY (APIRouteSubscriptionId) REFERENCES APIRouteSubscription(APIRouteSubscriptionId),
    CONSTRAINT FK_APIQuotaLimit_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId)
);



/* ====================================================================================================
Description: This table stored the error types

*/
CREATE TABLE IF NOT EXISTS ErrorType (
	ErrorTypeId INT NOT NULL,
    Name VARCHAR(30) NOT NULL,
    Description VARCHAR(100) NOT NULL,
	CONSTRAINT PK_APIUsageError PRIMARY KEY (ErrorTypeId)
);

INSERT INTO ErrorType (ErrorTypeId, Name, Description)
VALUES (1, 'ExternalError', 'External Error from client');
INSERT INTO ErrorType (ErrorTypeId, Name, Description)
VALUES (2, 'ValidationError', 'Request data validation error');
INSERT INTO ErrorType (ErrorTypeId, Name, Description)
VALUES (3, 'InternalProcessingError', 'Internal processing error');
INSERT INTO `api_usage_report_dev`.`ErrorType` (`ErrorTypeId`, `Name`, `Description`)
VALUES ('4', 'ClientValidationError', 'Client validation error')
INSERT INTO ErrorType (`ErrorTypeId`, `Name`, `Description`) 
VALUES ('5', 'InternalApiUsageError', 'Unhandled internal apiUsage error');
   



/* ====================================================================================================
Description: This table records any errors with an API invoke. 
It is used to track errors from API as well as internal errors. Any errors during processing should
be entered here.

ErrorId : error code from teh client
ErrorTypeId : Default external error
InputData : The inout JSON object as string

*/
CREATE TABLE IF NOT EXISTS APIError (
	APIErrorId INT NOT NULL AUTO_INCREMENT,
    ErrorTypeId INT NOT NULL DEFAULT 1,
    ErrorId INT NULL,
    ErrorMessage VARCHAR(1000) NOT NULL,
    InputData VARCHAR(2000) NULL,
    ErrorStatus TINYINT NOT NULL DEFAULT 0,
	CONSTRAINT PK_APIUsageError PRIMARY KEY (APIErrorId),
    CONSTRAINT FK_APIError_ErrorTypeId FOREIGN KEY (ErrorTypeId) REFERENCES ErrorType(ErrorTypeId)
);



/* ====================================================================================================
Descirption: This table stores the usage

APICustomerId : Chosen because you want to send a single bill for a Customer for all APIs subscribed.

DEVELOPER NOTES:
1. EndpointName is present here as APIRoute table will not contain entries for all end points. It will have onbly
those end points that have special pricing.

*/
CREATE TABLE IF NOT EXISTS APIUsage (
    APIUsageId INT NOT NULL AUTO_INCREMENT,
    APICustomerId INT NOT NULL,
    APIRouteId INT NOT NULL,
    APIErrorId INT NULL,
    APIPricingPlanId INT NULL,
	APIKey VARCHAR(100) NOT NULL,
	APINameId INT NOT NULL,
    APIVersion VARCHAR(10) NULL,
    EndpointName VARCHAR(100) NOT NULL,
	ClientIPAddress VARCHAR(30) NOT NULL,
	HttpStatusCode INT NOT NULL,
    RequestDate DATETIME NOT NULL  DEFAULT CURRENT_TIMESTAMP,
    PricePerCall DECIMAL(4,2) NOT NULL,
    TimeTakenMilliseconds INT NOT NULL,
    CONSTRAINT PK_APIUsage PRIMARY KEY (APIUsageId),
    CONSTRAINT FK_APIUsage_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APIUsage_APIRouteId FOREIGN KEY (APIRouteId) REFERENCES APIRoute(APIRouteId),
    CONSTRAINT FK_APIUsage_APIErrorId FOREIGN KEY (APIErrorId) REFERENCES APIError(APIErrorId),
	CONSTRAINT FK_APIUsage_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId),
    CONSTRAINT FK_APIUsage_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId)
);




	
			


