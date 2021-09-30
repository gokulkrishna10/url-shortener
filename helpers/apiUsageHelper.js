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
    apiUsageObject.PricePerCall = result.BasePricePerCall ? result.BasePricePerCall : 0;
    apiUsageObject.TimeTakenMilliseconds = req.body.apiDetails.executionTime

    return apiUsageObject;
}

exports.getAPIErrorAttributes = function (req, res) {
    let apiErrorObject = {}

    if (req.isValidationError) {                                              // req data validation error
        apiErrorObject.ErrorId = res.code;
        apiErrorObject.ErrorTypeId = 2
        apiErrorObject.ErrorMessage = res.error[0].message
    } else if (req.body.apiDetails && (req.body.apiDetails.errorCode || req.body.apiDetails.errorDescription)) {        // caller api error
        apiErrorObject.ErrorId = req.body.apiDetails.errorCode
        apiErrorObject.ErrorTypeId = 1
    } else if (req.isInternalProcessingError) {                               // internal data processing error
        apiErrorObject.ErrorId = null
        apiErrorObject.ErrorTypeId = 3
        apiErrorObject.ErrorMessage = req.internalProcessingMessage
        apiErrorObject.ErrorStatus = 1                                         // Needs to be resolved. Hence ErrorStatus = 1
    } else {
        apiErrorObject.ErrorId = null                                          //unknown error.
        apiErrorObject.ErrorTypeId = 4
        apiErrorObject.ErrorMessage = "Unhandled internal apiUsage error"
        apiErrorObject.ErrorStatus = 1                                         //Needs to be resolved. Hence ErrorStatus = 1
    }


    if (req.body.apiDetails && req.body.apiDetails.errorDescription) {
        apiErrorObject.ErrorMessage = apiErrorObject.ErrorMessage ? apiErrorObject.ErrorMessage + ". " + req.body.apiDetails.errorDescription : req.body.apiDetails.errorDescription;
    }

    apiErrorObject.InputData = JSON.stringify(req.body.apiDetails)

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
    apiRoutePriceAttributes.BasePricePerCall = req.body.basePricePerCall

    return apiRoutePriceAttributes
}