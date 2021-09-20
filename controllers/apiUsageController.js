const async = require('async')
const apiUsageDao = require('../dao/apiUsageDAO')

exports.updateAPIUsage = function (req, res, mainCallback) {
    console.log("inside API usage")

    let apiUsageClientValidationError = (req.body.apiDetails && Boolean(req.body.apiDetails.validationResult)  && req.body.apiDetails.validationResult !== true) ;
    let apiUsageClientError = (req.body.apiDetails && (Boolean(req.body.apiDetails.errorCode) || Boolean(req.body.apiDetails.errorDescription)));

    async.waterfall([
            function updateErrorDetails(callback) {
                if (req.isValidationError   //api-usage input rquest validation failed
                    || apiUsageClientValidationError  //request validation failed from client API
                    || apiUsageClientError
                ){  
                    apiUsageDao.insertErrorDetails(req, res, function (err, dbResponse) {
                        if (err) {
                            mainCallback(err, null)
                        } else {
                            if (dbResponse) {
                                if (!req.isValidationError  && apiUsageClientError){
                                    callback(null, req);
                                }else{
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

