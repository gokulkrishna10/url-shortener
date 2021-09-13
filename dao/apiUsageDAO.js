const db = require('../customnodemodules/database_node_module/app')
let errorMod = require('../customnodemodules/error_node_module/errors')
let customError = new errorMod()
const apiUsageAttributesHelper = require('../helpers/apiUsageHelper')

exports.getCustomerAPIDetails = function (req, res, callback) {

    let apiKey = req.headers.api_key
    let apiVersion = req.body.apiDetails.apiVersion
    let endPointName = req.body.apiDetails.endPointName
    let options;
    if (req.body.apiDetails.errorCode && req.body.apiDetails.errorDescription) {
        options = {
            sql: "SELECT ars.APINameId, ars.APICustomerId, ar.APIRouteId, ar.EndPointName " +
                "FROM APIRouteSubscription ars " +
                "JOIN APIRoute ar on ar.APINameId = ars.APINameId " +
                "JOIN APIName an ON an.APINameId = ars.APINameId " +
                "where an.Name = ? " +
                "AND (EndPointName = ? OR EndPointName = '/') " +
                "ORDER BY LENGTH(ar.EndPointName) DESC " +
                "LIMIT 1;",

            values: [req.body.apiDetails.apiName, endPointName]
        }
    } else {
        options = {
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