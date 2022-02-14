const async = require('async')
const apiUsageDao = require('../dao/apiUsageDAO')
const util = require('../customnodemodules/util_node_module/utils')
const {parse} = require("json2csv");

exports.updateAPIUsage = function (req, res, mainCallback) {
    console.log("inside API usage")

    let apiUsageClientValidationError = (req.body.apiDetails && req.body.apiDetails.validationResult !== true);
    let apiUsageClientError = (req.body.apiDetails && (Boolean(req.body.apiDetails.errorCode) || Boolean(req.body.apiDetails.errorDescription)));

    async.waterfall([
            function updateErrorDetails(callback) {
                if (req.isValidationError   // true if update-api-usage input request validation failed
                    || apiUsageClientValidationError  // true if request validation failed from client API( i.e. if client is not found to be subscribed to the requested api)
                    || apiUsageClientError   // true if client api failed
                ) {
                    apiUsageDao.insertErrorDetails(req, res, function (err, dbResponse) {
                        if (err) {
                            mainCallback(err, null)
                        } else {
                            if (dbResponse) {
                                if (!req.isValidationError && apiUsageClientError) {
                                    callback(null, req);
                                } else {
                                    //We do not have enough details to create an entry with APIUsage table and hence leaving after making an entry to APIError table.
                                    mainCallback(null, '{"status":"successful","message":"error successfully recorded in APIError table"}')
                                }
                            } else {
                                mainCallback('{"status":"failure","message":"failed to record the error"}', null)
                            }
                        }
                    })
                } else {
                    callback(null, req)
                }
            },
            function getCustomerAPIDetails(req, callback) {
                apiUsageDao.getCustomerAPIDetails(req, res, function (err, result) {
                    if (err) {
                        callback(err, null)
                    } else {
                        if (result && result.length === 0) {
                            req.isInternalProcessingError = true
                            req.internalProcessingMessage = "Failed to get API details"
                            apiUsageDao.insertErrorDetails(req, res, (err, response) => {
                                if (err) {
                                    console.log('{"status":"failure","message":"failed to record the error"}')
                                    mainCallback(err, null)
                                } else {
                                    console.log('{"status":"successful","message":"error successfully recorded"}')
                                    mainCallback(null, '{"status":"successful","message":"error successfully recorded"}')
                                }
                            })
                        } else {
                            callback(null, result)
                        }
                    }
                })
            },
            function insertAPIUsageDetails(result, callback) {
                apiUsageDao.insertAPIUsageDetails(req, res, result, function (err, response) {
                    if (err) {
                        req.isInternalProcessingError = true
                        req.internalProcessingMessage = "Failed to insert into usage table"
                        apiUsageDao.insertErrorDetails(req, res, (err, response) => {
                            if (err) {
                                console.log('{"status":"failure","message":"failed to record the error"}')
                                mainCallback(err, null)
                            } else {
                                console.log('{"status":"successful","message":"error successfully recorded"}')
                                mainCallback(null, '{"status":"successful","message":"error successfully recorded"}')
                            }
                        })
                    } else {
                        console.log('{"status":"successful","message":"API usage successfully recorded"}')
                        callback(null, '{"status":"successful","message":"API usage successfully recorded"}')
                    }
                })
            }
        ],
        function finalCallback(finalErr, finalResponse) {
            if (finalErr) {
                mainCallback(finalErr, null)
            } else {
                mainCallback(null, finalResponse)
            }
        })
}


exports.getApiUsage = function (req, res, callback) {
    apiUsageDao.getAPIUsage(req, res, (err, response) => {
        if (err) {
            callback(err, null)
        } else {
            callback(null, response)
        }
    })
}

exports.onBoardNewApi = function (req, res, mainCallback) {
    console.log("inside onBoardNewApi")

    async.waterfall([
        function checkIfApiAndEndpointExists(callback) {
            apiUsageDao.checkIfApiAndEndpointExists(req, (err, response) => {
                if (err) {
                    callback(err, null)
                } else {
                    if (response !== null) {
                        mainCallback({
                            "status": "failure",
                            "message": "Given endpoint is already registered under this api",
                            "code": 400
                        }, null)
                    } else {
                        callback(null, req)
                    }
                }
            })
        },
        function insertIntoApiName(req, callback) {
            apiUsageDao.insertIntoApiName(req, (err, response) => {
                if (err) {
                    callback(err, null)
                } else {
                    if (response.insertId) {  // for new api and new endpoint
                        req.apiNameId = response.insertId
                        callback(null, req)
                    } else {
                        apiUsageDao.getApiNameId(req, (innerQueryErr, innerQueryResponse) => {
                            if (innerQueryErr) {
                                callback(innerQueryErr, null)
                            } else { // for existing api but new endpoint
                                req.apiNameId = innerQueryResponse.APINameId
                                callback(null, req)
                            }
                        })
                    }
                }
            })
        }, function insertIntoApiRoute(req, callback) {
            apiUsageDao.insertIntoApiRoute(req, (err, response) => {
                if (err) {
                    callback(err, null)
                } else {
                    req.apiRouteId = response.insertId
                    callback(null, response)
                }
            })
        }, function insertIntoApiRoutePrice(result, callback) {
            apiUsageDao.insertIntoApiRoutePrice(req, (err, response) => {
                if (err) {
                    callback(err, null)
                } else {
                    let response = {"status": "successful", "message": "API onboarded successfully"}
                    callback(null, response)
                }
            })
        }
    ], function finalCallback(finalError, finalResult) {
        if (finalError) {
            mainCallback(finalError, null)
        } else {
            mainCallback(null, finalResult)
        }
    })
}


