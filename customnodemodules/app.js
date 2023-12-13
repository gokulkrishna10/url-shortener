const mysql = require("mysql2");
const rdsConfigVal = require("../customnodemodules/project_config/rds_config/rdsconfig");

const read_connection = mysql.createConnection({
    host: rdsConfigVal.rds_host,
    user: rdsConfigVal.rds_user,
    password: rdsConfigVal.rds_password,
    database: rdsConfigVal.rds_data_base,
    connectionLimit: rdsConfigVal.rds_no_of_connections,
    debug: false,
    //acquireTimeout: rdsConfigVal.rds_connections_timeout,
    waitForConnections: true,
    connectTimeout: rdsConfigVal.rds_connections_timeout
});

const read_pool = mysql.createPool({
    connectionLimit: rdsConfigVal.rds_no_of_connections,
    host: rdsConfigVal.rds_host,
    user: rdsConfigVal.rds_user,
    password: rdsConfigVal.rds_password,
    database: rdsConfigVal.rds_data_base,
    debug: false,
    //acquireTimeout: rdsConfigVal.rds_connections_timeout,
    waitForConnections: true,
    connectTimeout: rdsConfigVal.rds_connections_timeout
});


const failover_read_pool = mysql.createPool({
    connectionLimit: rdsConfigVal.rds_no_of_connections,
    host: rdsConfigVal.rds_host,
    user: rdsConfigVal.rds_user,
    password: rdsConfigVal.rds_password,
    database: rdsConfigVal.rds_data_base,
    debug: false,
    //acquireTimeout: rdsConfigVal.rds_connections_timeout,
    waitForConnections: true,
    connectTimeout: rdsConfigVal.rds_failover_no_of_connection
});

function sleep(ms) {
    return new Promise(
        resolve => setTimeout(resolve, ms)
    );
}

function pingService(conn) {
    conn.ping(pingErr => {
        if (pingErr) {
            return pingErr;
        } else {
            return false;
        }
    })
}


function getReadConnection(callback) {
    read_pool.getConnection(async (err, conn) => {
        if (err) {
            console.log(err);
            await sleep(500);
            getFailoverReadConnection(async (failOverErr, failOverConn) => {
                if (failOverErr) {
                    console.log(failOverErr);
                    callback(failOverErr, null)
                } else {
                    let pingFlag = pingService(failOverConn);
                    if (pingFlag) {
                        console.log(pingFlag)
                        await sleep(500);
                        callback(pingFlag, null)
                    } else {
                        callback(null, failOverConn);
                    }
                }
            })
        } else {
            let pingFlag = pingService(conn)
            if (pingFlag) {
                console.log(pingFlag)
                await sleep(500);
                getFailoverReadConnection(async (failOverErr, failOverConn) => {
                    if (failOverErr) {
                        console.log(failOverErr);
                        callback(failOverErr, null)
                    } else {
                        let pingFlagFail = pingService(failOverConn)
                        if (pingFlagFail) {
                            console.log(pingFlagFail)
                            await sleep(500);
                            callback(pingFlagFail, null)
                        } else {
                            callback(null, failOverConn);
                        }
                    }
                })
            } else {
                callback(null, conn);
            }
        }
    });
}

function getFailoverReadConnection(callback) {
    failover_read_pool.getConnection(async (err, conn) => {
        if (err) {
            await sleep(500);
            read_connection.connect();
            let pingFlag = pingService(read_connection)
            if (pingFlag) {
                console.log(pingFlag)
                callback(pingFlag, null)
            } else {
                callback(null, read_connection);
            }
        } else {
            let pingFlag = pingService(conn)
            if (pingFlag) {
                console.log(pingFlag);
                await sleep(500);
                read_connection.connect();
                let pingFlagRead = pingService(read_connection)
                if (pingFlagRead) {
                    console.log(pingFlagRead)
                    callback(pingFlagRead, null)
                } else {
                    callback(null, read_connection);
                }
            } else {
                callback(null, conn);
            }
        }
    });
}


exports.getReadConnection = getReadConnection;


/*** to Use for GET requests */

exports.queryWithParams = function (string, params, callback) {
    getReadConnection(function (err, con) {
        if (err) {
            callback(err, null);
        } else {
            con.query(string, params, function (err, rows) {
                releaseConnection(con);

                if (err) {
                    callback(err, null);
                } else {
                    callback(null, rows);
                }
            });
        }
    });
};


/*** to Use for GET requests */

exports.queryWithOptions = function (options, callback) {

    getReadConnection(function (err, con) {
        if (err) {
            callback(err, null);
        } else {
            con.query(options, function (err, rows) {
                releaseConnection(con);

                if (err) {
                    callback(err, null);
                } else {
                    callback(null, rows);
                }
            });
        }
    });
};


