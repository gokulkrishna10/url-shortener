const async = require('async')
const apiUsageDao = require('../dao/apiUsageDAO')
const {response} = require("express");

exports.updateAPIUsage = function (req, res, mainCallback) {
    console.log("inside API usage")

    let apiUsageClientValidationError = (req.body.apiDetails && Boolean(req.body.apiDetails.validationResult) && req.body.apiDetails.validationResult !== true);
    let apiUsageClientError = (req.body.apiDetails && (Boolean(req.body.apiDetails.errorCode) || Boolean(req.body.apiDetails.errorDescription)));

    async.waterfall([
            function updateErrorDetails(callback) {
                if (req.isValidationError   //api-usage input rquest validation failed
                    || apiUsageClientValidationError  //request validation failed from client API
                    || apiUsageClientError
                ) {
                    apiUsageDao.insertErrorDetails(req, res, function (err, dbResponse) {
                        if (err) {
                            mainCallback(err, null)
                        } else {
                            if (dbResponse) {
                                if (!req.isValidationError && apiUsageClientError) {
                                    callback(null, req);
                                } else {
                                    //We donot have enough details to create an entry with APIUsage table and hence leaving after making an entry to APIError table.
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
        function insertIntoApiName(callback) {
            apiUsageDao.insertIntoApiName(req, (err, response) => {
                if (err) {
                    callback(err, null)
                } else {
                    req.apiNameId = response.insertId
                    callback(null, req)
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


exports.customerApiSubscription = function (req, res, mainCallback) {
    console.log("inside customerApiSubscription")

    async.waterfall([
        function getAPICustomerAndApiNameId(callback) {
            apiUsageDao.getAPICustomerAndApiNameId(req, (err, response) => {
                if (err) {
                    callback(err, null)
                } else {
                    callback(null, response)
                }
            })
        }, function insertIntoApiRouteSubscription(response, callback) {
            apiUsageDao.insertIntoApiRouteSubscription(response, (err, response) => {
                if (err) {
                    callback(err, null)
                } else {
                    let response = {"status": "successful", "apiName": req.body.apiName,"customerName":req.body.customerName,"apiKey":response.apiKey}
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

