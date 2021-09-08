const moment = require('moment')


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

    if (req.isValidationError) {
        apiErrorObject.ErrorId = res.code;                                   // req data validation error
        apiErrorObject.ErrorTypeId = 2
    } else if (req.body.apiDetails && req.body.apiDetails.errorCode) {
        apiErrorObject.ErrorId = req.body.apiDetails.errorCode          // caller api error
        apiErrorObject.ErrorTypeId = 1
    } else {
        apiErrorObject.ErrorId = 9998                                   // internal data processing error
        apiErrorObject.ErrorTypeId = 3
    }


    if (res.error && res.error.length > 0 && res.error[0].message) {
        apiErrorObject.ErrorMessage = res.error[0].message                    // req data validation error
    } else if (req.body.apiDetails && req.body.apiDetails.errorDescription) {
        apiErrorObject.ErrorMessage = req.body.apiDetails.errorDescription    // caller api error
    } else {
        apiErrorObject.ErrorMessage = "internal data processing error"         // internal data processing error
    }

    // attributes applicable only for internal errors
    // if ((!req.body.apiDetails.errorCode && !req.body.apiDetails.errorDescription) && (req.isValidationError)) {
    //     apiErrorObject.IsInternal = 1
    //     apiErrorObject.InternalErrorStatus = 1
    // } else if ((req.body.apiDetails.errorCode && req.body.apiDetails.errorDescription) && (!req.isValidationError)) {
    //     apiErrorObject.IsInternal = 0
    //     apiErrorObject.InternalErrorStatus = 0
    // } else {
    //     apiErrorObject.IsInternal = 1
    //     apiErrorObject.InternalErrorStatus = 1
    // }

    apiErrorObject.InputData = JSON.stringify(req.body.apiDetails)
    apiErrorObject.ErrorStatus = 1

    return apiErrorObject
}