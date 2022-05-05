USE api_usage_report_prod;

Select * from APIUsage;

Select * from APIName;
Select * from APICustomer; 
Select * from APIRoute; 
Select * from APIPricingPlan; 
Select * from APIRouteSubscription; 
Select * from APIQuotaLimit; 
Select * from APIRoutePrice; 
Select * from ErrorType;
Select * from APIError;
Select * from APICustomerPricing;
Select * from APIRoutePricingTierMap;
Select * from APIPricingTier;


Select * from APICustomerPricing
Where APICustomerId = 5;

select * from APIUsage
where APIKey = 'faf1111e-ec48-4980-bc30-324a0f205fd3'
Order By APIUsageId desc;


select *  from APIUsage
Order By APIUsageId desc
LIMIT 30;

select * from Error
Order By APIErrorId desc
LIMIT 10;


select @@version;
SHOW VARIABLES LIKE 'version';




#--------------Update Usage Queries------------------

select * from APIRoute;
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

#====================SAMPLE - QUERY JSON from MYSQL==========================
CREATE TABLE events( 
  id int auto_increment primary key, 
  event_name varchar(255), 
  visitor varchar(255), 
  properties json, 
  browser json
);

INSERT INTO events(event_name, visitor,properties, browser) 
VALUES
('pageview', 
  '2',
  '{ "page": "/contact" }',
  '{ "name": "Firefox", "os": "Windows", "resolution": { "x": 2560, "y": 1600 } }'
),
(
  'pageview', 
  '1',
  '{ "page": "/products" }',
  '{ "name": "Safari", "os": "Mac", "resolution": { "x": 1920, "y": 1080 } }'
);

SELECT id, browser->'$.name' browser
FROM events;

# Invoice API
SELECT an.DisplayName as APIName , au.APIVersion, au.EndpointName, Count(*) as Count, SUM(au.PricePerCall ) as TotalPrice 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = 'PERSE-TEST-CLIENT-APIKEY'
AND (RequestDate) >= DATE_FORMAT("2022-04-01 00:00:00","%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT("2022-04-30 23:00:00","%Y-%m-%d %H:%i:%s")  
GROUP BY APIName, au.EndpointName;



####=================================APICustomerPricing - Manual===============================
#1. Make sure the endpoints are present
SELECT * FROM APIRoute;

#2. On-board the required endpoints
	## To be done from Postman
#3. Enter the price data for the endpoints in APIRoutePricingTierMap
	
INSERT INTO APIRoutePricingTierMap (APIRouteId, APIPricingTierId, BasePricePerCall)
VALUES (19,1,0.2);
INSERT INTO APIRoutePricingTierMap (APIRouteId, APIPricingTierId, BasePricePerCall)
VALUES (19,2,0.2);
INSERT INTO APIRoutePricingTierMap (APIRouteId, APIPricingTierId, BasePricePerCall)
VALUES (19,3,0.2);

Select * from APIRoutePricingTierMap
Order by APIRouteId asc, APIPricingTierId asc;

## TODO for other endpoints

Select * from APICustomerPricing;

#4. Enter the Customer pricing for each API
# 1 - RenewableExchange
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,19,1,1,0,0,0.2);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,20,1,1,0,0,0.2);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,21,1,1,0,0,0.25);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,22,1,1,0,0,0.2);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,23,1,1,0,0,0.50);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,24,1,1,0,0,0.5);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,25,1,1,0,0,0.1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,26,1,1,0,0,0.1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,27,1,1,0,0,0.2);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,28,1,1,0,0,0.5);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,14,1,1,0,0,0.6);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,15,1,1,0,0,0.6);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (1,29,1,1,0,0,1.0);


Select * from APICustomerPricing
Where APICustomerId = 5;

#2 - Perse Test Clienbt
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,19,5,1,0,0,0.2);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,20,5,1,0,0,0.2);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,21,5,1,0,0,0.25);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,22,5,1,0,0,0.2);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,23,5,1,0,0,0.50);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,24,5,1,0,0,0.5);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,25,5,1,0,0,0.1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,26,5,1,0,0,0.1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,27,5,1,0,0,0.2);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,28,5,1,0,0,0.5);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,14,5,1,0,0,0.6);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,15,5,1,0,0,0.6);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (1,29,5,1,0,0,1.0);

###--------------------------------------------------------------------------------------------------

##=====================================UsageCount===============================================

