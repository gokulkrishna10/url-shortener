const apiUsage = require('../controllers/apiUsageController')
const apiUsageDao = require('../dao/apiUsageDAO')


exports.updateAPIUsage = (req, res) => {
    apiUsage.updateAPIUsage(req, res, (err, response) => {
        if (err) {
            console.log("updateAPIUsage failed >" + JSON.stringify(err))
            res.send(err.msg).status(err.code)
        } else {
            console.log("updateAPIUsage succeeded")
            if (!req.isValidationError)
                res.send(response).status(202)
        }
    })
}

// check if the input API key is registered in the APIRouteSubscription table
// and the requested API name matches with the registered API key
exports.apiUsageRequestValidation = function (req, res) {
    apiUsageDao.validateApiKeyAndName(req, res, (err, response) => {
        if (err) {
            console.log(err)
            res.send(err).status(err.code)
        } else {
            if (response && response.length > 0) {
                console.log("{status:success, message:Validation successful}")
                res.send(response).status(200)
            } else {
                console.log("{status:failure, message:Validation failed}")
                res.send(response).status(200)
            }
        }
    })
}