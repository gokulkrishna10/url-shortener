const {environment} = require('../../../environments');

var rds_host = environment.RDS_HOST
var rds_user = environment.RDS_USER
var rds_password = environment.RDS_PASSWORD
var rds_data_base = environment.RDS_SCHEMA
var rds_no_of_connections = environment.RDS_NO_OF_CONNECTIONS
var rds_connections_timeout = environment.RDS_CONNECTION_TIMEOUT
var rds_failover_no_of_connection = environment.RDS_FAILOVER_NO_OF_CONNECTIONS

exports.rds_host = rds_host;
exports.rds_user = rds_user;
exports.rds_password = rds_password;
exports.rds_data_base = rds_data_base;
exports.rds_no_of_connections = rds_no_of_connections;
exports.rds_connections_timeout = rds_connections_timeout;
exports.rds_failover_no_of_connection = rds_failover_no_of_connection;
