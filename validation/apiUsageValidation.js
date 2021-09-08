const util = require('../customnodemodules/util_node_module/utils')
const ErrorMod = require('../customnodemodules/error_node_module/errors')
const customError = new ErrorMod()

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