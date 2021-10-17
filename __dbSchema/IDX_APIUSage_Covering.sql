CREATE INDEX IDX_APIUSage_Covering
ON APIUsage(RequestDate, APIKey, APINameId, APIVersion, EndpointName,HttpStatusCode,TimeTakenMilliseconds)