const constants = require('../constants/constants')
const crypto = require('crypto')
const config = require('../config.json')
const envFile = require('../env.json')

function generateRandomString(length, chars) {
    let result = '';
    for (let i = length; i > 0; --i) result += chars[Math.floor(Math.random() * chars.length)];
    return result;
}

function getHashForUrl(longUrl) {
    return crypto.createHash('sha1').update(longUrl).digest('hex');
}


exports.requestUrlMapping = function (longUrl) {
    let requestUrlObject = {}

    requestUrlObject['urlHash'] = getHashForUrl(longUrl)
    requestUrlObject.token = generateRandomString(constants.randomTokenLength, constants.alphaNumericChars)
    requestUrlObject.longUrl = longUrl
    requestUrlObject.shortUrl = constants.shortUrlBase + requestUrlObject.token

    return requestUrlObject
}

exports.responseUrlMapping = function (longUrl, shortUrl) {
    let responseUrlObject = {}

    responseUrlObject.longUrl = longUrl
    responseUrlObject.shortUrl = config[envFile.stage]["SERVER_PROTOCOL_WITH_SUBDOMAIN"] + shortUrl
    responseUrlObject.code = constants.created

    return responseUrlObject
}


exports.generateRandomString = generateRandomString
exports.getHashForUrl = getHashForUrl