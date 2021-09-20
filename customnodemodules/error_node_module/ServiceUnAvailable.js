exports = module.exports = ServiceUnAvailable;
const { v4: uuidv4 } = require('uuid');

function ServiceUnAvailable(msg) {
    this.status = 'Failure';
    this.code = 503;
    this.errorId = uuidv4();
    this.error = [{
        "type": "ServiceUnavailable",
        "message": "Requested Service Unavailable"
    }];

    if (msg && msg instanceof String || typeof (msg) === 'string') {
        this.error[0].message = msg;
    } else if (msg) {
        this.msg = msg;
    }


    Error.call(this, msg);
    Error.captureStackTrace(this, arguments.callee);
    return this;
}
