const uuid = require('uuid')
const constants = require('../constants/constants')


exports.getAPIUsageAttributes = function (req, res, result) {
    let apiUsageObject = {};

    if (res.APIErrorId)
        apiUsageObject.APIErrorId = res.APIErrorId

    apiUsageObject.APICustomerId = result.APICustomerId
    apiUsageObject.APIRouteId = result.APIRouteId
    apiUsageObject.APIPricingPlanId = result.APIPricingPlanId ? result.APIPricingPlanId : null
    apiUsageObject.APIKey = req.headers.api_key
    apiUsageObject.APINameId = result.APINameId
    apiUsageObject.APIVersion = req.body.apiDetails.apiVersion
    apiUsageObject.EndPointName = req.body.apiDetails.endPointName
    apiUsageObject.ClientIPAddress = req.body.apiDetails.clientIpAddress
    apiUsageObject.HttpStatusCode = req.body.apiDetails.httpStatusCode
    // apiUsageObject.PricePerCall = result.BasePricePerCall ? result.BasePricePerCall : 0;
    apiUsageObject.PricePerCall = result.SellingPricePerCall ? result.SellingPricePerCall : 0;
    apiUsageObject.TimeTakenMilliseconds = req.body.apiDetails.executionTime
    apiUsageObject.RequestData = req.body.apiDetails.requestData ? JSON.stringify(req.body.apiDetails.requestData) : null
    apiUsageObject.ResponseData = req.body.apiDetails.responseBody ? JSON.stringify(req.body.apiDetails.responseBody) : null
    apiUsageObject.ModifiedBy = req.body.apiDetails.modifiedby ? req.body.apiDetails.modifiedby : null

    return apiUsageObject;
}

exports.getAPIErrorAttributes = function (req, res) {
    let apiErrorObject = {}

    if (req.isValidationError) {                                              // request data validation error
        apiErrorObject.ErrorId = res.code;
        apiErrorObject.ErrorTypeId = 2
        apiErrorObject.ErrorMessage = res.error[0].message
    } else if (req.isInternalProcessingError) {                               // internal data processing error
        apiErrorObject.ErrorId = null
        apiErrorObject.ErrorTypeId = 3
        apiErrorObject.ErrorMessage = req.internalProcessingMessage
        apiErrorObject.ErrorStatus = 1                                         // Needs to be resolved. Hence, ErrorStatus = 1
    } else if (req.body.apiDetails && (req.body.apiDetails.errorCode || req.body.apiDetails.errorDescription)) {        // caller api error (client error)
        apiErrorObject.ErrorId = req.body.apiDetails.errorCode
        apiErrorObject.ErrorTypeId = 1
    } else if (req.body.apiDetails && req.body.apiDetails.validationResult !== true) {          // client validation error
        apiErrorObject.ErrorId = null
        apiErrorObject.ErrorTypeId = 4
        apiErrorObject.ErrorMessage = "Client validation error"
    } else {
        apiErrorObject.ErrorId = null                                          //unknown error.
        apiErrorObject.ErrorTypeId = 5
        apiErrorObject.ErrorMessage = "Unhandled internal apiUsage error"
        apiErrorObject.ErrorStatus = 1                                         //Needs to be resolved. Hence, ErrorStatus = 1
    }

    if (req.body.apiDetails && req.body.apiDetails.errorDescription) {
        apiErrorObject.ErrorMessage = apiErrorObject.ErrorMessage ? apiErrorObject.ErrorMessage + ". " + req.body.apiDetails.errorDescription : req.body.apiDetails.errorDescription;
    }

    apiErrorObject.InputData = JSON.stringify(req.body.apiDetails)
    apiErrorObject.RequestData = req.body.apiDetails.requestData ? JSON.stringify(req.body.apiDetails.requestData) : null
    apiErrorObject.ResponseData = req.body.apiDetails.responseBody ? JSON.stringify(req.body.apiDetails.responseBody) : null
    apiErrorObject.ModifiedBy = req.body.apiDetails.modifiedby ? req.body.apiDetails.modifiedby : null

    return apiErrorObject
}

exports.getAPINameAttributes = function (req) {
    let apiNameAttributes = {};

    apiNameAttributes.Name = req.body.name
    apiNameAttributes.DisplayName = req.body.displayName
    apiNameAttributes.Description = req.body.description

    return apiNameAttributes
}

exports.getAPIRouteAttributes = function (req) {
    let apiRouteAttributes = {};

    apiRouteAttributes.APINameId = req.apiNameId
    apiRouteAttributes.APIVersion = req.body.apiVersion
    apiRouteAttributes.EndpointName = req.body.endPointName ? req.body.endPointName : "/"

    return apiRouteAttributes
}

exports.getAPIRoutePriceAttributes = function (req) {
    let apiRoutePriceAttributes = {};

    apiRoutePriceAttributes.APIRouteId = req.apiRouteId
    apiRoutePriceAttributes.APIPricingPlanId = 1;
    apiRoutePriceAttributes.BasePricePerCall = req.body.basePricePerCall ? req.body.basePricePerCall : 0.00

    return apiRoutePriceAttributes
}

exports.getCustomerAttributes = function (req) {
    let customerAttributes = {};

    customerAttributes.CustomerName = req.body.customerName
    customerAttributes.LegalName = req.body.legalName;
    customerAttributes.Address = req.body.address ? req.body.address : null
    customerAttributes.Email = req.body.email
    customerAttributes.IsActive = 1
    customerAttributes.APIKey = uuid.v4()

    return customerAttributes
}

exports.getApiRouteSubscriptionAttributes = function (response) {
    let apiRouteSubscriptionAttributes = {};

    apiRouteSubscriptionAttributes.APICustomerId = response.APICustomerId
    apiRouteSubscriptionAttributes.APINameId = response.APINameId;
    apiRouteSubscriptionAttributes.IsActive = 1
    apiRouteSubscriptionAttributes.APIPricingPlanId = response.APIPricingPlanId

    return apiRouteSubscriptionAttributes
}

//Set the error code so that the error won't be logged as the APIUsage
// error
exports.setErrorCode = function (err) {
    err.errorId = constants.errorCodeExcludeFromAPIUsageLogging;
    return err;
}
