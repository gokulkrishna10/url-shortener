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

ALTER TABLE APICustomer
ADD	CONSTRAINT UK_APICustomer UNIQUE(CustomerName);

/* ====================================================================================================
Description: This table contains the APIName details

*/

CREATE TABLE IF NOT EXISTS APIName (
	APINameId INT NOT NULL AUTO_INCREMENT,
    Name VARCHAR(100) NOT NULL,
    DisplayName VARCHAR(100) NOT NULL,
    Description VARCHAR(200) NOT NULL,
	CreateDate DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_APIName PRIMARY KEY (APINameid)
);

ALTER TABLE APIName
ADD	CONSTRAINT UK_APIName UNIQUE(Name);


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
    CONSTRAINT FK_APIRoute_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId)
);

ALTER TABLE APIRoute
ADD	CONSTRAINT UK_APIRoute UNIQUE(APINameId, APIVersion, EndpointName);

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
    CONSTRAINT PK_APIPricingPlan PRIMARY KEY (APIPricingPlanId)
);

ALTER TABLE APIPricingPlan
ADD	CONSTRAINT UK_APIPricingPlan UNIQUE(Name);


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


/* ====================================================================================================
Description: This table contains data for an APISubscription for a (API+Customer). Note API Keys are defined
per (API + Customer).
APIKey : GUID string

IMPORTANT NOTE: INSERT A NEW ENTRY when the pricing plan changes for a customer, so that we can track
				the history and can be tracked. Also can be used to re-create past invoices.
TODO: Need changes here... this can't be here.. it has to go to APIRoutePrice table
    APIPricingPlanId INT NOT NULL,
*/

CREATE TABLE IF NOT EXISTS APIRouteSubscription(
	APIRouteSubscriptionId INT NOT NULL AUTO_INCREMENT,
	APICustomerId INT NOT NULL,
    APINameId INT NOT NULL,
	APIKey VARCHAR(100) NOT NULL, 
    IsActive TINYINT NOT NULL,
	StartDate DATETIME NOT NULL DEFAULT NOW(),
    CONSTRAINT PK_APIRouteSubscription PRIMARY KEY (APIRouteSubscriptionId),
    CONSTRAINT FK_APIRouteSubscription_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId),
    CONSTRAINT FK_APISubscription_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId)
);

ALTER TABLE APIRouteSubscription
ADD	CONSTRAINT UK_APIRouteSubscription UNIQUE(APICustomerId, APINameId, APIKey);

/* TO DROP, HAD TO DROP THE FK FIRST
ALTER TABLE APIRouteSubscription
DROP FOREIGN KEY FK_APISubscription_APICustomerId;
ALTER TABLE APIRouteSubscription
DROP INDEX  UK_APIRouteSubscription;
# Add it back after dropping the UK key
ALTER TABLE APIRouteSubscription
ADD CONSTRAINT FK_APISubscription_APICustomerId FOREIGN KEY (APICustomerId) REFERENCES APICustomer(APICustomerId);

*/



/* ====================================================================================================
Description : This table stores the API Limits for a (APINameId + CustomerId). This can be used to track Volume usage as well as
upfront usage.
PlanDuration : Daily, Weekly, Monthly

FACTS:
1. Customer subscribes for an API and receives an APIKey
2. An API can have single or multiple chargeable routes (each route charges differently : PricePerCall for BasePlan)
3. API Discounts are applied though Pricing Plans, which will internallky impose quota limits

Edge cases:
1. Pay Upfront amount/Quota Limit is over for a month
	SOLUTION: 
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







/*--------------------SELECT----------------------
USE api_usage_report_dev;

Select * from APIUsage;

Select * from APIName;
Select * from APICustomer; 
Select * from APIRoute; 
Select * from APIPricingPlan; 
Select * from APIRouteSubscription; 
Select * from APIQuotaLimit; 
Select * from APIRoutePrice; 
Select * from ErrorType;



Select * from APIError
#where APIErrorId = 2
order by APIErrorId desc
LIMIT 5; 

Select * from APIUsage
order by APIUsageId desc
LIMIT 5; 

*/


