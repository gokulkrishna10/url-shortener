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

##=====================================TEMP===============================================

SELECT an.DisplayName as APIName , au.APIVersion, au.EndpointName, Count(*) as Count, SUM(au.PricePerCall ) as TotalPrice 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = 'faf1111e-ec48-4980-bc30-324a0f205fd3'
AND (RequestDate) >= DATE_FORMAT("2022-03-01 00:00:00","%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT("2022-03-31 23:00:00","%Y-%m-%d %H:%i:%s")  
GROUP BY APIName, au.APIVersion, au.EndpointName;

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

## TODO for other endpoints

Select * from APICustomerPricing;

#4. Enter the Customer pricing for each API
# 1 - RenewableExchange
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,19,1,1,0,0,0.2);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,87,1,2,0,0,0.2);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,88,1,3,0,0,0.25);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,89,1,1,0,0,0.2);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,90,1,2,0,0,0.53);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,77,1,1,0,0,0.6);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,91,1,1,0,0,0.5);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,92,1,2,0,0,0.08,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,93,1,1,0,0,0.1,1);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall)
VALUES (4,94,1,1,0,0,0.2,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (4,95,1,1,0,0,0.5,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (4,76,1,1,0,0,0.6,1);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (1,79,1,1,0,0,1.0,1);




