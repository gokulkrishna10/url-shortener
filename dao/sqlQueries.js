//----------------------Usage Queries-------------------------
module.exports.GET_DAILY_USAGE_WITH_ENDPOINTS_QUERY = `SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ? 
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
GROUP BY Date, APIVersion, EndpointName, APIName`;
module.exports.GET_DAILY_USAGE_WO_ENDPOINTS_QUERY = `SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
GROUP BY Date, APIVersion, APIName`;




module.exports.GET_DAILY_USAGE_WITH_ENDPOINTS_AND_API_NAME_QUERY = `SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ? and DisplayName = ? 
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
GROUP BY Date, APIVersion, EndpointName`;
module.exports.GET_DAILY_USAGE_WO_ENDPOINTS_AND_API_NAME_QUERY = `SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ? and DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
GROUP BY Date, APIVersion`;




module.exports.GET_MONTHLY_USAGE_WITH_ENDPOINTS_QUERY = `SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ? 
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
GROUP BY Month, APIVersion, EndpointName, APIName`;
module.exports.GET_MONTHLY_USAGE_WO_ENDPOINTS_QUERY = `SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
GROUP BY Month, APIVersion, APIName`;




module.exports.GET_MONTHLY_USAGE_WITH_ENDPOINTS_AND_API_NAME_QUERY = `SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ? and DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
GROUP BY Month, APIVersion, EndpointName`;
module.exports.GET_MONTHLY_USAGE_WO_ENDPOINTS_AND_API_NAME_QUERY = `SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ? and DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
GROUP BY Month, APIVersion`;




module.exports.GET_YEARLY_USAGE_WITH_ENDPOINTS_QUERY = `SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ? 
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
GROUP BY Year, APIVersion, EndpointName, APIName`;
module.exports.GET_YEARLY_USAGE_WO_ENDPOINTS_QUERY = `SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
GROUP BY Year, APIVersion, APIName`;




module.exports.GET_YEARLY_USAGE_WITH_ENDPOINTS_AND_API_NAME_QUERY = `SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ? and DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
GROUP BY Year, APIVersion, EndpointName`;
module.exports.GET_YEARLY_USAGE_WO_ENDPOINTS_AND_API_NAME_QUERY = `SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where APIKey = ? and DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
GROUP BY Year, APIVersion`;


//----------------------Error Queries-------------------------
module.exports.GET_ERRORS_WITH_DETAILS = `SELECT DATE_FORMAT(RequestDate,"%Y-%m-%d %H:%i:%s") as DateTime, an.DisplayName as APIName , APIVersion, EndpointName, HttpStatusCode, ae.ErrorId, ae.ErrorMessage
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where APIKey = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
LIMIT ?`;
module.exports.GET_ERRORS_WITH_DETAILS_AND_API_NAME_QUERY = `SELECT DATE_FORMAT(RequestDate,"%Y-%m-%d %H:%i:%s") as DateTime, an.DisplayName as APIName , APIVersion, EndpointName, HttpStatusCode, ae.ErrorId, ae.ErrorMessage
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where APIKey = ? and DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
LIMIT ?`;




module.exports.GET_DAILY_ERROR_COUNT = `SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where APIKey = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
GROUP BY Date, APIVersion, APIName`;
module.exports.GET_DAILY_ERROR_COUNT_AND_API_NAME_QUERY = `SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where APIKey = ? and DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
GROUP BY Date, APIVersion`;




module.exports.GET_MONTLY_ERROR_COUNT = `SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where APIKey = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
AND au.APIErrorId IS NOT NULL
GROUP BY Month, APIVersion, APIName`;
module.exports.GET_MONTLY_ERROR_COUNT_AND_API_NAME_QUERY = `SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where APIKey = ? and DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
AND au.APIErrorId IS NOT NULL
GROUP BY Month, APIVersion`;




module.exports.GET_YEARLY_ERROR_COUNT = `SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where APIKey = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
GROUP BY Year, APIVersion, APIName`;
module.exports.GET_YEARLY_ERROR_COUNT_AND_API_NAME_QUERY = `SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where APIKey = ? and DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
GROUP BY Year, APIVersion`;




module.exports.GET_DAILY_ADMIN_USAGE_WITH_ENDPOINTS_QUERY = `SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where an.DisplayName = ? 
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
GROUP BY Date, APIVersion, EndpointName`;
module.exports.GET_DAILY_ADMIN_USAGE_WO_ENDPOINTS_QUERY = `SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where an.DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
GROUP BY Date, APIVersion`;




module.exports.GET_MONTHLY_ADMIN_USAGE_WITH_ENDPOINTS_QUERY = `SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where an.DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
GROUP BY Month, APIVersion, EndpointName`;
module.exports.GET_MONTHLY_ADMIN_USAGE_WO_ENDPOINTS_QUERY = `SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where an.DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s")  
GROUP BY Month, APIVersion`;




module.exports.GET_YEARLY_ADMIN_USAGE_WITH_ENDPOINTS_QUERY = `SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where an.DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
GROUP BY Year,  APIVersion, EndpointName`;
module.exports.GET_YEARLY_ADMIN_USAGE_WO_ENDPOINTS_QUERY = `SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, Count(*) as Count 
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
where an.DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
GROUP BY Year, APIVersion`;




module.exports.GET_DAILY_ADMIN_ERROR_COUNT = `SELECT DATE(RequestDate) as Date, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where an.DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
GROUP BY Date, APIVersion`;
module.exports.GET_MONTLY_ADMIN_ERROR_COUNT = `SELECT DATE_FORMAT(RequestDate,'%M %Y') AS Month, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where an.DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
GROUP BY Month, APIVersion`;
module.exports.GET_YEARLY_ADMIN_ERROR_COUNT = `SELECT YEAR(RequestDate) AS Year, an.DisplayName as APIName , APIVersion, EndpointName, Count(*) as Count
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where an.DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
GROUP BY Year, APIVersion`;



module.exports.GET_ERRORS_ADMIN_WITH_DETAILS = `SELECT DATE_FORMAT(RequestDate,"%Y-%m-%d %H:%i:%s") as DateTime, an.DisplayName as APIName , APIVersion, EndpointName, HttpStatusCode, ae.ErrorId, ae.ErrorMessage
FROM APIUsage au
JOIN APIName an on au.APINameId = an.APINameId
JOIN APIError ae on ae.APIErrorId = au.APIErrorId
where an.DisplayName = ?
AND (RequestDate) >= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND (RequestDate)<= DATE_FORMAT(?,"%Y-%m-%d %H:%i:%s") 
AND au.APIErrorId IS NOT NULL
LIMIT ?`;

