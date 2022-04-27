
USE api_usage_report_dev;

Select * from APIUsage;

Select * from APIName;
Select * from APICustomer; 
Select * from APIRoute; 
Select * from APIPricingPlan; 
Select * from APIRouteSubscription; 
Select * from APIRoutePrice; 
Select * from ErrorType;
Select * from APICustomerPricing;
Select * from APIRoutePricingTierMap;
Select * from APIPricingTier;

select * from APIUsage
Order By APIUsageId desc
LIMIT 5;

Select * from APIError
#where APIErrorId = 2
order by APIErrorId desc
LIMIT 5; 




#--------------Update Usage Queries------------------


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

#--get MONTHLY API Errors. (getErrorCountsOnly = true)
#--get YEARLY API Errors. (getErrorCountsOnly = true)


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

#--Worst
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

#=========================================== Invoice Endpoint=============================================

SELECT an.DisplayName as APIName , 
	au.APIVersion, 
    au.EndpointName,
    au.PricePerCall as UnitPrice,
    Count(*) as Count, 
    SUM(au.PricePerCall ) as TotalPrice 
	FROM APIUsage au 
	JOIN APIName an on au.APINameId = an.APINameId 
	WHERE APIKey = 'PERSE-TEST-CLIENT-APIKEY'
	AND RequestDate >= DATE_FORMAT('2022-04-27 12:30:00','%Y-%m-%d %H:%i:%s')
	AND RequestDate <= DATE_FORMAT('2022-04-27 23:59:59','%Y-%m-%d %H:%i:%s')
	AND an.DisplayName != 'Half Hourly Meter History API'
	GROUP BY APIName, au.APIVersion, au.EndpointName;
    
select * from APIUsage
Order By APIUsageId desc
LIMIT 5;


Select * from APIError
#where APIErrorId = 2
order by APIErrorId desc
LIMIT 5; 

##==============================Enter Customer Pricing Manually========================================
SELECT * FROM api_usage_report_dev.APIRoute;
SELECT * FROM api_usage_report_dev.APIName;
SELECT * FROM api_usage_report_dev.APICustomer;



##-------------------------------Add New Endpoint Prices to : APICustomerPricing----------------------------

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,86,46,1,0,0,0.2,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,87,46,2,0,0,0.2,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,88,46,3,0,0,0.25,1);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,89,46,1,0,0,0.2,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,90,46,2,0,0,0.53,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,77,46,1,0,0,0.6,1);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,91,46,1,0,0,0.5,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,92,46,2,0,0,0.08,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,93,46,1,0,0,0.1,1);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,94,46,1,0,0,0.2,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,95,46,1,0,0,0.5,1);
INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,90,46,1,0,0,0.6,1);

INSERT INTO APICustomerPricing (APINameId, APIRouteId, APICustomerId, APIPricingTierId, DiscountAmountPerCall, DiscountPercentPerCall, SellingPricePerCall, IsActive)
VALUES (89,79,46,1,0,0,1.0,1);


Select * from APICustomerPricing;

##-------------------------------Add New Endpoint Prices to : APIRoutePricingTierMap----------------------------
Select * from APIRoutePricingTierMap;
SELECT * FROM api_usage_report_dev.APIRoute;

INSERT INTO APIRoutePricingTierMap (APIRouteId, APIPricingTierId, BasePricePerCall)
VALUES (94,1,0.2);
INSERT INTO APIRoutePricingTierMap (APIRouteId, APIPricingTierId, BasePricePerCall)
VALUES (94,2,0.2);
INSERT INTO APIRoutePricingTierMap (APIRouteId, APIPricingTierId, BasePricePerCall)
VALUES (94,3,0.2);




#######================================TRIGGER TEST - Make the tale not updateable==============================

use devdb;
create table trigger_test
(
    id int not null
);
Select * from trigger_test;


DELIMITER $$
-- before inserting new id
DROP TRIGGER IF EXISTS before_update_id$$
CREATE TRIGGER before_update_id
    BEFORE INSERT ON test_trigger FOR EACH ROW
    BEGIN
        -- condition to check
        IF NEW.id < 0 THEN
            -- hack to solve absence of SIGNAL/prepared statements in triggers
            UPDATE `Error: CAN NOT update any pricing record in this table.` SET x=1;
        END IF;
    END$$

DELIMITER ;

### BUT Trigger creation is failing with error
###Error Code: 1419. You do not have the SUPER privilege and binary logging is enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)
## Probable solutions:
# https://serverfault.com/questions/420480/when-trying-to-create-a-trigger-in-rds-i-get-an-error-about-binary-logging
# https://www.thesysadmin.rocks/2020/08/19/aws-rds-you-do-not-have-the-super-privilege-and-binary-logging-is-enabled/

-- run the following as seperate statements:
insert into trigger_test values (1), (-1), (2); -- everything fails as one row is bad
select * from trigger_test;
insert into trigger_test values (1); -- succeeds as expected
insert into trigger_test values (-1); -- fails as expected
select * from trigger_test;

##==========================END - TRIGGER TEST=============================================