exports = module.exports = Unauthorized;
const { v4: uuidv4 } = require('uuid');

function Unauthorized(msg) {
    this.status = 'Failure';
    this.code = 401;
    this.errorId = uuidv4();
    this.error = [{
        "type": "UnauthorizedAccess",
        "message": "Please try with correct credentials"
    }];

    if (msg && msg instanceof String || typeof (msg) === 'string') {
        console.log(msg)
        this.error[0].message = msg;
    } else if (msg) {
        this.error[0].message = msg;
    }
    Error.call(this, msg);
    Error.captureStackTrace(this, arguments.callee);
    return this;
}
