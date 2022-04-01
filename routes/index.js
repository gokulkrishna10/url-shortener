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
                res.send(JSON.parse(response)).status(202)
        }
    })
}

// check if the requested API key is registered with the requested API name in the APIRouteSubscription table
exports.apiUsageRequestValidation = function (req, res) {
    apiUsageDao.validateApiKeyAndName(req, res, (err, response) => {
        if (err) {
            console.log(err)
            res.send(err).status(err.code)
        } else {
            if (response && response.length > 0) {
                console.log('{status:success, message:Validation successful}')
                res.send(JSON.parse('{"status":"success", "message":"Validation successful"}')).status(200)
            } else {
                console.log('{status:failure, message:Validation failed}')
                res.status(200).send(JSON.parse('{"status":"failure", "message":"Validation failed. Please check the apiKey or the apiName entered"}'))
            }
        }
    })
}

exports.apiUsageClientValidationByKey = function (req, res, next) {
    apiUsageDao.validateApiKey(req, res, (err, response) => {
        if (err) {
            next(err)
        } else {
            next();
        }
    })
}


exports.getApiUsage = function (req, res) {
    apiUsageDao.getAPIUsage(req, res, (err, response) => {
        if (err) {
            res.status(err.code).send(err.msg)
        } else {
            res.status(200).send(response)
        }
    })
}

exports.getAPIError = function (req, res) {
    apiUsageDao.getAPIError(req, res, (err, response) => {
        if (err) {
            res.status(err.code).send(err.msg)
        } else {
            res.status(200).send(response)
        }
    })
}

exports.onBoardNewApi = function (req, res) {
    apiUsage.onBoardNewApi(req, res, (err, response) => {
        if (err) {
            res.status(err.code).send(err)
        } else {
            res.status(201).send(response)
        }
    })
}


exports.addNewCustomer = function (req, res) {
    apiUsage.addNewCustomer(req, res, (err, response) => {
        if (err) {
            res.status(err.code).send(err)
        } else {
            res.status(201).send(response)
        }
    })
}


exports.customerApiSubscription = function (req, res) {
    apiUsage.customerApiSubscription(req, res, (err, response) => {
        if (err) {
            res.status(err.code).send(err)
        } else {
            res.status(201).send(response)
        }
    })
}


exports.getAllApiNames = function (req, res) {
    apiUsage.getAllApiNames(req, res, (err, response) => {
        if (err) {
            res.status(err.code).send(err)
        } else {
            res.status(200).send(response)
        }
    })
}

exports.getAdminUsage = function (req, res) {
    apiUsage.getAdminUsage(req, res, (err, response) => {
        if (err) {
            res.status(err.code).send(err)
        } else {
            res.status(200).send(response)
        }
    })
}


exports.getAdminError = function (req, res) {
    apiUsage.getAdminError(req, res, (err, response) => {
        if (err) {
            res.status(err.code).send(err.msg)
        } else {
            res.status(200).send(response)
        }
    })
}

exports.getApiPerformance = function (req, res) {
    apiUsage.getApiPerformance(req, res, (err, response) => {
        if (err) {
            res.status(err.code).send(err.msg)
        } else {
            res.status(200).send(response)
        }
    })
}


exports.getAllPricingPlans = function (req, res) {
    apiUsage.getAllPricingPlans(req, (err, response) => {
        if (err) {
            res.status(err.code).send(err.msg)
        } else {
            res.status(200).send(response)
        }
    })
}

exports.getApiKeyFromCustomerName = function (req, res) {
    apiUsage.getApiKeyFromCustomerName(req, (err, response) => {
        if (err) {
            res.status(err.code).send(err)
        } else {
            res.status(200).send(response)
        }
    })
}

exports.getAllOrganisations = function (req, res) {
    apiUsage.getAllOrganisations(req, (err, response) => {
        if (err) {
            res.status(err.code).send(err)
        } else {
            res.status(200).send(response)
        }
    })
}


exports.getCustomerDetailsByApiKey = function (req, res) {
    apiUsage.getCustomerDetailsByApiKey(req, (err, response) => {
        if (err) {
            res.status(err.code).send(err)
        } else {
            res.status(200).send(response)
        }
    })
}