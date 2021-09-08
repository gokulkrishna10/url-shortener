/**
 * Created by Avinash on 01/04/19.
 */

var ErrorMode = require("../error_node_module/errors");
var errors = new ErrorMode();
const {v1: uuidv1} = require('uuid');
exports.uuid = uuidv1();
exports.getJson = function getJson(result) {
    if (result instanceof String || typeof (result) === "string") {
        result = JSON.parse(result);
    }
    return result;
};

exports.addIfDefined = function addIfDefined(Obj, name, prop, isBoolean) {
    if ((prop && typeof prop != "undefined") || prop == 0) {
        if (isBoolean == true) {
            if (prop == 0) {
                Obj[name] = false;
            } else if (prop == 1) {
                Obj[name] = true;
            }
        } else {
            Obj[name] = prop;
        }

    }
};

exports.addInAllCases = function addInAllCases(Obj, name, prop, isBoolean) {
    if (isBoolean == true) {
        if (prop == 0) {
            Obj[name] = false;
        } else if (prop == 1) {
            Obj[name] = true;
        }
    } else {
        Obj[name] = prop;
    }
};

exports.isError = function isError(error) {
    return !exports.isEmpty(error);
};

exports.isValidResponse = function isValidResponse(err, results) {
    return exports.isNull(err) && exports.isNotEmpty(results);
};

exports.isNull = function isNull(item) {
    return item == null || item == "" || typeof item == "undefined";
};

exports.isNotNull = function isNotNull(item) {
    return item != null && item != "" && typeof item != "undefined";
};

exports.isNotEmpty = function isNotEmpty(item) {
    return item != null && item != "" && typeof item != "undefined" && item.length > 0;
};

exports.isValidDate = function isValidDate(date) {
    var result = new Date(date);
    if (result === "Invalid Date") return false;
    return true;
};

exports.groupByKey = function groupByKey(result, key) {
    var groupBy = function (xs, key) {
        return xs.reduce(function (rv, x) {
            (rv[x[key]] = rv[x[key]] || []).push(x);
            return rv;
        }, {});
    };

    return groupBy(result, key);
};

exports.groupByCompositeKey = function groupByCompositeKey(result, key1, key2, key3, key4, key5) {

    var groupBy = function (xs, key1, key2, key3, key4, key5) {
        return xs.reduce(function (rv, x) {
            (rv[x[key1] + x[key2] + x[key3] + x[key4] + x[key5]] = rv[x[key1] + x[key2] + x[key3] + x[key4] + x[key5]] || []).push(x);
            return rv;
        }, {});
    };

    return groupBy(result, key1, key2, key3, key4, key5);
};

exports.dateFormate = function dateFormate(date, format) {
    //returns date in MM/DD/YYYY formate
    var converDate = new Date();
    if (date) {
        converDate = date;
    }
    var dateObj = new Date(converDate);
    var month = dateObj.getUTCMonth();
    var day = dateObj.getUTCDate();
    var year = dateObj.getUTCFullYear();
    if (format && format === "YYMMDD") {
        return "" + year + "/" + month + "/" + day + "";
    } else if (format && format === "DDMMYY") {
        return "" + (day + 1) + "/" + (month + 1) + "/" + year + "";
    } else if (format && format === "DD_MM_YY") {
        return "" + day + "_" + (month + 1) + "_" + year + "";
    } else {
        return "" + month + "/" + day + "/" + year + "";
    }

};

exports.validateRequestInput = function (reportInputs, validateWith) {
    var error;

    for (var key in validateWith) {
        if (reportInputs.hasOwnProperty(validateWith[key]) && this.isNull(reportInputs.hasOwnProperty(validateWith[key]))) {
            error = errors.BadRequest("Invalid " + validateWith[key] + " Input");
            return error;
        }
    }
};

exports.findArrayObjectByKeyValue = function (array, key, value) {
    for (var i = 0; i < array.length; i++) {
        if (array[i][key] === value) {
            return array[i];
        }
    }
    return null;
};

exports.findByMatchingProperties = function (set, properties) {
    return set.filter(function (entry) {
        return Object.keys(properties).every(function (key) {
            return entry[key] === properties[key];
        });
    });
};

