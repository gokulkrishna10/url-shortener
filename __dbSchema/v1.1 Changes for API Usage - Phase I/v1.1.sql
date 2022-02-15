
#1. API Customer changes
ALTER TABLE APICustomer
MODIFY COLUMN APIKey VARCHAR(100) NULL;

# Now update the APIKey from APIRouteSubscription manually and after that make the key non-nullable

ALTER TABLE APICustomer
MODIFY COLUMN APIKey VARCHAR(100) NOT NULL;

ALTER TABLE APICustomer
ADD	CONSTRAINT UK_APICustomer_APIKey UNIQUE(APIKey);


#2. APIName table changes
# make then unique
ALTER TABLE APIName
ADD	CONSTRAINT UK_APIName_APIName UNIQUE(Name);
ALTER TABLE APIName
ADD	CONSTRAINT UK_APIName_DisplayName UNIQUE(DisplayName);

#3. APIRouteSubscription table changes
ALTER TABLE APIRouteSubscription
ADD COLUMN APIPricingPlanId INT NOT NULL DEFAULT 1;

Select * from APIRouteSubscription;

# Modify the Constraints
ALTER TABLE APIRouteSubscription
DROP CONSTRAINT UK_APIRouteSubscription_Covering; 

ALTER TABLE APIRouteSubscription
ADD CONSTRAINT UK_APIRouteSubscription_Covering UNIQUE(APICustomerId, APINameId, APIPricingPlanId);

ALTER TABLE APIRouteSubscription
ADD CONSTRAINT FK_APIRouteSubscription_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId);

#4. Drop the APIKey Column after testing is done
ALTER TABLE APIRouteSubscription
DROP CONSTRAINT UK_APIRouteSubscription;

ALTER TABLE APIRouteSubscription
DROP COLUMN APIKey;