/*--------------------DROP----------------------
USE api_usage_report_dev;

Drop table APIUsage;
Drop table APIError;
Drop table ErrorType;
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
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('Half-Hourly-Meter-History', 'Half Hourly Meter History',  'Half-Hourly-Meter-History');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('meter-data', 'meter-data',  'meter-data');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('meter-data-advanced', 'meter-data-advanced',  'meter-data-advanced');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('carbon-footprint', 'carbon-footprint',  'carbon-footprint');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('eveloper/meter-data', 'eveloper/meter-data',  'eveloper/meter-data');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('current-energy-profile', 'current-energy-profile',  'current-energy-profile');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('precovid-energy-profile', 'precovid-energy-profile',  'precovid-energy-profile');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('current-energy-usage', 'current-energy-usage',  'current-energy-usage');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('precovid-energy-usage', 'precovid-energy-usage',  'precovid-energy-usage');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('current-energy-supplier', 'current-energy-supplier',  'current-energy-supplier');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('current-supplier-details', 'current-supplier-details',  'current-supplier-details');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('quote-request', 'quote-request',  'quote-request');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('ev-comparison-api', 'evCompare',  'evCompare');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('ou-neighbourhood-comparison', 'Neighbourhood Energy Comparison',  'Neighbourhood Energy Comparison');


 

#--ROUTE1
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (1,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (1,'v1','cumulative-interval-data');

INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (2,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (3,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (4,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (5,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (6,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (7,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (8,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (9,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (10,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (11,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (12,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (13,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (14,'v1','/');


select * from APIRoute;

#-- NOTE you will only enter price for APIPricingPlanId = 1
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (1, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (2, 1, 0.15); 

INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (3, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (4, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (5, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (6, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (7, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (8, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (9, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (10, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (11, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (12, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (13, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (14, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (15, 1, 0.10); 




#-----------Onboard a Customer -----
INSERT INTO APICustomer (CustomerName, LegalName,  Address, Email, IsActive)
VALUES ('Renewable-Exchange', 'Renewable Exchange Ltd',  NULL, 'sudheer.k@digitalapicraft.com', 1);

INSERT INTO APICustomer (CustomerName, LegalName,  Address, Email, IsActive)
VALUES ('Test Customer', 'Test Customer',  NULL, 'sudheer.k@digitalapicraft.com', 1);

#---------------Subcription (API + Customer)

INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (1, 1, 'a0a07621-2379-4042-bde9-0539a84a036c', 1);
	
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 2, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 3, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 4, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 5, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 6, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 7, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 8, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 9, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 10, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 11, 'LABRADOR-APIKEY', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 12, 'LABRADOR-APIKEY', 1);

INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 13, '3f56cc00-7882-483d-b1eb-9c89070c64a7', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 14, 'f6ec9f65-fa7a-4365-958c-aff0a1220631', 1);



#--------------APIRouteId + Customer ( If there are any limits needed)
#INSERT INTO APIQuotaLimit (APINameId, APICustomerId, APIPricingPlanId, PlanDuration)
#VALUES (1, 1, 2, 'Monthly');



#--------------Update Usage Queries------------------

select * from APIRoute
#-- Regular
Select ar.APIRouteId, ar.EndPointName, ars.APINameId,ars.APICustomerId, arp.APIPricingPlanId, arp.BasePricePerCall 
FROM APIRouteSubscription ars
JOIN APIRoute ar on ar.APINameId = ars.APINameId
JOIN APIRoutePrice arp on ar.APIRouteId = arp.APIRouteId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c'
AND ar.APIVersion = 'v1'
AND (EndPointName = 'cumulative-interval-data1' OR EndPointName = '/')
ORDER BY LENGTH(ar.EndPointName) DESC
LIMIT 1;



# --------------ValidateRequest Query-------------------------
SELECT * from APIRouteSubscription ars 
INNER JOIN APIName apn on ars.APINameId = apn.APINameId 
WHERE Name = 'ev-comparison-api' 
AND APIKey = '3f56cc00-7882-483d-b1eb-9c89070c64a7'

# ================================Usage Queries=========================

--get API Usage. (getEndpoints = true)
SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c' 
AND RequestDate >= STR_TO_DATE("2020-10-20 23:00:00", "%Y-%m-%d %H:%i:%s")
AND RequestDate <= STR_TO_DATE("2021-09-24 23:00:00", "%Y-%m-%d %H:%i:%s")
GROUP BY Date, an.DisplayName, APIVersion, EndpointName

--get API Usage. (getEndpoints = false)
SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c' 
AND RequestDate >= STR_TO_DATE("2020-10-20 23:00:00", "%Y-%m-%d %H:%i:%s")
AND RequestDate <= STR_TO_DATE("2021-09-24 23:00:00", "%Y-%m-%d %H:%i:%s")
GROUP BY Date, an.DisplayName, APIVersion

------------Month---------------
--get API Usage. (getEndpoints = true)
SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c' 
AND RequestDate >= STR_TO_DATE("2020-10-20 23:00:00", "%Y-%m-%d %H:%i:%s")
AND RequestDate <= STR_TO_DATE("2021-09-24 23:00:00", "%Y-%m-%d %H:%i:%s")
GROUP BY Month, an.DisplayName, APIVersion, EndpointName

--get API Usage. (getEndpoints = false)
SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c' 
AND RequestDate >= STR_TO_DATE("2020-10-20 23:00:00", "%Y-%m-%d %H:%i:%s")
AND RequestDate <= STR_TO_DATE("2021-09-24 23:00:00", "%Y-%m-%d %H:%i:%s")
GROUP BY Month, an.DisplayName, APIVersion

-----------------------Year---------------------
--get API Usage. (getEndpoints = true)
SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c' 
AND RequestDate >= STR_TO_DATE("2020-10-20 23:00:00", "%Y-%m-%d %H:%i:%s")
AND RequestDate <= STR_TO_DATE("2021-09-24 23:00:00", "%Y-%m-%d %H:%i:%s")
GROUP BY Year, an.DisplayName, APIVersion, EndpointName

--get API Usage. (getEndpoints = false)
SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c' 
AND RequestDate >= STR_TO_DATE("2020-10-20 23:00:00", "%Y-%m-%d %H:%i:%s")
AND RequestDate <= STR_TO_DATE("2021-09-24 23:00:00", "%Y-%m-%d %H:%i:%s")
GROUP BY Year, an.DisplayName, APIVersion



--=========================Errors===============================

--get API Errors with Details (getErrorCountsOnly = true)
SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, EndpointName, HttpStatusCode, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c' 
AND RequestDate >= STR_TO_DATE("2020-10-20 23:00:00", "%Y-%m-%d %H:%i:%s")
AND RequestDate <= STR_TO_DATE("2021-09-24 23:00:00", "%Y-%m-%d %H:%i:%s")
AND APIErrorId IS NOT NULL
GROUP BY Date, an.DisplayName, APIVersion, EndpointName, HttpStatusCode



--get DAILY API Errors. (getErrorCountsOnly = true)
SELECT RequestDate as DateTime, an.DisplayName as APIName , APIVersion, EndpointName, HttpStatusCode, ae.ErrorId, ae.ErrorMessage
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c' 
AND RequestDate >= STR_TO_DATE("2020-10-20 23:00:00", "%Y-%m-%d %H:%i:%s")
AND RequestDate <= STR_TO_DATE("2021-09-24 23:00:00", "%Y-%m-%d %H:%i:%s")
AND au.APIErrorId IS NOT NULL
LIMIT 1000;

--get MONTHLY API Errors. (getErrorCountsOnly = true)
--get YEARLY API Errors. (getErrorCountsOnly = true)


=================================Perfornamce========================
--Best
#Ref : https://ubiq.co/database-blog/select-top-10-records-for-each-category-in-mysql/
SELECT an.DisplayName as APIName, t.EndpointName, DATE(t.RequestDate) as Date, t.TimeTakenMilliseconds as Time
FROM ( 
	SELECT au.EndpointName, au.RequestDate, au.TimeTakenMilliseconds, au.HttpStatusCode, au.APINameId, @product_rank := IF(@current_product = APINameId, @product_rank + 1, 1) AS product_rank, 
			@current_product := APINameId 
	FROM APIUsage au 
	ORDER BY APINameId ASC, RequestDate DESC, TimeTakenMilliseconds ASC) t
LEFT OUTER JOIN APIName an on an.APINameId = t.APINameId
where product_rank<=10
AND t.HttpStatusCode = 200;

--Worst
#Ref : https://ubiq.co/database-blog/select-top-10-records-for-each-category-in-mysql/
SELECT an.DisplayName as APIName, t.EndpointName, DATE(t.RequestDate) as Date, t.TimeTakenMilliseconds as Time
FROM ( 
	SELECT au.EndpointName, au.RequestDate, au.TimeTakenMilliseconds, au.HttpStatusCode, au.APINameId, @product_rank := IF(@current_product = APINameId, @product_rank + 1, 1) AS product_rank, 
			@current_product := APINameId 
	FROM APIUsage au 
	ORDER BY APINameId ASC, DATE(RequestDate) DESC, TimeTakenMilliseconds desc) t
LEFT OUTER JOIN APIName an on an.APINameId = t.APINameId
where product_rank<=10
AND t.HttpStatusCode = 200;

#===========================================Testing - MeterDeactivationTracker- Year 50000================================
select * from MeterDeactivationTracker
where MeterNo = '9999999999999'


delete from MeterDeactivationTracker
where MeterNo = '9999999999999'


*/











	
			


