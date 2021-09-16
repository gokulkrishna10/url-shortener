const async = require('async')
const apiUsageDao = require('../dao/apiUsageDAO')

exports.updateAPIUsage = function (req, res, mainCallback) {
    console.log("inside API usage")

    async.waterfall([
            function updateErrorDetails(callback) {
                if (req.isValidationError || (req.body.apiDetails && req.body.apiDetails.validationResult !== true)) {  // insert into error table only in case of an internal validation error or internal processing error. And also in the case of apiUsage validation endpoint error
                    apiUsageDao.insertErrorDetails(req, res, function (err, dbResponse) {
                        if (err) {
                            mainCallback(err, null)
                        } else {
                            if (dbResponse) {
                                mainCallback(null, '{"status":"successful","message":"error successfully recorded"}')
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

