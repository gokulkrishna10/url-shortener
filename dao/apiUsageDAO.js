const db = require('../customnodemodules/database_node_module/app')
let errorMod = require('../customnodemodules/error_node_module/errors')
let customError = new errorMod()
const apiUsageAttributesHelper = require('../helpers/apiUsageHelper')
const constants = require('../constants/constants')
const moment = require('moment')
const sqlQueries = require('./sqlQueries')
const {parse} = require('json2csv');
const {environment} = require('../environments')

exports.getCustomerAPIDetails = function (req, res, callback) {

    let apiKey = req.headers.api_key
    let apiVersion = req.body.apiDetails.apiVersion
    let endPointName = req.body.apiDetails.endPointName
    let options = {
        sql: "SELECT ars.APINameId,ars.APICustomerId, arp.APIPricingPlanId, arp.BasePricePerCall, ar.APIRouteId, ar.EndPointName " +
            "FROM APIRouteSubscription ars " +
            "JOIN APIRoute ar on ar.APINameId = ars.APINameId " +
            "JOIN APIRoutePrice arp on ar.APIRouteId = arp.APIRouteId " +
            "where APIKey = ? " +
            "AND ar.APIVersion = ? " +
            "AND (EndPointName = ? OR EndPointName = '/') " +
            "ORDER BY LENGTH(ar.EndPointName) DESC " +
            "LIMIT 1;",

        values: [apiKey, apiVersion, endPointName]
    }

    db.queryWithOptions(options, function (err, dbResponse) {
        if (err) {
            callback(customError.dbError(err), null)
        } else {
            callback(null, dbResponse)
        }
    })
}

exports.insertAPIUsageDetails = function (req, res, result, callback) {

    let apiUsageObject = apiUsageAttributesHelper.getAPIUsageAttributes(req, res, result[0]);

    let options = {
        sql: "insert into APIUsage set ? ",
        values: [apiUsageObject]
    }

    db.queryWithOptions(options, function (err, dbResponse) {
        if (err) {
            callback(customError.dbError(err), null)
        } else {
            callback(null, dbResponse)
        }
    })
}

exports.insertErrorDetails = function (req, res, callback) {

    let apiErrorObject = apiUsageAttributesHelper.getAPIErrorAttributes(req, res)

    let options = {
        sql: "insert into APIError set ? ",
        values: [apiErrorObject]
    }

    db.queryWithOptions(options, (err, dbResult) => {
        if (err) {
            callback(customError.dbError(err), null)
        } else {
            if (dbResult.affectedRows && dbResult.affectedRows > 0) {
                res.APIErrorId = dbResult.insertId
                console.log("Inserted error logs successfully")
                callback(null, dbResult)
            } else {
                console.log("No records were inserted")
                callback(null, null)
            }
        }
    })
}


exports.validateApiKeyAndName = function (req, res, callback) {

    let options = {
        sql: "SELECT * from APIRouteSubscription ars " +
            "INNER JOIN APIName apn on ars.APINameId = apn.APINameId " +
            "WHERE Name = ? AND APIKey = ?",
        values: [req.body.apiName, req.headers.api_key]
    }

    db.queryWithOptions(options, function (error, dbResponse) {
        if (error) {
            console.log(error)
            callback(customError.dbError(error), null)
        } else {
            if (dbResponse && dbResponse.length > 0) {
                callback(null, dbResponse)
            } else {
                callback(null, null)
            }
        }
    })
}