/*** to Use for POST,PUT, DELETE requests */

exports.executeWithParams = function (string, params, callback) {
    getFailoverReadConnection(function (err, con) {
        if (err) {
            callback(err, null);
        } else {
            con.query(string, params, function (err, rows) {

                releaseConnection(con);

                if (err) {
                    callback(err, null);
                } else {
                    callback(null, rows);
                }
            });
        }
    });
};

/*** to Use for POST,PUT,DELETE requests */

exports.executeWithOptions = function (options, callback) {
    getWriteConnection(function (err, con) {
        if (err) {
            callback(err, null);
        } else {
            con.query(options, function (err, rows) {

                releaseConnection(con);

                if (err) {
                    callback(err, null);
                } else {
                    callback(null, rows);
                }
            });
        }
    });
};

/** Multiple sequeneced updates/inserts with/without transaction support */

exports.executeMultipleWithOptions = function (mOptions, isTransaction, callback) {

    if (!mOptions || (!(mOptions instanceof Array)) || mOptions.length <= 0) {
        callback(null, null);
    } else {
        getReadConnection(function (err, con) {
            if (err) {
                callback(err, null);
            } else {
                if (isTransaction) {
                    con.beginTransaction(function (err) {
                        if (err) {
                            callback(err, null);
                        } else {
                            var resultList = new Array(mOptions.length);
                            executeSequencedQuery(mOptions, 0, con, resultList, function (err) {
                                if (err) {
                                    rollbackTransaction(con, err, callback);
                                } else {
                                    commitTransaction(con, resultList, callback);
                                }
                            });


                        }

                    });
                } else {
                    var resultList = new Array(mOptions.length);
                    executeSequencedQuery(mOptions, 0, con, resultList, function (err) {
                        releaseConnection(con);
                        if (err) {
                            callback(err, null);
                        } else {
                            callback(null, resultList);

                        }
                    });


                }

            }
        });
    }

};

exports.escape = mysql.escape;


function rollbackTransaction(con, err, callback) {
    con.rollback(function () {
        releaseConnection(con);
        callback(err, null);
    });
}

function commitTransaction(con, result, callback) {
    con.commit(function (err) {
        if (err) {
            rollbackTransaction(con, err, callback);
        } else {
            try {
                con.release();
            } catch (e) {
            }
            callback(null, result);
        }

    });
}

function releaseConnection(con) {

    try {
        con.release();
    } catch (e) {
    }
}

function executeSequencedQuery(mOptions, i, con, resultList, callback) {

    var options = mOptions[i];
    con.query(options, function (err, rows) {
        if (err) {
            callback(err);
        } else {
            resultList[i] = rows;
            if ((i + 1) < mOptions.length) {
                executeSequencedQuery(mOptions, i + 1, con, resultList, function (err) {
                    if (err) {
                        callback(err);
                    } else {
                        callback(null);
                    }
                });
            } else {
                callback(null);
            }
        }
    });

}

exports.customeTransactions = function (mOptions, transactionOpt, callback) {

    if (!mOptions || (!(mOptions instanceof Array)) || mOptions.length <= 0) {
        callback(null, null);
    } else {
        getWriteConnection(function (err, con) {
            if (err) {
                callback(err, null);
            } else {
                con.beginTransaction(function (err) {
                    if (err) {
                        callback(err, null);
                    } else {
                        var resultList = new Array(mOptions.length);
                        executeSequencedQueryForCustome(mOptions, 0, con, resultList, transactionOpt, function (err) {
                            if (err) {
                                rollbackTransaction(con, err, callback);
                            } else {
                                commitTransaction(con, resultList, callback);
                            }
                        });


                    }

                });
            }
        });
    }

};

function executeSequencedQueryForCustome(mOptions, i, con, resultList, transactionOpt, callback) {

    var options = mOptions[i];
    if (transactionOpt && transactionOpt.length > 0) {
        transactionOpt.forEach(function (singleObject) {
            if (singleObject.ResultForQuery === i) {
                options.values.push(resultList[singleObject.ResultFromQuery].insertId)
            }
        });
    }
    con.query(options, function (err, rows) {
        if (err) {
            callback(err);
        } else {
            resultList[i] = rows;
            if ((i + 1) < mOptions.length) {
                executeSequencedQueryForCustome(mOptions, i + 1, con, resultList, transactionOpt, function (err) {
                    if (err) {
                        callback(err);
                    } else {
                        callback(null);
                    }
                });
            } else {
                callback(null);
            }
        }
    });

}
