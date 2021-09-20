exports = module.exports = ConflictRequest;
const { v4: uuidv4 } = require('uuid');

function ConflictRequest(msg) {
    this.status = 'Failure';
    this.code = 409;
    this.errorId = uuidv4();
    this.error = [{
        "type": "Conflict",
        "message": "Conflict Request"
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
