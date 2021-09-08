exports = module.exports = BadSession;
const { v4: uuidv4 } = require('uuid');

function BadSession(msg) {
    this.status = 'Failure';
    this.code = 401;
    this.errorId = uuidv4();
    this.error = [{
        "type": "InvalidSession",
        "message": "Invalid Session"
    }];

    if (msg && msg instanceof String || typeof (msg) === 'string') {
        this.error[0].message = msg;
    } else if (msg) {
        this.error = msg;
    }

    Error.call(this, msg);
    Error.captureStackTrace(this, arguments.callee);
    return this;
}
