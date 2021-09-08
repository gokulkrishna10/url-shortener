const apiUsage = require('../controllers/apiUsageController')

exports.updateAPIUsage = (req, res) => {
    apiUsage.updateAPIUsage(req, res, (err, response) => {
        if (err) {
            console.log("updateAPIUsage failed >" + JSON.stringify(err))
            res.send(err.msg).status(err.code)
        } else {
            console.log("updateAPIUsage succeeded")
            if (!req.isValidationError)
                res.send(response).status(202)
        }
    })
}