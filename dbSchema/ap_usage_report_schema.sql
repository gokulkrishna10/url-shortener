/*
--Connetion details
server: openenergy.crjdegsnxmp2.eu-west-1.rds.amazonaws.com
Schema : api_usage_report_dev
userName:  api_usasge_report_devuser
password: 891f5b0d-6873-4b5f-a0ae-9b890ed0739d

DESIGN DECISIONS:
-------------------
1. Volume Quota Limits:
Decided not to use the Volume limits at the AWS API Gateway level as we will have to create a usage plan per API/method
at the customer level. Also it will not warn the customer once the limits are about to be reached. Hence we are going ahead 
with a custom implementation.

2. Pricing Plan:
Chose to follow a simple plan where we define the pricing only for the PayAsYouGo plan. All the other plans follow
a discuont scheme basd on the BasePrice defined for PayAsYouGo plan.


*/


USE api_usage_report_dev;

/* ====================================================================================================
Description: This table contains data for an API Customer

*/

CREATE TABLE IF NOT EXISTS APICustomer (
	APICustomerId INT NOT NULL,
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
	APINameId INT NOT NULL,
    Name VARCHAR(100) NOT NULL,
    Description VARCHAR(100) NOT NULL,
	CreateDate DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_APIName PRIMARY KEY (APINameid)
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
	APIRouteId INT NOT NULL,
    APINameId INT NOT NULL,
    APIVersion VARCHAR(10) NULL,
    EndpointName VARCHAR(100) NOT NULL,
    CONSTRAINT PK_APIRoute PRIMARY KEY (APIRouteId),
    CONSTRAINT FK_APIRoute_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId)
);



/* ====================================================================================================
Description: This table stores the Pricing Discount types

PlanDuration : Daily, Weekly, Monthly
DiscountPercent - Represents discusounts from the base price which is PayAsYouGoPrice
*/

CREATE TABLE IF NOT EXISTS APIPricingPlan (
	APIPricingPlanId INT NOT NULL,
	Name VARCHAR(100) NOT NULL,
    Description VARCHAR(50) NOT NULL,
    Unit VARCHAR(50) NOT NULL,
    PlanDuration VARCHAR(30) NOT NULL,
    Quantity INT NOT NULL,
    DiscountPercent DECIMAL(4,2) NOT NULL,
    CONSTRAINT PK_APIPricingPlan PRIMARY KEY (APIPricingPlanId)
);


INSERT INTO APIPricingPlan(APIPricingPlanId, Name, Description, Unit,PlanDuration, Quantity, DiscountPercent)
VALUES (1, 'PayAsYouGo', 'PayAsYouGo', 'Nos','N/A', 0,0);
INSERT INTO APIPricingPlan(APIPricingPlanId, Name, Description, Unit, PlanDuration, Quantity, DiscountPercent)
VALUES (2, 'Bronze', 'Volume Purchase', 'Nos','Monthly', 1000000, 5);
INSERT INTO APIPricingPlan(APIPricingPlanId, Name, Description, Unit, PlanDuration, Quantity, DiscountPercent)
VALUES (3, 'Silver', 'Volume Purchase', 'Nos','Monthly', 2000000, 7);
INSERT INTO APIPricingPlan(APIPricingPlanId, Name, Description, Unit, PlanDuration, Quantity, DiscountPercent)
VALUES (4, 'SavingPlan1000', 'Pay Upfront Purchase', 'Pounds','Monthly', 1000, 4);
INSERT INTO APIPricingPlan(APIPricingPlanId, Name, Description, Unit, PlanDuration, Quantity, DiscountPercent)
VALUES (5, 'SavingPlan2000', 'Pay Upfront Purchase', 'Pounds','Monthly', 2000, 5);


/* ====================================================================================================
Description: This table contains data for an APISubscription for a (API+Customer). Note API Keys are defined
per (API + Customer).
APIKey : GUID string

IMPORTANT NOTE: INSERT A NEW ENTRY when the pricing plan changes for a customer, so that we can track
				the history and can be tracked. Also can be used to re-create past invoices.
*/

CREATE TABLE IF NOT EXISTS APIRouteSubscription(
	APIRouteSubscriptionId INT NOT NULL,
	APICustomerId INT NOT NULL,
    APINameId INT NOT NULL,
    APIPricingPlanId INT NOT NULL,
	APIKey VARCHAR(100) NOT NULL, 
    IsActive TINYINT NOT NULL,
	StartDate DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_APIRouteSubscription PRIMARY KEY (APIRouteSubscriptionId),
    CONSTRAINT FK_APIRouteSubscription_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APISubscription_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId),
    CONSTRAINT FK_APIRouteSubscription_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId)
);



/* ====================================================================================================
Description : This table stores the API Limits for a (APINameId + CustomerId). This can be used to track Volume usage as well as
upfront usage.
PlanDuration : Daily, Weekly, Monthly

Edge cases:
1. Pay Upfront amount/Quota Limit is over for a month
	SOL: 
		Possible options:
		a. Customer moves to the new Pricing plan
			SOL: Will be charged accordingly as we keep track of the PlanId pe call
		b. Customer doesn't change to the new plan.
			SOL: For QuotaLimit, the customer can be charged as per PayAsYouGo after the QuotaLimit is reached
				 For the PayUpFront, once the amount expires, the cusrtomer will be changed by the PayAsYouGo plan.

*/

