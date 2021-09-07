# api-usage-ms

This microservice helps to track the API Usage (requests and errors) and also helps in monetizing the APIs


# APIUsage API Design

## MIDDLEWARE DESIGN

1. Middleware method will receive all the details in the req & res
	updateAPIUsage(req,res)
		req will have the following : apiKey, apiversion, endPointName, clientIPAdress
		res will have the following : httpStatusCode, timeTakenInMilliSeconds (populated by client) ,errorCode & errorDescription (in case of error)

## USAGE DATA INJECTION

1. The middleware module will POST to the following method of this micro service:
	POST usage <br/>
	    Url : v1/usage<br/>
	    Header : apiKey<br/>
    Body (JSON):<br/>
	Success Scenario Args : apiversion, endPointName, clientIPAdress,httpStatusCode, timeTakenInMilliSeconds	<br/>
	Error Scenario Args : apiversion, endPointName, clientIPAdress, httpStatusCode, 
    timeTakenInMilliSeconds, errorCode, errorDescription  <br/>
        - Insert in to APIError table first in case of an error <br/>
        - Insert to APIUsage table : <br/>
				- apiCustomerId, apiRouteid, apiKey, apiName, apiVersion, 
				endPointName, clientIPAdress, httpStatusCode, pricePerCall, TimeTakenInMilliSeconds
    <br/>
	Validation:<br/>
		- All parameters are required, error params required in case of error only.<br/>

2. All Client API Endpoint Validation:<br/>
    POST validateRequest<br/>
        Url : v1/validateRequest<br/>
        Header : apiKey<br/>
        Body (JSON) :  <br/>
		- Check if the customer has valid subscription based on the APIKey<br/>
<br/>  

3. Record internal errors in the API during processing to the APIError table<br/>
	- Any errors during processing have to be logged as internal errors in the APIError <br/>table<br/>
		IsInternal - true<br/>
		InputData - Inouts to the POST usage endpoint<br/>
		InternalErrorStatus - 0 (not resolved)<br/>
		ErrorMessage - Details of the error occured<br/>
<br/>
<br/>

## USAGE DATA RETRIEVAL<br/>
<br/>
1. GET usage<br/>
	Header : apiKey, apiVersion<br/>
	Query Params : intervalType ,endPointName = null, fromDate, toDate = null<br/>
	intervalType : d, m or y<br/>
    <br/>
    Validations:<br/>
		- endPointName - Validate in the middleware where we will have all endpoints listed<br/>
		- usageType (Jaipal)<br/>
			=> d : If difference between date > x days, give an error: Please provide a range less than 60 days<br/>
		- fromDate & toDate : dateTime values, format : YYYY-MM-DD:HH:MM:SS<br/>
2. GET errors<br/>
	Header : apiKey, apiVersion<br/>
	Query Params : intervalType ,endPointName = null, fromDate, toDate = null<br/>
	intervalType : d, m or y<br/>
    <br/>
    Validations:<br/>
		- endPointName - Validate in the middleware where we will have all endpoints listed<br/>
		- usageType (Jaipal)<br/>
			=> d : If difference between date > x days, give an error: Please provide a range less than 60 days<br/>
		- fromDate & toDate : dateTime values, format : YYYY-MM-DD:HH:MM:SS<br/>
<br/>


## API Usage Management - INTERNAL APIs<br/>
<br/>
1. On boarding an API for APIUsage<br/>
	RegisterAPIRoute<br/>
		- apiName, apiVersion, endpointName = null<br/>
			- Create entry in APIRoute & APIRoutePrice tables<br/>
            
2. Customer Onboarding for an API Subscription<br/>
	RegisterAPICustomer<br/>
		- apiKey, customerName, address = null, email = null, pricingModelName <br/>
				- Create an entry in Customer, APISubscription tables <br/>
3. Ability to subscribe an API for a Customer <br/>
4. Ability for Admin to unsubscribe an API for a Customer <br/>
<br/>

## Non-Functional Requirements<br/>
<br/>

1. Send Alert Email on Receiving requests from an invalid subscription<br/>
		- Check if the customer has an active entry in the table : APISubscription<br/>
        - If the previous query has flag : HasQuotaLimits set to true, Check if the <br/>customer has not exceeded the volume limits in the table : APIRouteCustomerLimit<br/>
2. Semd Alert Email on customer reaching limits<br/>
3. Need to reset API Quota Limits <br/>
		- Use a Cron Job to implement this<br/>
6. Invoice creation process<br/>
<br/>
<br/>


## Analytics SQL Queries :<br/>
<br/>
1. Time:<br/>
	- Best Time Averages<br/>
	- Time Averages Per Route<br/>
2. Revenue:<br/>
	- Most Revenue APIs<br/>