exports.getAPIUsage = function (req, res, callback) {
    //Dont use moment.format("YYYY-MM-DD HH:MM:SS"), istead use the format : ("YYYY-MM-DD[T]HH:mm:ss"). The former, at times ,gives seconds > 60 and makes the date inmvalid creating unpredictable issues.
    //Ref : https://github.com/moment/moment/issues/4300
    let fromDate = moment(req.query.fromDate).format("YYYY-MM-DD[T]HH:mm:ss")
    let toDate = req.query.toDate ? moment(req.query.toDate).format("YYYY-MM-DD[T]HH:mm:ss") : moment(new Date()).format("YYYY-MM-DD[T]HH:mm:ss")
    let apiKey = req.headers.api_key
    let options;
    if (constants.dailyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        if (req.query.getEndpoints) {
            options = {
                sql: sqlQueries.GET_DAILY_USAGE_WITH_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_DAILY_USAGE_WO_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        }
    } else if (constants.monthlyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        if (req.query.getEndpoints) {
            options = {
                sql: sqlQueries.GET_MONTHLY_USAGE_WITH_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_MONTHLY_USAGE_WO_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        }
    } else {
        if (req.query.getEndpoints) {
            options = {
                sql: sqlQueries.GET_YEARLY_USAGE_WITH_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_YEARLY_USAGE_WO_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        }
    }

    console.log(options);
    db.queryWithOptions(options, (dbError, dbResult) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            if (dbResult && dbResult.length > 0) {
                if (req.headers["content-type"] && req.headers["content-type"].includes("csv")) {
                    callback(null, parse(dbResult))
                } else {
                    callback(null, dbResult)
                }
            } else {
                callback(null, "No Data")
            }
        }
    })
}

exports.getAPIError = function (req, res, callback) {
    let fromDate = moment(req.query.fromDate).format("YYYY-MM-DD[T]HH:mm:ss")
    let toDate = req.query.toDate ? moment(req.query.toDate).format("YYYY-MM-DD[T]HH:mm:ss") : moment(new Date()).format("YYYY-MM-DD[T]HH:mm:ss")
    let apiKey = req.headers.api_key
    let options;
    if (constants.dailyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        if (req.query.getErrorCountsOnly === 'true') {
            options = {
                sql: sqlQueries.GET_DAILY_ERROR_COUNT,
                values: [apiKey, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_ERRORS_WITH_DETAILS,
                values: [apiKey, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
            }
        }
    } else if (constants.monthlyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        if (req.query.getErrorCountsOnly === 'true') {
            options = {
                sql: sqlQueries.GET_MONTLY_ERROR_COUNT,
                values: [apiKey, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_ERRORS_WITH_DETAILS,
                values: [apiKey, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
            }
        }
    } else {
        if (req.query.getErrorCountsOnly === 'true') {
            options = {
                sql: sqlQueries.GET_YEARLY_ERROR_COUNT,
                values: [apiKey, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_ERRORS_WITH_DETAILS,
                values: [apiKey, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
            }
        }
    }

    console.log(options);
    db.queryWithOptions(options, (dbError, dbResult) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            if (dbResult && dbResult.length > 0) {
                if (req.headers["content-type"] && req.headers["content-type"].includes("csv")) {
                    callback(null, parse(dbResult))
                } else {
                    callback(null, dbResult)
                }
            } else {
                callback(null, "No Data")
            }
        }
    })
}


exports.insertIntoApiName = function (req, callback) {
    let apiNameAttributes = apiUsageAttributesHelper.getAPINameAttributes(req);
    let options = {
        sql: "insert into APIName set ?",
        values: [apiNameAttributes]
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            let dbErrorResponse;
            if (dbError.code === "ER_DUP_ENTRY") {
                dbErrorResponse = {"status": "failure", "message": "Duplicate entry", code: 400}
            } else {
                dbErrorResponse = {"status": "failure", "message": "API onboard failed", code: 500}
            }
            callback(dbErrorResponse, null)
        } else {
            callback(null, dbResponse)
        }
    })
}

exports.insertIntoApiRoute = function (req, callback) {
    let apiRouteAttributes = apiUsageAttributesHelper.getAPIRouteAttributes(req);
    let options = {
        sql: "insert into APIRoute set ?",
        values: [apiRouteAttributes]
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            let dbErrorResponse;
            if (dbError.code === "ER_DUP_ENTRY") {
                dbErrorResponse = {"status": "failure", "message": "Duplicate entry", code: 400}
            } else {
                dbErrorResponse = {"status": "failure", "message": "API onboard failed", code: 500}
            }
            callback(dbErrorResponse, null)
        } else {
            callback(null, dbResponse)
        }
    })
}

exports.insertIntoApiRoutePrice = function (req, callback) {
    let apiRoutePriceAttributes = apiUsageAttributesHelper.getAPIRoutePriceAttributes(req);
    let options = {
        sql: "insert into APIRoutePrice set ?",
        values: [apiRoutePriceAttributes]
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            let dbErrorResponse;
            if (dbError.code === "ER_DUP_ENTRY") {
                dbErrorResponse = {"status": "failure", "message": "Duplicate entry", code: 400}
            } else {
                dbErrorResponse = {"status": "failure", "message": "API onboard failed", code: 500}
            }
            callback(dbErrorResponse, null)
        } else {
            callback(null, dbResponse)
        }
    })
}

exports.getAPICustomerIdAndApiNameId = function (req, callback) {
    let options = [{
        sql: "select APICustomerId from APICustomer where CustomerName = ?",
        values: [req.body.customerName]
    }, {
        sql: "select APINameId from APIName where Name = ?",
        values: [req.body.apiName]
    }]

    db.executeMultipleWithOptions(options, true, (dbError, dbResponse) => {
        if (dbError) {
            callback(dbError, null)
        } else {
            let dbSuccessResponse = {};
            if (dbResponse && dbResponse[0].length === 0) {
                dbSuccessResponse = {
                    "status": "failure",
                    "message": "Requested Customer name does not match with our records",
                    code: 400
                }
            } else if (dbResponse && dbResponse[1].length === 0) {
                dbSuccessResponse = {
                    "status": "failure",
                    "message": "Requested API name does not match with our records",
                    code: 400
                }
            } else {
                dbSuccessResponse.APICustomerId = dbResponse[0][0].APICustomerId
                dbSuccessResponse.APINameId = dbResponse[1][0].APINameId
            }
            callback(null, dbSuccessResponse)
        }
    })
}

exports.checkTheCustomerIdAndApiNameId = function (response, callback) {
    let options = {
        sql: "select APICustomerId, APINameId from APIRouteSubscription where APICustomerId = ? AND APINameId = ?",
        values: [response.APICustomerId, response.APINameId]
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            let dbSuccessResponse = {};
            if (dbResponse && dbResponse.length > 0) {
                dbSuccessResponse = {
                    "status": "failure",
                    "message": "This customer is already subscribed to the requested API",
                    code: 400
                }
            }
            callback(null, dbSuccessResponse)
        }
    })
}

exports.insertIntoApiRouteSubscription = function (response, callback) {
    let apiRouteSubscriptionAttributes = apiUsageAttributesHelper.getApiRouteSubscriptionAttributes(response)
    let options = {
        sql: "insert into APIRouteSubscription set ?",
        values: [apiRouteSubscriptionAttributes]
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            let finalResponse = {}
            if (dbResponse && dbResponse.affectedRows > 0) {
                finalResponse = {
                    "status": "successful",
                    "apiKey": apiRouteSubscriptionAttributes.APIKey
                }
            } else {
                finalResponse = {
                    "status": "failure",
                    "message": "API route subscription failed",
                    "code": 500
                }
            }
            callback(null, finalResponse)
        }
    })
}