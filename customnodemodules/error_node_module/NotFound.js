exports = module.exports = NotFound;
const { v4: uuidv4 } = require('uuid');

function NotFound(msg) {
    this.status = 'Failure';
    this.code = 404;
    this.errorId = uuidv4();
    this.error = [{
        "type": "NotFound",
        "message": "Requested resource does not exist"
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
