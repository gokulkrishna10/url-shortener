/*
--Connetion details
server: openenergy.crjdegsnxmp2.eu-west-1.rds.amazonaws.com
Schema : api_usage_report_dev
userName:  api_usasge_report_devuser
password: 891f5b0d-6873-4b5f-a0ae-9b890ed0739d


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
    CONSTRAINT UK_APIName_APIName UNIQUE(Name)
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
Description: This table contains data for an APISubscription for a (API+Customer). NOTE APIKeys are
at the Customer Level. Just like othe subscription, the custoner is subscribing with a PricingPlan and with a StartDate
and NO EndDate.
When the Customer changes plan, which will be allowed only from Next month, the EndDate will be updated 
a new Subscription will be started, with a new PricinglanId.


IMPORTANT NOTE: INSERT A NEW ENTRY when the pricing plan changes for a customer, so that we can track
the history and can be tracked. Also can be used to re-create past invoices.

*/

CREATE TABLE IF NOT EXISTS APIRouteSubscription(
	APIRouteSubscriptionId INT NOT NULL AUTO_INCREMENT,
	APICustomerId INT NOT NULL,
    APINameId INT NOT NULL,
	APIKey VARCHAR(100) NOT NULL, 
    IsActive TINYINT NOT NULL,
	StartDate DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_APIRouteSubscription PRIMARY KEY (APIRouteSubscriptionId),
    CONSTRAINT UK_APIRouteSubscription_Covering UNIQUE(APICustomerId, APINameId, APIKey),
    CONSTRAINT FK_APIRouteSubscription_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APISubscription_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId)
);




CREATE TABLE IF NOT EXISTS APIQuotaLimit (
	APIQuotaLimitId INT NOT NULL AUTO_INCREMENT,
    APINameId INT NOT NULL,
    APICustomerId INT NOT NULL,
    APIPricingPlanId INT NOT NULL,
    PlanDuration VARCHAR(30) NOT NULL,
	TotalQuotaUsage INT NOT NULL DEFAULT 0,
    IsActive TINYINT NOT NULL DEFAULT 1,
    StartDate DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_APIQuotaLimit PRIMARY KEY (APIQuotaLimitId),
    CONSTRAINT FK_APIQuotaLimit_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APIQuotaLimit_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId),
    CONSTRAINT FK_APIQuotaLimit_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId)
);

ALTER TABLE APIQuotaLimit
ADD	CONSTRAINT UK_APIQuotaLimit UNIQUE(APINameId, APICustomerId, APIPricingPlanId, IsActive, StartDate);

/* ====================================================================================================
Description: THis table stores the price for a RouteId.
When we enter price for an API, we only add the price for :APIPricingModelId = 1, which is the Base Price.
The other pricing plans have get discounts defined on them with respect to the base price.

*/
CREATE TABLE IF NOT EXISTS APIRoutePrice (
	APIRoutePriceId INT NOT NULL AUTO_INCREMENT,
	APIRouteId INT NOT NULL,
    APIPricingPlanId INT NOT NULL,
    BasePricePerCall DECIMAL(4,2)  NOT NULL,
    CONSTRAINT PK_APIRoutePrice PRIMARY KEY (APIRoutePriceId),
    CONSTRAINT FK_APIRoutePrice_APIRouteId FOREIGN KEY (APIRouteId) REFERENCES APIRoute(APIRouteId),
    CONSTRAINT FK_APIRoutePrice_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId)
);

ALTER TABLE APIRoutePrice
ADD	CONSTRAINT UK_APIRoutePrice UNIQUE(APIRouteId, APIPricingPlanId);

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




	
			


