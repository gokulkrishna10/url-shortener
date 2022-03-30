Use api_usage_report_prod;

Select * from APIError;

select * from APIUsage
where APIKey = 'faf1111e-ec48-4980-bc30-324a0f205fd3'
Order By APIUsageId desc;

Select Count(*) from APIUsage
where APIKey = 'faf1111e-ec48-4980-bc30-324a0f205fd3'
And ClientIPAddress = '::ffff:10.11.0.250'

Select * from APIUsage
where APIKey = 'faf1111e-ec48-4980-bc30-324a0f205fd3'
#And ClientIPAddress = '::ffff:10.11.0.250'
Order By RequestDate Desc;



select * from APIUsage
#where APIKey = 'PERSE-TEST-CLIENT-APIKEY'
Order By APIUsageId desc;



select * from APIError
where APIErrorId in (2717)
Order by APIErrorId;

Select * from APIName;

Select * from APIRouteSubscription;

Select * from APICustomer;

select @@version;
SHOW VARIABLES LIKE 'version';




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



Select * from APIError
#where APIErrorId = 2
order by APIErrorId desc
LIMIT 5; 

Select * from APIUsage
order by APIUsageId desc
LIMIT 5; 



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

##=====================================TEMP===============================================
