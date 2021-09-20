exports = module.exports = CallFailed;
const { v4: uuidv4 } = require('uuid');

function CallFailed(msg) {
    this.status = 'Failure';
    this.code = 500;
    this.errorId = uuidv4();
    this.error = [{
        "type": "Backend_Call_Failed",
        "message": "Requested api call has failed"
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
