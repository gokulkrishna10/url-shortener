exports = module.exports = Forbidden;
const { v4: uuidv4 } = require('uuid');

function Forbidden(msg) {
    this.status = 'Failure';
    this.code = 403;
    this.errorId = uuidv4();
    this.error = [{
        "type": "Forbidden",
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
