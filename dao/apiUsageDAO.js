const db = require('../customnodemodules/database_node_module/app')
let errorMod = require('../customnodemodules/error_node_module/errors')
let customError = new errorMod()
const apiUsageAttributesHelper = require('../helpers/apiUsageHelper')
const constants = require('../constants/constants')
const moment = require('moment')

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
    let fromDate = moment(req.query.fromDate).format("YYYY-MM-DD HH:MM:SS")
    let toDate = req.query.toDate ? moment(req.query.toDate).format("YYYY-MM-DD HH:MM:SS") : moment(new Date()).format("YYYY-MM-DD HH:MM:SS")
    let apiKey = req.headers.api_key
    let options;
    if (constants.dailyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        options = {
            sql: "SELECT DATE(RequestDate), APIVersion, EndpointName, Count(*) as Count " +
                "FROM APIUsage " +
                "where APIKey = ? " +
                "AND DATE(RequestDate) >= DATE(?) AND DATE(RequestDate)<= DATE(?) " +
                "GROUP BY DATE(RequestDate), APIVersion, EndpointName ",
            values: [apiKey, fromDate, toDate]
        }
    } else if (constants.monthlyIntervalTypeConstant.includes(req.query.intervalType.toUpperCase())) {
        options = {
            sql: "SELECT MONTHNAME(RequestDate) as Month, APIVersion, EndpointName, Count(*) as Count " +
                "FROM APIUsage " +
                "WHERE APIKey = ? " +
                "AND DATE(RequestDate) >= DATE(?) AND DATE(RequestDate)<= DATE(?) " +
                "GROUP BY MONTHNAME(RequestDate), APIVersion, EndpointName",
            values: [apiKey, fromDate, toDate]
        }
    } else {
        options = {
            sql: "SELECT YEAR(RequestDate) as Year, APIVersion, EndpointName, Count(*) as Count " +
                "FROM APIUsage " +
                "WHERE APIKey = ? " +
                "AND DATE(RequestDate) >= DATE(?) AND DATE(RequestDate)<= DATE(?) " +
                "GROUP BY YEAR(RequestDate), APIVersion, EndpointName",
            values: [apiKey, fromDate, toDate]
        }
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
