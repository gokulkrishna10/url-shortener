/**
 * Created by Malashree on 31/01/2020.
 */
exports = module.exports = errors;

var NotFound = require('./NotFound');
var BadSession = require('./BadSession');
var BadRequest = require('./BadRequest');
var CallFailed = require('./CallFailed');
var Unauthorized = require('./Unauthorized');
var ServiceUnAvailable = require('./ServiceUnAvailable');
var Forbidden = require('./Forbidden');
var dbError = require('./DataBaseError');
var ConflictRequest = require('./ConflictRequest');

function errors() {
    'use strict';
}

exports.error_handler = function error_handler(err, req, res) {
    console.error(err.stack);
    res.header('Content-Type', 'application/json; charset=utf-8');
    res.status(err.code || 500).send(JSON.stringify(err.msg, undefined, 2));
};

errors.prototype.NotFound = NotFound;
errors.prototype.ConflictRequest = ConflictRequest;
errors.prototype.BadRequest = BadRequest;
errors.prototype.BadSession = BadSession;
errors.prototype.CallFailed = CallFailed;
errors.prototype.Unauthorized = Unauthorized;
errors.prototype.ServiceUnAvailable = ServiceUnAvailable;
errors.prototype.dbError = dbError;

errors.prototype.Forbidden = Forbidden;
