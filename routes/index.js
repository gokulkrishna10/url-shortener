const apiUsage = require('../controllers/shortenUrlController')
const util = require("../customnodemodules/util_node_module/utils");


exports.shortenUrl = function (req, res) {
    apiUsage.shortenUrl(req, (err, response) => {
        if (err) {
            res.status(err.code ? err.code : 500).send(err)
        } else {
            res.status(response.code).send({"shortUrl": response.shortUrl, "longUrl": response.longUrl})
        }
    })
}

exports.redirectUsingShortUrl = function (req, res) {
    apiUsage.redirectUsingShortUrl(req, (err, response) => {
        if (err || util.isNull(response)) {
            res.status(404).send('Resource not found')
        } else {
            res.redirect(response.longUrl)
        }
    })
}