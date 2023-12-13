const async = require('async')
const apiUsageDao = require('../dao/shortenUrlDAO')


exports.shortenUrl = function (req, mainCallback) {
    async.waterfall([
            function getShortUrl(callback) {
                apiUsageDao.getShortUrl(req, (err, result) => {
                    if (err) {
                        callback(err, null)
                    } else {
                        result.length > 0 ? mainCallback(null, result[0]) : callback(null, null)
                    }
                })
            },
            function createAndAddShortUrl(result, callback) {
                apiUsageDao.createAndAddShortUrl(req, (err, result) => {
                    if (err) {
                        callback(err, null)
                    } else {
                        callback(null, result)
                    }
                })
            }
        ],
        function finalCallback(finalErr, finalResp) {
            if (finalErr) {
                mainCallback(finalErr, null)
            } else {
                mainCallback(null, finalResp)
            }
        })
}

exports.redirectUsingShortUrl = function (req, callback) {
    apiUsageDao.getLongUrl(req, (err, response) => {
        if (err) {
            callback(err, null)
        } else {
            callback(null, response)
        }
    })
}


