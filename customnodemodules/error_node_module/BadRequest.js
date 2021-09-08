exports = module.exports = BadRequest;
const { v4: uuidv4 } = require('uuid');

function BadRequest(msg) {
    this.status = 'Failure';
    this.code = 400;
    this.errorId = uuidv4();
    this.error = [{
        "type": "InvalidRequest",
        "message": "Invalid Request"
    }];

    if (msg && msg instanceof String || typeof (msg) === 'string') {
        this.error.message = msg;
    } else if (msg) {
        this.error = msg;
    }

    Error.call(this, msg);
    Error.captureStackTrace(this, arguments.callee);
    return this;
}


function BadRequest(msg, displayName) {
    this.status = 'Failure';
    this.code = 400;
    this.errorId = uuidv4();
    this.error = [{
        "type": "Invalid_Request",
        "message": "Invalid Request",
    }];
    if (msg && msg instanceof String || typeof (msg) === 'string') {
        this.error[0].message = msg;
    } else if (msg) {
        this.error[0] = msg;
    }
    if(displayName){
        this.msg.displayErrorMsg = displayName;
    }
    Error.call(this, msg);
    Error.captureStackTrace(this, arguments.callee);
    return this;
}