SELECT an.DisplayName as APIName , au.APIVersion, au.EndpointName, Count(*) as Count, SUM(au.PricePerCall ) as TotalPrice 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = '4e628695-23ed-4759-9529-b4fc19e0b0b7'
AND (RequestDate) >= DATE_FORMAT("2022-04-01 00:00:00","%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT("2022-04-30 23:59:59","%Y-%m-%d %H:%i:%s")  
AND APIErrorId IS NULL
GROUP BY APIName, au.APIVersion, au.EndpointName;


### Neeed to make sure HH has got the entry for the Customer, else Invoice call will fail while trying to get ActiveMeterCount
SELECT Customer.Name AS CustomerName,
Customer.CustomerId as cid, 
ServiceType.Name AS ServiceName, 
ServiceMetadata.ServiceMetadataId AS ServiceMetadataId
FROM Customer 
INNER JOIN ServiceMetadata ON Customer.CustomerId = ServiceMetadata.CustomerId 
INNER JOIN ServiceType ON ServiceType.ServiceTypeId = ServiceMetadata.ServiceTypeId 
WHERE Customer.ApiKey = '67afbb34-2191-4e14-9b03-4b827dd74ff9';

#=========================================== Invoice Endpoint=============================================

Select * from APIRoute;
Select * from APICustomerPricing;

##---------------- Get the cusotmer fees for a given period
Set @startDate = DATE_FORMAT('2022-03-01 00:00:00','%Y-%m-%d %H:%i:%s');
Set @endDate = DATE_FORMAT('2022-03-31 23:59:59','%Y-%m-%d %H:%i:%s');
Select APIRouteId, SellingPricePerCall, StartDate, EndDate
FROM APICustomerPricing acp 
WHERE(
	(EndDate > @startdate  AND EndDate < @endDate AND StartDate < @endDate )  #1.1
	OR (StartDate < @endDate  AND EndDate >= @endDate)  #1.2
	OR ((StartDate < @endDate) AND EndDate IS NULL)  #2.1
	OR ((StartDate > @startdate  AND StartDate < @endDate) AND (EndDate > @startdate AND EndDate < @endDate)) #3.1
	OR (StartDate = @startdate  AND EndDate = @endDate)
)
AND APIKey = 'PERSE-TEST-CLIENT-APIKEY';


##-------------------- Get the Invoice fees for a given period
Set @startDate = DATE_FORMAT('2022-04-01 00:00:00','%Y-%m-%d %H:%i:%s');
Set @endDate = DATE_FORMAT('2022-04-30 23:59:59','%Y-%m-%d %H:%i:%s');

SELECT au.APIRouteId, acp.SellingPricePerCall, an.DisplayName as APIName , 
	au.APIVersion, 
    au.EndpointName,
    acp.SellingPricePerCall as UnitPrice,
    Count(*) as Count, 
    (Count(*) * acp.SellingPricePerCall) as APICost
	FROM APIUsage au 
	JOIN APIName an on au.APINameId = an.APINameId 
    LEFT OUTER JOIN (
		Select APIRouteId, SellingPricePerCall, StartDate, EndDate
		FROM APICustomerPricing acp 
        JOIN APICustomer ac on ac.APICustomerId = acp.APICustomerId
		WHERE ac.APIKey = '67afbb34-2191-4e14-9b03-4b827dd74ff9'
        AND (
			(EndDate > @startdate  AND EndDate < @endDate AND StartDate < @endDate )  #1.1
			OR (StartDate < @endDate  AND EndDate >= @endDate)  #1.2
			OR ((StartDate < @endDate) AND EndDate IS NULL)  #2.1
			OR ((StartDate > @startdate  AND StartDate < @endDate) AND (EndDate > @startdate AND EndDate < @endDate)) #3.1
			OR (StartDate = @startdate  AND EndDate = @endDate)
		)
    ) acp on acp.APIRouteId = au.APIRouteId
    WHERE APIKey = '67afbb34-2191-4e14-9b03-4b827dd74ff9'
	AND RequestDate >= @startDate
	AND RequestDate <= @endDate
	AND an.DisplayName != 'Half Hourly Meter History API'
    AND APIErrorId IS NULL
	GROUP BY APIName, au.APIVersion, au.EndpointName
    Order By SellingPricePerCall desc;
    
    Select * from APIUsage
    WHERE APIKey = '67afbb34-2191-4e14-9b03-4b827dd74ff9'
	AND RequestDate >= @startDate
	AND RequestDate <= @endDate
    AND APIErrorId IS NOT NULL

#### Fixx the Routeids in APIUsage table

Set @epName = 'addresses';
Set @routeId = 20;
Select COUNT(*), MAX(RequestDate) from APIUsage 
Where EndpointName = @epName
AND APIRouteId != @routeId;


Update APIUsage
Set APIRouteId = @routeId
Where EndpointName = @epName
AND APIRouteId != @routeId;



SET SQL_SAFE_UPDATES = 0;

SET SQL_SAFE_UPDATES = 1;


Select * from APIRouteSubscription
Where APICustomerId = 100

Select * from APIName;