CREATE TABLE IF NOT EXISTS APIQuotaLimit (
	APIQuotaLimitId INT NOT NULL AUTO_INCREMENT,
    APINameId INT NOT NULL,
    APICustomerId INT NOT NULL,
    APIPricingPlanId INT NOT NULL,
    PlanDuration VARCHAR(30) NOT NULL,
	TotalQuotaUsage INT NOT NULL DEFAULT 0,
    CONSTRAINT PK_APIQuotaLimit PRIMARY KEY (APIQuotaLimitId),
    CONSTRAINT FK_APIQuotaLimit_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APIQuotaLimit_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId),
    CONSTRAINT FK_APIQuotaLimit_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId)
);



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
    CONSTRAINT UK_APIRoutePrice UNIQUE KEY (APIPricingPlanId,APIRouteId),
    CONSTRAINT FK_APIRoutePrice_APIRouteId FOREIGN KEY (APIRouteId) REFERENCES APIRoute(APIRouteId),
    CONSTRAINT FK_APIRoutePrice_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId)
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
    ErrorStatus TINYINT NOT NULL DEFAULT 1,
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
    RequestDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PricePerCall DECIMAL(4,2) NOT NULL,
    TimeTakenMilliseconds INT NOT NULL,
    CONSTRAINT PK_APIUsage PRIMARY KEY (APIUsageId),
    CONSTRAINT FK_APIUsage_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APIUsage_APIRouteId FOREIGN KEY (APIRouteId) REFERENCES APIRoute(APIRouteId),
    CONSTRAINT FK_APIUsage_APIErrorId FOREIGN KEY (APIErrorId) REFERENCES APIError(APIErrorId),
	CONSTRAINT FK_APIUsage_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId),
    CONSTRAINT FK_APIUsage_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId)
);



/*--------------------SELECT----------------------
Select * from APICustomer; 
Select * from APIRoute; 
Select * from APIPricingPlan; 
Select * from APIRouteSubscription; 
Select * from APIQuotaLimit; 
Select * from APIRoutePrice; 
Select * from APIError; 
Select * from APIUsage; 

*/


/*--------------------DROP----------------------
USE api_usage_report_dev;

Drop table APIUsage;
Drop table APIError;
Drop table APIRoutePrice;
Drop table APIQuotaLimit;
Drop table APIRouteSubscription;
Drop table APIPricingPlan;
Drop table APIRoute;
Drop table APICustomer;
Drop table APIName;

*/


/*
----------------------------------Scripts-------------------------------------------------------


------------Onboard an API--------------------
#------API 
INSERT INTO APIName (APINameId, Name, Description)
VALUES (1, 'Half-Hourly-Meter-Hisotory', 'Half-Hourly-Meter-Hisotory');

#--ROUTE1
INSERT INTO APIRoute (APIRouteId, APINameId, APIVersion, EndpointName)
VALUES (1, 1,'v1','/');
#-- NOTE you will only enter price for APIPricingPlanId = 1
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (1, 1, 1.10); 

#--ROUTE2
INSERT INTO APIRoute (APIRouteId, APINameId, APIVersion, EndpointName)
VALUES (2, 1,'v1','getCumulativeTotalData');
#-- NOTE you will only enter price for APIPricingPlanId = 1
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (2, 1, 1.2); 


#-----------Onboard a Customer -----
INSERT INTO APICustomer (APICustomerId, CustomerName, LegalName,  Address, Email, IsActive)
VALUES (1, 'Renewable-Exchange', 'Renewable Exchange Ltd',  NULL, 'sudheer.k@digitalapicraft.com', 1);

#---------------API + Customer
INSERT INTO APIRouteSubscription (APIRouteSubscriptionId, APICustomerId, APINameId, APIPricingPlanId, APIKey, IsActive)
VALUES (1, 1, 1, 2, 'ed1ddbc9-9e1d-43ad-ba6c-dbe5ce75f6ec', 1);

#--------------APIRouteId + Customer ( If there are any limits needed)
INSERT INTO APIQuotaLimit (APINameId, APICustomerId, APIPricingPlanId, PlanDuration)
VALUES (1, 1, 2, 'Monthly');

#--------------Update Usage Queries------------------

#-- Regular
Select ar.APIRouteId, ar.EndPointName, ars.APINameId,ars.APICustomerId, ars.APIPricingPlanId, arp.BasePricePerCall 
FROM APIRouteSubscription ars
JOIN APIRoute ar on ar.APINameId = ars.APINameId
JOIN APIRoutePrice arp on ar.APIRouteId = arp.APIRouteId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c'
AND ar.APIVersion = 'v1'
AND (EndPointName = 'getCumulativeTotalData1' OR EndPointName = '/')
ORDER BY LENGTH(ar.EndPointName) DESC
LIMIT 1;


--Error (any error scenario including Invalid API Key)
Select ar.APIRouteId, ar.EndPointName, ars.APINameId,ars.APICustomerId
FROM APIRouteSubscription ars
JOIN APIRoute ar ON ar.APINameId = ars.APINameId
JOIN APIName an ON an.APINameId = ars.APINameId
where an.Name = 'Half-Hourly-Meter-Hisotory'
AND (EndPointName = 'getCumulativeTotalData1' OR EndPointName = '/')
ORDER BY LENGTH(ar.EndPointName) DESC
LIMIT 1;

# --------------ValidateRequest Query-------------------------
Select IsActive from APIRouteSubscription
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c';

*/








	
			


