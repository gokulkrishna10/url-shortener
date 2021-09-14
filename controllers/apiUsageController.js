const async = require('async')
const apiUsageDao = require('../dao/apiUsageDAO')

exports.updateAPIUsage = function (req, res, mainCallback) {
    console.log("inside API usage")
    let allResponse = {};

    async.waterfall([
            function updateErrorDetails(callback) {
                if (req.isValidationError || !(req.body.apiDetails.validationResult)) {  // insert into error table only in case of an internal validation error or internal processing error. And also in the case of apiUsage validation endpoint error
                    apiUsageDao.insertErrorDetails(req, res, function (err, dbResponse) {
                        if (err) {
                            mainCallback(err, null)
                        } else {
                            if (dbResponse) {
                                mainCallback(null, "{status:successful,message:error successfully recorded}")
                            } else {
                                mainCallback(null, "{status:failure,message:failed to record the error}")
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
                        if (req.body.apiDetails && req.body.apiDetails.errorCode && req.body.apiDetails.errorDescription) {
                            apiUsageDao.insertErrorDetails(req, res, (err, response) => {
                                if (err) {
                                    callback(err, null)
                                } else {
                                    callback(null, result)
                                }
                            })
                        } else {
                            allResponse['customerAPIInfo'] = result[0]
                            callback(null, result)
                        }

                    }
                })
            },
            function insertAPIUsageDetails(result, callback) {
                if (result && result.length > 0) {
                    apiUsageDao.insertAPIUsageDetails(req, res, result, function (err, response) {
                        if (err) {
                            callback(err, null)
                        } else {
                            callback(null, allResponse)
                        }
                    })
                } else {
                    //update error table
                    // insert into error table only in case of an internal validation error or internal processing error
                    if (!req.body.apiDetails && !req.body.apiDetails.errorCode && !req.body.apiDetails.errorDescription) {
                        apiUsageDao.insertErrorDetails(req, res, (err, response) => {
                            if (err) {
                                callback(err, null)
                            } else {
                                callback(null, response)
                            }
                        })
                    } else {
                        callback(null, allResponse)
                    }
                }
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

