/*
--Connetion details
Host : oeprodrds.crjdegsnxmp2.eu-west-1.rds.amazonaws.com
Schema : api_usage_report_prod
userName:  api_usasge_report_produser
password: be293b19-5ab2-4cf6-9f4b-85d574e898b9

*/

USE api_usage_report_prod;


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
	APIRouteId INT NOT NULL AUTO_INCREMENT,
    APINameId INT NOT NULL,
    APIVersion VARCHAR(10) NULL,
    EndpointName VARCHAR(200) NOT NULL,
    CONSTRAINT PK_APIRoute PRIMARY KEY (APIRouteId),
    CONSTRAINT FK_APIRoute_APINameId FOREIGN KEY (APINameId) REFERENCES APIName(APINameId)
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
    CONSTRAINT PK_APIPricingPlan PRIMARY KEY (APIPricingPlanId)
);


INSERT INTO APIPricingPlan(Name, Description, Unit,PlanDuration, Quantity, DiscountPercent)
VALUES ('PayAsYouGo', 'PayAsYouGo', 'Nos','N/A', 0,0);
/* Samples: 
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



/* ====================================================================================================
Description : This table stores the API Limits for a (APINameId + CustomerId). This can be used to track Volume usage as well as
upfront usage.
PlanDuration : Daily, Weekly, Monthly

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

USE api_usage_report_prod;

Select * from APIName;
Select * from APICustomer; 
Select * from APIRoute; 
Select * from APIPricingPlan; 
Select * from APIRouteSubscription; 
Select * from APIQuotaLimit; 
Select * from APIRoutePrice; 
Select * from ErrorType;



Select * from APIError
order by APIErrorId desc
LIMIT 5; 

Select * from APIUsage
order by APIUsageId desc
LIMIT 5; 


# Truncate table APIRoute;

*/


/*--------------------DROP----------------------


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
VALUES ('Half-Hourly-Meter-Hisotory', 'Half Hourly Meter Hisotory',  'Half-Hourly-Meter-Hisotory');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('ev-comparison-api', 'evCompare',  'evCompare');
INSERT INTO APIName (Name, DisplayName, Description)
VALUES ('ou-neighbourhood-comparison', 'Neighbourhood Energy Comparison',  'Neighbourhood Energy Comparison');
 
 Select * from APIName;

#--ROUTE1
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (1,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (1,'v1','cumulative-interval-data');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (2,'v1','/');
INSERT INTO APIRoute (APINameId, APIVersion, EndpointName)
VALUES (3,'v1','/');

Select * from APIRoute; 

#-- NOTE you will only enter price for APIPricingPlanId = 1
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (1, 1, 0.10); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (2, 1, 0.15); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (3, 1, 0.9); 
INSERT INTO APIRoutePrice (APIRouteId, APIPricingPlanId, BasePricePerCall)
VALUES (4, 1, 0.8); 

Select * from APIRoutePrice;


#-----------Onboard a Customer -----
INSERT INTO APICustomer (CustomerName, LegalName,  Address, Email, IsActive)
VALUES ('Renewable-Exchange', 'Renewable Exchange Ltd',  NULL, 'sudheer.k@digitalapicraft.com', 1);

INSERT INTO APICustomer (CustomerName, LegalName,  Address, Email, IsActive)
VALUES ('Test Customer', 'Test Customer',  NULL, 'sudheer.k@digitalapicraft.com', 1);

Select * from APICustomer; 

#---------------Subcription (API + Customer)

INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (1, 1, '532c7bfd-712e-4888-856e-2510a978be80', 1);
	
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 2, '81586818-fba3-4c15-aba8-5ce08f552141', 1);
INSERT INTO APIRouteSubscription (APICustomerId, APINameId, APIKey, IsActive)
VALUES (2, 3, '2ec89fd7-908d-453d-a6a1-bcf8e26fe5ca', 1);

Select * from APIRouteSubscription; 

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
where APIKey = '532c7bfd-712e-4888-856e-2510a978be80'
AND ar.APIVersion = 'v1'
AND (EndPointName = 'cumulative-interval-data1' OR EndPointName = '/')
ORDER BY LENGTH(ar.EndPointName) DESC
LIMIT 1;



# --------------ValidateRequest Query-------------------------
SELECT * from APIRouteSubscription ars 
INNER JOIN APIName apn on ars.APINameId = apn.APINameId 
WHERE Name = 'ev-comparison-api' 
AND APIKey = '81586818-fba3-4c15-aba8-5ce08f552141'

# -------------------------Usage - IntervalType = d----------------
Select * from APIUsage

Select RequestDate, APINameId, APIVersion, EndpointName, COunt(*) as Count from APIUsage
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c'
group by RequestDate, APINameId, APIVersion, EndpointName

Select date_format(date(RequestDate),'%d-%m-%Y')as RequestDate, APIVersion, EndpointName, Count(*) as Count
FROM APIUsage
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c'
group by date_format(date(RequestDate),'%d-%m-%Y'), APIVersion, EndpointName

Select DATE(RequestDate), APIVersion, EndpointName, Count(*) as Count
FROM APIUsage
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c'
AND DATE(RequestDate) = '2021-09-14'
group by DATE(RequestDate), APIVersion, EndpointName

Select MONTHNAME(RequestDate) as Month, APIVersion, EndpointName, Count(*) as Count
FROM APIUsage
where APIKey = 'a0a07621-2379-4042-bde9-0539a84a036c'
AND DATE(RequestDate) = '2021-09-14'
group by MONTHNAME(RequestDate), APIVersion, EndpointName



*/








	
			