exports.addNewCustomer = function (req, res, callback) {
    apiUsageDao.addNewCustomer(req, (err, response) => {
        if (err) {
            callback(err, null)
        } else {
            callback(null, response)
        }
    })
}


exports.customerApiSubscription = function (req, res, mainCallback) {
    console.log("inside customerApiSubscription")

    async.waterfall([
        function getAPICustomerIdAndApiNameIdAndPricingPlanId(callback) {
            apiUsageDao.getAPICustomerIdAndApiNameIdAndPricingPlanId(req, (err, response) => {
                if (err) {
                    callback(err, null)
                } else {
                    (response.code && response.code === 400) ? mainCallback(response, null) : callback(null, response)
                }
            })
        }, function checkTheCustomerIdAndApiNameIdAndPricingPlanId(response, callback) {
            apiUsageDao.checkTheCustomerIdAndApiNameIdAndPricingPlanId(response, (err, result) => {
                if (err) {
                    callback(err, null)
                } else {
                    (result && result.code && result.code === 400) ? mainCallback(result, null) : callback(null, response)
                }
            })
        }, function insertOrUpdateToApiRouteSubscription(response, callback) {
            apiUsageDao.insertOrUpdateToApiRouteSubscription(response, (err, response) => {
                if (err) {
                    callback(err, null)
                } else {
                    response.apiName = req.body.apiName
                    response.customerName = req.body.customerName
                    response.pricingPlan = req.body.pricingPlan;
                    (response.code && response.code === 500) ? callback(response, null) : callback(null, response)
                }
            })
        }
    ], function finalCallback(finalError, finalResult) {
        if (finalError) {
            mainCallback(finalError, null)
        } else {
            mainCallback(null, finalResult)
        }
    })
}


exports.getAllApiNames = function (req, res, callback) {
    apiUsageDao.getAllApiNames(req, (err, response) => {
        if (err) {
            callback(err, null)
        } else {
            if (response && response.length > 0) {
                if (req.headers["content-type"] && req.headers["content-type"].includes("csv")) {
                    callback(null, parse(response))
                } else {
                    callback(null, response)
                }
            } else {
                callback(null, "{message:No data}")
            }
        }
    })
}

exports.getAdminUsage = function (req, res, mainCallback) {
    async.waterfall([
            function getAllApiNames(callback) {
                apiUsageDao.getAllApiNames(req, (err, response) => {
                    if (err) {
                        callback(err, null)
                    } else {
                        let errorResponse = []
                        let successResponse = []
                        let apiNameMatch;
                        if (util.isNull(req.query.apiName)) {
                            response.forEach(responseEle => {
                                successResponse.push(responseEle.DisplayName)
                            })
                            callback(null, successResponse)
                        } else {
                            response.forEach(responseEle => {
                                if (responseEle.DisplayName === req.query.apiName) {
                                    apiNameMatch = true
                                } else {
                                    errorResponse.push(responseEle.DisplayName)
                                }
                            })
                            apiNameMatch ? callback(null, response) : mainCallback({
                                "status": "failure",
                                "code": 400,
                                "message": `API name can only be one of : [${errorResponse}]`
                            }, null)
                        }
                    }
                })
            },
            function getAdminUsage(response, callback) {
                apiUsageDao.getAdminUsage(req, response, (err, response) => {
                    if (err) {
                        callback(err, null)
                    } else {
                        callback(null, response)
                    }
                })
            }
        ],
        function finalCallback(finalErr, finalResponse) {
            if (finalErr) {
                mainCallback(finalErr, null)
            } else {
                mainCallback(null, finalResponse)
            }
        })
}


exports.getAdminError = function (req, res, mainCallback) {
    async.waterfall([
            function getAllApiNames(callback) {
                apiUsageDao.getAllApiNames(req, (err, response) => {
                    if (err) {
                        callback(err, null)
                    } else {
                        let errorResponse = []
                        let successResponse = []
                        let apiNameMatch;
                        if (util.isNull(req.query.apiName)) {
                            response.forEach(responseEle => {
                                successResponse.push(responseEle.DisplayName)
                            })
                            callback(null, successResponse)
                        } else {
                            response.forEach(responseEle => {
                                if (responseEle.DisplayName === req.query.apiName) {
                                    apiNameMatch = true
                                } else {
                                    errorResponse.push(responseEle.DisplayName)
                                }
                            })
                            apiNameMatch ? callback(null, response) : mainCallback({
                                "status": "failure",
                                "code": 400,
                                "message": `API name can only be one of : [${errorResponse}]`
                            }, null)
                        }
                    }
                })
            },
            function getAdminError(response, callback) {
                apiUsageDao.getAdminError(req, response, (err, response) => {
                    if (err) {
                        callback(err, null)
                    } else {
                        callback(null, response)
                    }
                })
            }
        ],
        function finalCallback(finalErr, finalResponse) {
            if (finalErr) {
                mainCallback(finalErr, null)
            } else {
                mainCallback(null, finalResponse)
            }
        })
}

exports.getApiPerformance = function (req, res, callback) {
    apiUsageDao.getApiPerformanceBasedOnExecutionTime(req, res, (err, result) => {
        if (err) {
            callback(err, null)
        } else {
            callback(null, result)
        }
    })
}

exports.getAllPricingPlans = function (req, callback) {
    apiUsageDao.getAllPricingPlans(req, (err, result) => {
        if (err) {
            callback(err, null)
        } else {
            callback(null, result)
        }
    })
}




