const util = require('../customnodemodules/util_node_module/utils')
const ErrorMod = require('../customnodemodules/error_node_module/errors')
const customError = new ErrorMod()
const constants = require('../constants/constants')
const {environment} = require("../environments");


exports.apiKeyAndApiNameValidation = function (req, res, next) {
    let err = null;

    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("request needs an api key")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.body.apiName) || util.isNull((req.body.apiName).trim())) {
        err = customError.BadRequest("request needs an apiName")
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next()
    }
}


exports.apiUsageValidation = function (req, res, next) {
    //If no statuscode, put it as 500
    if (!Boolean(req.body.apiDetails.httpStatusCode)) {
        req.body.apiDetails.httpStatusCode = 500;
    }
    if (util.isNull(req.body) && util.isNull(req.body.apiDetails)) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs a body"))
    } else if (util.isNull(req.headers.api_key)) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs an api key"))
    } else if (util.isNull(req.body.apiDetails.apiName) || util.isNull((req.body.apiDetails.apiName).trim())) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs an apiName"))
    } else if (isNaN(req.body.apiDetails.executionTime)) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs an execution time"))
    } else if (util.isNull(req.body.apiDetails.apiVersion)) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs an apiVersion"))
    } else if (util.isNull(req.body.apiDetails.endPointName)) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs an endPointName"))
    } else if (util.isNull(req.body.apiDetails.clientIpAddress)) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs an clientIpAddress"))
    } else if (util.isNull(req.body.apiDetails.httpStatusCode)) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs a httpStatusCode"))
    } else {
        req.isValidationError = false;
        next()
    }
}

exports.getUsageValidation = function (req, res, next) {
    let err = null;
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.intervalType) || !(constants.intervalTypeConstants.includes(req.query.intervalType.toUpperCase()))) {
        err = customError.BadRequest("Interval type is required and it should be one of daily, monthly or yearly")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.fromDate)) {
        err = customError.BadRequest("FromDate is required")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.getEndpoints)) {
        err = customError.BadRequest("getEndpoints is required")
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next();
    }
}

//donotUpdateUsage flag is set to true to prevent the invocation of updateApiUsage api in the global error handler
exports.getErrorValidation = function (req, res, next) {
    let err = null;
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required");
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.intervalType) || !(constants.intervalTypeConstants.includes(req.query.intervalType.toUpperCase()))) {
        err = customError.BadRequest("Interval type is required and it should be one of daily, monthly or yearly");
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.fromDate)) {
        err = customError.BadRequest("FromDate is required");
        err.donotUpdateUsage = true;
        next(err)
    } else if (!Boolean(req.query["getErrorDetails"])) {
        err = customError.BadRequest("getErrorDetails is required");
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next();
    }
}

exports.getAPIOnboardValidation = function (req, res, next) {
    let err = null
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required")
        err.donotUpdateUsage = true;
        next(err)
    } else if (Object.entries(req.body).length === 0) {
        err = customError.BadRequest("request needs a body")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.body.name) || util.isNull((req.body.name).trim())) {
        err = customError.BadRequest("request needs apiName")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.body.displayName) || util.isNull((req.body.displayName).trim())) {
        err = customError.BadRequest("request needs displayName")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.body.description) || util.isNull((req.body.description).trim())) {
        err = customError.BadRequest("request needs description")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.body.apiVersion) || util.isNull((req.body.apiVersion).trim())) {
        err = customError.BadRequest("request needs apiVersion")
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next()
    }
}

exports.getNewCustomerValidation = function (req, res, next) {
    let err = null
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required")
        err.donotUpdateUsage = true;
        next(err)
    } else if (Object.entries(req.body).length === 0) {
        err = customError.BadRequest("request needs a body")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.body.customerName)) {
        err = customError.BadRequest("request needs a customerName")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.body.legalName)) {
        err = customError.BadRequest("request needs a legalName")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.body.email)) {
        err = customError.BadRequest("request needs a customer email")
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next()
    }
}


exports.getCustomerApiSubscriptionValidation = function (req, res, next) {
    let err = null
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required")
        err.donotUpdateUsage = true;
        next(err)
    } else if (Object.entries(req.body).length === 0) {
        err = customError.BadRequest("request needs a body")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull((req.body.customerName).trim())) {
        err = customError.BadRequest("request needs customerName")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull((req.body.apiName).trim())) {
        err = customError.BadRequest("request needs apiName")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull((req.body.pricingPlan).trim())) {
        err = customError.BadRequest("request needs pricingPlanName")
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next()
    }
}


exports.adminValidation = function (req, res, next) {
    let err = null;
    if (req.headers && req.headers.api_key === environment.ADMIN_API_KEY) {
        next()
    } else {
        err = customError.BadRequest('Invalid API key')
        err.donotUpdateUsage = true;
        err.code = 400;
        next(err)
    }
}


exports.getAdminUsageValidation = function (req, res, next) {
    let err = null
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.fromDate)) {
        err = customError.BadRequest("FromDate is required")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.intervalType) || !(constants.intervalTypeConstants.includes(req.query.intervalType.toUpperCase()))) {
        err = customError.BadRequest("Interval type is required and it should be one of daily, monthly or yearly")
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.getEndpoints)) {
        err = customError.BadRequest("getEndpoints is required")
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next();
    }
}


exports.getAdminErrorValidation = function (req, res, next) {
    let err = null;
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required");
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.intervalType) || !(constants.intervalTypeConstants.includes(req.query.intervalType.toUpperCase()))) {
        err = customError.BadRequest("Interval type is required and it should be one of daily, monthly or yearly");
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.fromDate)) {
        err = customError.BadRequest("FromDate is required");
        err.donotUpdateUsage = true;
        next(err)
    } else if (!Boolean(req.query["getErrorDetails"])) {
        err = customError.BadRequest("getErrorDetails is required");
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next();
    }
}

exports.getAdminApiPerformanceValidation = function (req, res, next) {
    let err = null;
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required");
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.fastestOnTop)) {
        err = customError.BadRequest("fastestOnTop is required");
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next()
    }
}


exports.getAdminApiKeyFromCustomerNameValidation = function (req, res, next) {
    let err = null;
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required");
        err.donotUpdateUsage = true;
        next(err)
    } else if (util.isNull(req.query.orgName)) {
        err = customError.BadRequest("organisation name is required");
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next()
    }
}

exports.getAdminOrganisationsValidation = function (req, res, next) {
    let err = null;
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required");
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next()
    }
}

exports.getCustomerDetailsByApiKeyValidation = function (req, res, next) {
    let err = null;
    if (util.isNull(req.headers.api_key)) {
        err = customError.BadRequest("API key is required");
        err.donotUpdateUsage = true;
        next(err)
    } else {
        next()
    }
}