exports.getKeyValueFromObject = function (object, key) {

    if (object[key]) {
        return object[key];
    }
    return null;
};

exports.renameProperty = function (object, oldKeyNames, newKeyNames) {

    var newObject = {};
    for (var i in object) {

        if (object.hasOwnProperty(i) && this.getKeyValueFromObject(newKeyNames, i)) {
            newObject[this.getKeyValueFromObject(newKeyNames, i)] = object[i];
        }
    }
    return newObject;
};

exports.arrayToCommaString = function (input) {
    var string = "";
    for (var i = 0; i < input.length; i++) {
        if (i === input.length - 1) {
            string = string + input[i] + "";
        } else {
            string = string + input[i] + ",";
        }
    }
    return string;
};

exports.arrayToTabString = function (input) {
    var string = "";
    for (var i = 0; i < input.length; i++) {
        if (i === input.length - 1) {
            string = string + input[i] + "";
        } else {
            string = string + input[i] + "\t";
        }
    }
    return string;
};

exports.objectToCommaString = function (input) {
    var string = "";
    for (var key in input) {
        string = string + input[key] + ",";
    }
    return string;
};
exports.objectToTabString = function (input) {
    var string = "";
    for (var i in input) {
        string = string + input[i] + "\t";
    }
    return string;
};

exports.valuePresentInArray = function (array, value) {
    var present = false;
    if (this.isNotNull(array) && (array instanceof Array && array.indexOf(value) > -1)) {
        return true;
    }
    return present;
};

exports.getFirstDateOfMonth = function (mm, yyyy) {
    return (new Date((new Date(yyyy, mm, 1))));
};

exports.getLastDateOfMonth = function (mm, yyyy) {
    return (new Date((new Date(yyyy, mm + 1, 1)) - 1));
};

exports.getTimeInms = function () {
    var currentDate = new Date();
    return currentDate.getTime();
};

exports.getLastMonthAndYear = function () {
    var d = new Date();
    d.setMonth(d.getMonth(), 0);
    return [d.getMonth(), d.getFullYear()];
};

exports.replaceByMatchingProperties = function (set, properties, ignoreValues, defaultValue) {
    delete properties[ignoreValues];
    var res = set.filter(function (entry) {
        return Object.keys(properties).every(function (key) {
            if (entry[key] === properties[key]) {
                properties[ignoreValues] = entry[ignoreValues];
                return entry[ignoreValues];
            } else {
                return defaultValue;
            }
        });
    });
    if (this.isNotEmpty(res)) {
        return res[0];
    } else {
        properties[ignoreValues] = defaultValue;
        return properties;
    }
};

exports.replaceByMatchingPropertieswithKeys = function (set, properties, ignoreValues) {
    delete properties[ignoreValues];
    return set.filter(function (entry) {
        return Object.keys(properties).every(function (key) {
            return entry[key] === properties[key];
        });
    });
};

exports.uniqueArray = function (array) {
    var arr = [];
    for (var i = 0; i < array.length; i++) {
        if (arr.indexOf(array[i]) === -1) {
            if (array[i]) {
                arr.push(array[i]);
            }
        }
    }
    return arr;
};

exports.convertToTwoDigit = function convertToTwoDigit(n) {
    return n > 9 ? "" + n : "0" + n;
};

exports.getSeconds = function (oldDate, newDate) {
    if (newDate === undefined || newDate === null) {
        newDate = new Date();
    }
    return Math.abs((new Date(newDate).getTime() - new Date(oldDate).getTime()) / 1000);
};

module.exports.dateConvert = (date) => {
    if (date.match(/\Date\(/g)) {
        return new Date(parseFloat(date.replace("/Date(", "").replace(")/", ""))).toUTCString();
    } else {
        return date;
    }
}

module.exports.dateCompare = (date1, date2, symbol) => {
    let firstDate = new Date(date1), secondDate = new Date(date2), val = false;
    if (symbol === "<") {
        if (firstDate.getTime() < secondDate.getTime())
            val = true;
    } else if(symbol === ">") {
        if (firstDate.getTime() > secondDate.getTime())
            val = true;
    } else if(symbol === "=") {
        if (firstDate.getTime() === secondDate.getTime())
            val = true;
    }
    return val;
}