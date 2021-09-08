exports = module.exports = DataBaseError;
const { v4: uuidv4 } = require('uuid');

function DataBaseError(InputError, customeMessage) {
    this.status = 'Failure';
    this.code = 500;
    this.errorId = uuidv4();
    this.error = [{
        "type": "Backend_Call_Failed",
        "message": "GET/Create/Update failed"
    }];

    switch (InputError.errno) {
        case 1054: //foreign key violation
            this.msg.error = InputError.code;
            this.msg.description = InputError.sqlMessage;
            break
        case 1452: //foreign key violation
            this.msg.description = InputError.sqlMessage;
        case 1169: //unique key constraint

            break;
        case 1062: //duplicate primary key
            if (err.message.indexOf('PRIMARY') > -1) {
            }
            break;
        default:
            this.msg.description = "GET/Create/Update failed";
    }

    Error.call(this, InputError);
    Error.captureStackTrace(this, arguments.callee);
    return this;
}






