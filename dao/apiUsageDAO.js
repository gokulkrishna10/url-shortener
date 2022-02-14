const db = require('../customnodemodules/database_node_module/app')
let errorMod = require('../customnodemodules/error_node_module/errors')
let customError = new errorMod()
const apiUsageAttributesHelper = require('../helpers/apiUsageHelper')
const constants = require('../constants/constants')
const moment = require('moment')
const sqlQueries = require('./sqlQueries')
const {parse} = require('json2csv');
const {environment} = require('../environments')
const util = require('../customnodemodules/util_node_module/utils')

exports.getCustomerAPIDetails = function (req, res, callback) {

    let apiKey = req.headers.api_key
    let apiVersion = req.body.apiDetails.apiVersion
    let endPointName = req.body.apiDetails.endPointName
    let apiName = req.body.apiDetails.apiName
    let options = {
        sql: "SELECT ars.APINameId,ars.APICustomerId, arp.APIPricingPlanId, arp.BasePricePerCall, ar.APIRouteId, ar.EndPointName " +
            "FROM APIRouteSubscription ars " +
            "JOIN APIName an on an.APINameId = ars.APINameId " +
            "JOIN APIRoute ar on ar.APINameId = ars.APINameId " +
            "JOIN APIRoutePrice arp on ar.APIRouteId = arp.APIRouteId " +
            "JOIN APICustomer ac on ars.APICustomerId = ac.APICustomerId " +
            "where ac.APIKey = ? AND an.Name = ? " +
            "AND ar.APIVersion = ? " +
            "AND (EndPointName = ? OR EndPointName = '/') " +
            "ORDER BY LENGTH(ar.EndPointName) DESC " +
            "LIMIT 1;",

        values: [apiKey, apiName, apiVersion, endPointName]
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


//THis method is being called by client APIs to validate before invoking the API endpoints
exports.validateApiKeyAndName = function (req, res, callback) {

    let options = {
        sql: "SELECT * from APIRouteSubscription ars " +
            "INNER JOIN APIName apn on ars.APINameId = apn.APINameId " +
            "INNER JOIN APICustomer ac on ars.APICustomerId = ac.APICustomerId " +
            "WHERE Name = ? AND ac.APIKey = ?",
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

//This method is being called by the external clients of API Usage and is being to 
// validate the cleints with just their APIKey. Used before invoking usage and error endpoints.
exports.validateApiKey = function (req, res, callback) {

    let options = {
        sql: "SELECT * from APIRouteSubscription ars " +
            "INNER JOIN APIName apn on ars.APINameId = apn.APINameId " +
            "INNER JOIN APICustomer ac on ars.APICustomerId = ac.APICustomerId " +
            "WHERE ac.APIKey = ?",

        values: [req.headers.api_key]
    }

    db.queryWithOptions(options, function (error, dbResponse) {
        if (error) {
            console.log(error)
            callback(apiUsageAttributesHelper.setErrorCode(customError.Unauthorized("Failed to validate. Please try again.", constants.errorCodeExcludeFromAPIUsageLogging)), null)
        } else {
            if (dbResponse && dbResponse.length > 0) {
                callback(null, dbResponse)
            } else {
                console.log("validateApiKey() failed for :" + req.headers.api_key);
                callback(apiUsageAttributesHelper.setErrorCode(customError.Unauthorized("Failed to authorize. Please set correct value for header : api_key", constants.errorCodeExcludeFromAPIUsageLogging)), null)
            }
        }
    })
}

exports.getAPIUsage = function (req, res, callback) {
    //Dont use moment.format("YYYY-MM-DD HH:MM:SS"), istead use the format : ("YYYY-MM-DD[T]HH:mm:ss"). The former, at times ,gives seconds > 60 and makes the date inmvalid creating unpredictable issues.
    //Ref : https://github.com/moment/moment/issues/4300
    let fromDate = moment(req.query.fromDate).format("YYYY-MM-DD[T]HH:mm:ss")
    let toDate;
    if (!req.query.toDate) {
        toDate = moment(new Date()).format("YYYY-MM-DD[T]23:59:ss");
    } else if (req.query.toDate && (moment(req.query.toDate).format("HH:mm:ss")) === "00:00:00") {
        toDate = moment(req.query.toDate).format("YYYY-MM-DD[T]23:59:ss");
    } else {
        toDate = moment(req.query.toDate).format("YYYY-MM-DD[T]HH:mm:ss");
    }
    let apiKey = req.headers.api_key
    let apiName = req.query.apiName
    let options;
    if (constants.dailyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        if (req.query.getEndpoints === "true" && !apiName) {
            options = {
                sql: sqlQueries.GET_DAILY_USAGE_WITH_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        } else if (req.query.getEndpoints === "true" && apiName) {
            options = {
                sql: sqlQueries.GET_DAILY_USAGE_WITH_ENDPOINTS_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate]
            }
        } else if (req.query.getEndpoints !== "true" && apiName) {
            options = {
                sql: sqlQueries.GET_DAILY_USAGE_WO_ENDPOINTS_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_DAILY_USAGE_WO_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        }
    } else if (constants.monthlyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        if (req.query.getEndpoints === "true" && !apiName) {
            options = {
                sql: sqlQueries.GET_MONTHLY_USAGE_WITH_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        } else if (req.query.getEndpoints === "true" && apiName) {
            options = {
                sql: sqlQueries.GET_MONTHLY_USAGE_WITH_ENDPOINTS_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate]
            }
        } else if (req.query.getEndpoints !== "true" && apiName) {
            options = {
                sql: sqlQueries.GET_MONTHLY_USAGE_WO_ENDPOINTS_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_MONTHLY_USAGE_WO_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        }
    } else {
        if (req.query.getEndpoints === "true" && !apiName) {
            options = {
                sql: sqlQueries.GET_YEARLY_USAGE_WITH_ENDPOINTS_QUERY,
                values: [apiKey, fromDate, toDate]
            }
        } else if (req.query.getEndpoints === "true" && apiName) {
            options = {
                sql: sqlQueries.GET_YEARLY_USAGE_WITH_ENDPOINTS_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate]
            }
        } else if (req.query.getEndpoints !== "true" && apiName) {
            options = {
                sql: sqlQueries.GET_YEARLY_USAGE_WO_ENDPOINTS_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate]
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
                dbResult.forEach(dbRows => {
                    if (dbRows.Date) {
                        dbRows.Date = moment(dbRows.Date).format("YYYY-MM-DD")
                    }
                })
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
    let toDate;
    if (!req.query.toDate) {
        toDate = moment(new Date()).format("YYYY-MM-DD[T]23:59:ss");
    } else if (req.query.toDate && (moment(req.query.toDate).format("HH:mm:ss")) === "00:00:00") {
        toDate = moment(req.query.toDate).format("YYYY-MM-DD[T]23:59:ss");
    } else {
        toDate = moment(req.query.toDate).format("YYYY-MM-DD[T]HH:mm:ss");
    }
    let apiKey = req.headers.api_key
    let apiName = req.query.apiName
    let options;
    if (constants.dailyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        if (req.query.getErrorDetails === 'true' && !apiName) {
            options = {
                sql: sqlQueries.GET_ERRORS_WITH_DETAILS,
                values: [apiKey, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
            }
        } else if (req.query.getErrorDetails === 'true' && apiName) {
            options = {
                sql: sqlQueries.GET_ERRORS_WITH_DETAILS_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
            }
        } else if (req.query.getErrorDetails !== 'true' && apiName) {
            options = {
                sql: sqlQueries.GET_DAILY_ERROR_COUNT_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_DAILY_ERROR_COUNT,
                values: [apiKey, fromDate, toDate]
            }
        }
    } else if (constants.monthlyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        if (req.query.getErrorDetails === 'true' && !apiName) {
            options = {
                sql: sqlQueries.GET_ERRORS_WITH_DETAILS,
                values: [apiKey, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
            }
        } else if (req.query.getErrorDetails === 'true' && apiName) {
            options = {
                sql: sqlQueries.GET_ERRORS_WITH_DETAILS_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
            }
        } else if (req.query.getErrorDetails !== 'true' && apiName) {
            options = {
                sql: sqlQueries.GET_MONTLY_ERROR_COUNT_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_MONTLY_ERROR_COUNT,
                values: [apiKey, fromDate, toDate]
            }
        }
    } else {
        if (req.query.getErrorDetails === 'true' && !apiName) {
            options = {
                sql: sqlQueries.GET_ERRORS_WITH_DETAILS,
                values: [apiKey, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
            }
        } else if (req.query.getErrorDetails === 'true' && apiName) {
            options = {
                sql: sqlQueries.GET_ERRORS_WITH_DETAILS_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
            }
        } else if (req.query.getErrorDetails !== 'true' && apiName) {
            options = {
                sql: sqlQueries.GET_YEARLY_ERROR_COUNT_AND_API_NAME_QUERY,
                values: [apiKey, apiName, fromDate, toDate]
            }
        } else {
            options = {
                sql: sqlQueries.GET_YEARLY_ERROR_COUNT,
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
                dbResult.forEach(dbRows => {
                    if (dbRows.Date) {
                        dbRows.Date = moment(dbRows.Date).format("YYYY-MM-DD")
                    }
                })
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


exports.checkIfApiAndEndpointExists = function (req, callback) {
    let options = {
        sql: "SELECT ar.EndpointName,an.Name " +
            "FROM APIName an " +
            "JOIN APIRoute ar on ar.APINameId = an.APINameId " +
            "where an.Name = ? AND ar.EndpointName = ?;",
        values: [req.body.name, req.body.endPointName]
    }

    db.queryWithOptions(options, (dbError, dbResult) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            if (dbResult && dbResult.length > 0) {
                callback(null, dbResult)
            } else {
                callback(null, null)
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
                // dbErrorResponse = {"status": "failure", "message": "Duplicate entry", code: 400}
                callback(null, req)
            } else {
                dbErrorResponse = {"status": "failure", "message": "API onboard failed", code: 500}
                callback(dbErrorResponse, null)
            }

        } else {
            callback(null, dbResponse)
        }
    })
}

exports.getApiNameId = function (req, callback) {
    let options = {
        sql: "SELECT * FROM APIName where Name = ?",
        values: [req.body.name]
    }

    db.queryWithOptions(options, function (dbError, dbResult) {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            callback(null, dbResult[0])
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


exports.addNewCustomer = function (req, callback) {
    let customerObject = apiUsageAttributesHelper.getCustomerAttributes(req)
    let options = {
        sql: "insert into APICustomer set ?",
        values: [customerObject]
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            let dbErrorResponse;
            if (dbError.code === "ER_DUP_ENTRY") {
                dbErrorResponse = {"status": "failure", "message": "Customer is already present", code: 400}
            } else {
                dbErrorResponse = {"status": "failure", "message": "Failed to add the customer", code: 500}
            }
            callback(dbErrorResponse, null)
        } else {
            let response = {
                "status": "successful",
                "message": `Added customer successfully with the apiKey : ${customerObject.APIKey}`
            }
            callback(null, response)
        }
    })
}


exports.getAPICustomerIdAndApiNameIdAndPricingPlanId = function (req, callback) {
    let options = [{
        sql: "select APICustomerId from APICustomer where CustomerName = ?",
        values: [req.body.customerName]
    }, {
        sql: "select APINameId from APIName where DisplayName = ?",
        values: [req.body.apiName]
    }, {
        sql: "select APIPricingPlanId from APIPricingPlan where Name = ?",
        values: [req.body.pricingPlan]
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
            } else if (dbResponse && dbResponse[2].length === 0) {
                dbSuccessResponse = {
                    "status": "failure",
                    "message": `Requested pricing plan is not available. pricingPlan value can only be one of [${constants.pricingPlans}]`,
                    code: 400
                }
            } else {
                dbSuccessResponse.APICustomerId = dbResponse[0][0].APICustomerId
                dbSuccessResponse.APINameId = dbResponse[1][0].APINameId
                dbSuccessResponse.APIPricingPlanId = dbResponse[2][0].APIPricingPlanId
            }
            callback(null, dbSuccessResponse)
        }
    })
}

exports.checkTheCustomerIdAndApiNameIdAndPricingPlanId = function (response, callback) {
    let options = {
        sql: "select APICustomerId, APINameId, APIPricingPlanId from APIRouteSubscription where APICustomerId = ? AND APINameId = ? AND APIPricingPlanId = ?",
        values: [response.APICustomerId, response.APINameId, response.APIPricingPlanId]
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            let dbSuccessResponse = {};
            if (dbResponse && dbResponse.length > 0) {
                dbSuccessResponse = {
                    "status": "failure",
                    "message": "This customer is already subscribed to the requested API and pricingPlan",
                    code: 400
                }
            }
            callback(null, dbSuccessResponse)
        }
    })
}

exports.insertOrUpdateToApiRouteSubscription = function (response, callback) {
    let apiRouteSubscriptionAttributes = apiUsageAttributesHelper.getApiRouteSubscriptionAttributes(response)
    let options = {
        sql: "insert into APIRouteSubscription set ? ON DUPLICATE KEY UPDATE ?",
        values: [apiRouteSubscriptionAttributes, apiRouteSubscriptionAttributes]
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            let finalResponse = {}
            if (dbResponse && dbResponse.affectedRows > 0) {
                finalResponse = {
                    "status": "successful",
                    "message": "Customer successfully subscribed to the API",
                    "apiKey": apiRouteSubscriptionAttributes.APIKey  // purge this after the apiKey is removed from apiSubscription table
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


exports.getAllApiNames = function (req, callback) {
    let options = {
        sql: "select DisplayName,Description from APIName"
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            callback(null, dbResponse)
        }
    })
}

exports.getAdminUsage = function (req, response, callback) {

    let fromDate = moment(req.query.fromDate).format("YYYY-MM-DD[T]HH:mm:ss")
    let toDate;
    if (!req.query.toDate) {
        toDate = moment(new Date()).format("YYYY-MM-DD[T]23:59:ss");
    } else if (req.query.toDate && (moment(req.query.toDate).format("HH:mm:ss")) === "00:00:00") {
        toDate = moment(req.query.toDate).format("YYYY-MM-DD[T]23:59:ss");
    } else {
        toDate = moment(req.query.toDate).format("YYYY-MM-DD[T]HH:mm:ss");
    }
    let options = [];

    if (util.isNull(req.query.apiName)) {
        for (const responseEle of response) {

            let apiName = responseEle;

            if (constants.dailyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
                if (req.query.getEndpoints === "true") {
                    options.push({
                        sql: sqlQueries.GET_DAILY_ADMIN_USAGE_WITH_ENDPOINTS_QUERY,
                        values: [apiName, fromDate, toDate]
                    })
                } else {
                    options.push({
                        sql: sqlQueries.GET_DAILY_ADMIN_USAGE_WO_ENDPOINTS_QUERY,
                        values: [apiName, fromDate, toDate]
                    })
                }
            } else if (constants.monthlyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
                if (req.query.getEndpoints === "true") {
                    options.push({
                        sql: sqlQueries.GET_MONTHLY_ADMIN_USAGE_WITH_ENDPOINTS_QUERY,
                        values: [apiName, fromDate, toDate]
                    })
                } else {
                    options.push({
                        sql: sqlQueries.GET_MONTHLY_ADMIN_USAGE_WO_ENDPOINTS_QUERY,
                        values: [apiName, fromDate, toDate]
                    })
                }
            } else {
                if (req.query.getEndpoints === "true") {
                    options.push({
                        sql: sqlQueries.GET_YEARLY_ADMIN_USAGE_WITH_ENDPOINTS_QUERY,
                        values: [apiName, fromDate, toDate]
                    })
                } else {
                    options.push({
                        sql: sqlQueries.GET_YEARLY_ADMIN_USAGE_WO_ENDPOINTS_QUERY,
                        values: [apiName, fromDate, toDate]
                    })
                }
            }
        }

    } else {
        let apiName = req.query.apiName

        if (constants.dailyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
            if (req.query.getEndpoints === "true") {
                options.push({
                    sql: sqlQueries.GET_DAILY_ADMIN_USAGE_WITH_ENDPOINTS_QUERY,
                    values: [apiName, fromDate, toDate]
                })
            } else {
                options.push({
                    sql: sqlQueries.GET_DAILY_ADMIN_USAGE_WO_ENDPOINTS_QUERY,
                    values: [apiName, fromDate, toDate]
                })
            }
        } else if (constants.monthlyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
            if (req.query.getEndpoints === "true") {
                options.push({
                    sql: sqlQueries.GET_MONTHLY_ADMIN_USAGE_WITH_ENDPOINTS_QUERY,
                    values: [apiName, fromDate, toDate]
                })
            } else {
                options.push({
                    sql: sqlQueries.GET_MONTHLY_ADMIN_USAGE_WO_ENDPOINTS_QUERY,
                    values: [apiName, fromDate, toDate]
                })
            }
        } else {
            if (req.query.getEndpoints === "true") {
                options.push({
                    sql: sqlQueries.GET_YEARLY_ADMIN_USAGE_WITH_ENDPOINTS_QUERY,
                    values: [apiName, fromDate, toDate]
                })
            } else {
                options.push({
                    sql: sqlQueries.GET_YEARLY_ADMIN_USAGE_WO_ENDPOINTS_QUERY,
                    values: [apiName, fromDate, toDate]
                })
            }
        }
    }

    console.log(options);
    db.executeMultipleWithOptions(options, true, (dbError, dbResult) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            if (dbResult && dbResult.length > 0) {
                let csvResponse = [];
                dbResult.forEach(dbRows => {
                    if (dbRows && dbRows.length > 0) {
                        dbRows.forEach(result => {
                            if (result.Date) {
                                result.Date = moment(result.Date).format("YYYY-MM-DD");
                            }
                            csvResponse.push(result)
                        })
                    } else {
                        csvResponse.push()
                    }
                })
                if (req.headers["content-type"] && req.headers["content-type"].includes("csv")) {
                    csvResponse.length > 0 ? callback(null, parse(csvResponse)) : callback(null, "No Data")
                } else {
                    csvResponse.length > 0 ? callback(null, csvResponse) : callback(null, "No Data")
                }
            } else {
                callback(null, "No Data")
            }
        }
    })
}


exports.getAdminError = function (req, response, callback) {
    let fromDate = moment(req.query.fromDate).format("YYYY-MM-DD[T]HH:mm:ss")
    let toDate;
    if (!req.query.toDate) {
        toDate = moment(new Date()).format("YYYY-MM-DD[T]23:59:ss");
    } else if (req.query.toDate && (moment(req.query.toDate).format("HH:mm:ss")) === "00:00:00") {
        toDate = moment(req.query.toDate).format("YYYY-MM-DD[T]23:59:ss");
    } else {
        toDate = moment(req.query.toDate).format("YYYY-MM-DD[T]HH:mm:ss");
    }
    let options = [];

    if (util.isNull(req.query.apiName)) {
        for (const responseEle of response) {

            let apiName = responseEle;

            if (constants.dailyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
                if (req.query.getErrorDetails === 'true') {
                    options.push({
                        sql: sqlQueries.GET_ERRORS_ADMIN_WITH_DETAILS,
                        values: [apiName, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
                    })
                } else {
                    options.push({
                        sql: sqlQueries.GET_DAILY_ADMIN_ERROR_COUNT,
                        values: [apiName, fromDate, toDate]
                    })
                }
            } else if (constants.monthlyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
                if (req.query.getErrorDetails === 'true') {
                    options.push({
                        sql: sqlQueries.GET_ERRORS_ADMIN_WITH_DETAILS,
                        values: [apiName, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
                    })
                } else {
                    options.push({
                        sql: sqlQueries.GET_MONTLY_ADMIN_ERROR_COUNT,
                        values: [apiName, fromDate, toDate]
                    })
                }
            } else {
                if (req.query.getErrorDetails === 'true') {
                    options.push({
                        sql: sqlQueries.GET_ERRORS_ADMIN_WITH_DETAILS,
                        values: [apiName, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
                    })
                } else {
                    options.push({
                        sql: sqlQueries.GET_YEARLY_ADMIN_ERROR_COUNT,
                        values: [apiName, fromDate, toDate]
                    })
                }
            }
        }

    } else {
        let apiName = req.query.apiName

        if (constants.dailyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
            if (req.query.getErrorDetails === 'true') {
                options.push({
                    sql: sqlQueries.GET_ERRORS_ADMIN_WITH_DETAILS,
                    values: [apiName, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
                })
            } else {
                options.push({
                    sql: sqlQueries.GET_DAILY_ADMIN_ERROR_COUNT,
                    values: [apiName, fromDate, toDate]
                })
            }
        } else if (constants.monthlyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
            if (req.query.getErrorDetails === 'true') {
                options.push({
                    sql: sqlQueries.GET_ERRORS_ADMIN_WITH_DETAILS,
                    values: [apiName, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
                })
            } else {
                options.push({
                    sql: sqlQueries.GET_MONTLY_ADMIN_ERROR_COUNT,
                    values: [apiName, fromDate, toDate]
                })
            }
        } else {
            if (req.query.getErrorDetails === 'true') {
                options.push({
                    sql: sqlQueries.GET_ERRORS_ADMIN_WITH_DETAILS,
                    values: [apiName, fromDate, toDate, environment.MAX_ERROR_GET_COUNT]
                })
            } else {
                options.push({
                    sql: sqlQueries.GET_YEARLY_ADMIN_ERROR_COUNT,
                    values: [apiName, fromDate, toDate]
                })
            }
        }
    }

    console.log(options);
    db.executeMultipleWithOptions(options, true, (dbError, dbResult) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            if (dbResult && dbResult.length > 0) {
                let csvResponse = [];
                dbResult.forEach(dbRows => {
                    if (dbRows && dbRows.length > 0) {
                        dbRows.forEach(result => {
                            if (result.Date) {
                                result.Date = moment(result.Date).format("YYYY-MM-DD");
                            }
                            csvResponse.push(result)
                        })
                    } else {
                        csvResponse.push()
                    }
                })
                if (req.headers["content-type"] && req.headers["content-type"].includes("csv")) {
                    csvResponse.length > 0 ? callback(null, parse(csvResponse)) : callback(null, "No Data")
                } else {
                    csvResponse.length > 0 ? callback(null, csvResponse) : callback(null, "No Data")
                }
            } else {
                callback(null, "No Data")
            }
        }
    })
}


// For query ref : https://ubiq.co/database-blog/select-top-10-records-for-each-category-in-mysql/
exports.getApiPerformanceBasedOnExecutionTime = function (req, res, callback) {
    let options = {};
    if (req.query.fastestOnTop === "true") {
        options = {
            sql: "SELECT an.APINameId, an.DisplayName as APIName, t.EndpointName, DATE_FORMAT(t.RequestDate,\"%Y-%m-%d %H:%i:%s\") as Date, t.TimeTakenMilliseconds as ExecutionTime " +
                "FROM " +
                "(SELECT au.EndpointName, au.RequestDate, au.TimeTakenMilliseconds, au.HttpStatusCode, au.APINameId, " +
                "@product_rank := IF(@current_product = APINameId, @product_rank + 1, 1) AS product_rank, " +
                "@current_product := APINameId " +
                "FROM APIUsage au " +
                "ORDER BY APINameId, TimeTakenMilliseconds, RequestDate DESC) t " +
                "LEFT OUTER JOIN APIName an on an.APINameId = t.APINameId " +
                "where product_rank<=10 " +
                "AND t.HttpStatusCode = 200;"
        }
    } else {
        options = {
            sql: "SELECT an.APINameId, an.DisplayName as APIName, t.EndpointName, DATE_FORMAT(t.RequestDate,\"%Y-%m-%d %H:%i:%s\") as Date, t.TimeTakenMilliseconds as ExecutionTime " +
                "FROM " +
                "(SELECT au.EndpointName, au.RequestDate, au.TimeTakenMilliseconds, au.HttpStatusCode, au.APINameId, " +
                "@product_rank := IF(@current_product = APINameId, @product_rank + 1, 1) AS product_rank, " +
                "@current_product := APINameId " +
                "FROM APIUsage au " +
                "ORDER BY APINameId, TimeTakenMilliseconds DESC, RequestDate DESC) t " +
                "LEFT OUTER JOIN APIName an on an.APINameId = t.APINameId " +
                "where product_rank<=10 " +
                "AND t.HttpStatusCode = 200"
        }
    }


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


exports.getAllPricingPlans = function (req, callback) {
    let options = {
        sql: "select Name from APIPricingPlan",
    }

    db.queryWithOptions(options, (dbError, dbResponse) => {
        if (dbError) {
            callback(customError.dbError(dbError), null)
        } else {
            if (dbResponse && dbResponse.length > 0) {
                if (req.headers["content-type"] && req.headers["content-type"].includes("csv")) {
                    callback(null, parse(dbResponse))
                } else {
                    callback(null, dbResponse)
                }
            } else {
                callback(null, "{message:No data}")
            }
        }
    })
}

