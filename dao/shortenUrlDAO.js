const db = require('../customnodemodules/database_node_module/app')
const apiUsageAttributesHelper = require('../helpers/shortenUrlHelper')
const constants = require('../constants/constants')


exports.getShortUrl = function (req, callback) {
    let hashValue = apiUsageAttributesHelper.getHashForUrl(req.body.url)
    let options = {
        sql: `select * from ${constants.db_tables["URL_MAPPING"]} where urlHash = ?`,
        values: [hashValue]
    }

    db.queryWithOptions(options, (dbErr, dbResp) => {
        if (dbErr) {
            callback(dbErr, null)
        } else {
            if (dbResp.length > 0) dbResp[0].code = constants.fetched
            callback(null, dbResp)
        }
    })
}

exports.createAndAddShortUrl = function (req, callback) {
    let url = req.body.url, base = constants.shortUrlBase
    let urlMappingObject = apiUsageAttributesHelper.requestUrlMapping(url)
    let shortUrl = urlMappingObject['shortUrl']

    let options = {
        sql: `insert into ${constants.db_tables['URL_MAPPING']} set ?`,
        values: [urlMappingObject]
    }

    db.queryWithOptions(options, (dbErr, dbResp) => {
        if (dbErr) {
            callback(dbErr, null)
        } else {
            let response = {}
            if (dbResp && dbResp.affectedRows && dbResp.affectedRows > 0) response = apiUsageAttributesHelper.responseUrlMapping(url, shortUrl)
            callback(null, response)
        }
    })
}

exports.getLongUrl = function (req, callback) {
    let token = req.url.split('/').pop()
    let options = {
        sql: `select longUrl from ${constants.db_tables['URL_MAPPING']} where token = ?`,
        values: [token]
    }

    db.queryWithOptions(options, (dbErr, dbResp) => {
        if (dbErr) {
            callback(dbErr, null)
        } else {
            if (dbResp.length > 0) {
                callback(null, dbResp[0])
            } else {
                callback(null, null)
            }
        }
    })
}

