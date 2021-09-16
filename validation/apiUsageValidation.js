const util = require('../customnodemodules/util_node_module/utils')
const ErrorMod = require('../customnodemodules/error_node_module/errors')
const customError = new ErrorMod()
const constants = require('../constants/constants')

exports.apiUsageValidation = function (req, res, next) {
    if (util.isNull(req.body) && util.isNull(req.body.apiDetails)) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs a body"))
    } else if (util.isNull(req.headers.api_key) && util.isNull(req.body.apiDetails.apiName)) {
        req.isValidationError = true;
        next(customError.BadRequest("request needs either an api key or api name"))
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
    if (util.isNull(req.headers.api_key)) {
        next(customError.BadRequest("API key is required"))
    } else if (util.isNull(req.query.intervalType) && !(constants.intervalTypeConstants.includes(req.query.intervalType.toUpperCase()))) {
        next(customError.BadRequest("Interval type is required and it should be either one of daily, monthly or yearly"))
    } else if (util.isNull(req.query.fromDate)) {
        next(customError.BadRequest("FromDate is required"))
    } else {
        next();
    }
}

