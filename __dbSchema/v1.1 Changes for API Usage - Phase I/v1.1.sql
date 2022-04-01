
#1. API Customer changes
ALTER TABLE APICustomer
ADD COLUMN APIKey VARCHAR(100) NULL AFTER APICustomerId;


# Now update the APIKey from APIRouteSubscription manually and after that make the key non-nullable

select * from APICustomer;

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
ADD COLUMN APIPricingPlanId INT NOT NULL DEFAULT 1 AFTER APINameId;

Select * from APIRouteSubscription;

ALTER TABLE APIRouteSubscription
ADD CONSTRAINT UK_APIRouteSubscription_Covering UNIQUE(APICustomerId, APINameId, APIPricingPlanId);

ALTER TABLE APIRouteSubscription
ADD CONSTRAINT FK_APIRouteSubscription_APIPricingPlanId FOREIGN KEY (APIPricingPlanId) REFERENCES APIPricingPlan(APIPricingPlanId);

#4 Drop the non-applicable constraint from Workbench

#5 truncate tables to clean up data
truncate table APIUsage;
#Drop the FK for APIErrorId from API usage, else it wont allow to truncate
truncate table APIError;
# Add the FK after that
ALTER TABLE APIUsage
ADD CONSTRAINT FK_APIUsage_APIErrorId FOREIGN KEY (APIErrorId) REFERENCES APIError(APIErrorId);

#5. Drop the non-applicabl constraint from Workbench

#6. INSERT INTO `api_usage_report_dev`.`ErrorType` (`ErrorTypeId`, `Name`, `Description`) VALUES ('5', 'InternalApiUsageError', 'Unhandled internal apiUsage error');
    UPDATE `api_usage_report_dev`.`ErrorType` SET `Name` = 'ClientValidationError', `Description` = 'Client validation error' WHERE (`ErrorTypeId` = '4');


