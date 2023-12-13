const util = require('../customnodemodules/util_node_module/utils')
const ErrorMod = require('../customnodemodules/error_node_module/errors')
const customError = new ErrorMod()
const validator = require('validator');


exports.validateInputUrl = function (req, res, next) {
    let err = null;
    let url = req.body.url

    if (util.isNull(url)) {
        err = customError.BadRequest("url is required");
        next(err)
    }
    if (!url.startsWith("https://") && !url.startsWith("http://")) {
        req.body.url = "http://" + url;
    }
    if (!validator.isURL(req.body.url)) {
        err = customError.BadRequest("Enter a valid url");
        next(err)
    }
    next()
}


exports.validateShortUrl = function (req, res, next) {
    let err = null
    if (util.isNull(req.params)) {
        err = customError.NotFound("URL is not found")
        next(err)
    }
    next()
}