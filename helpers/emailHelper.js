const {environment} = require('../environments')
const AWS = require('aws-sdk');
AWS.config.update({region: 'eu-west-1'});
const sqs = new AWS.SQS({apiVersion: '2012-11-05'});

var GENERIC_MAIL_META = {
    subject: 'Customer pricing data not found',
    previewText: 'Customer pricing data not found',
    acqPartyDisplayName: 'Labrador',
    acqPartyLogo: 'https://s3-eu-west-1.amazonaws.com/assets.dev.thelabrador.co.uk/email-assets/logo.png',
    buttoncolor: '#2196F3',
    subjectDummy: '',
    bodyText: "This is to inform that the Selling price per call is not found for the customer",
    campaign: 'generic-email',
    inManage: true,
    homePath: 'https://thelabrador.co.uk',
    assetsPath: 'https://assets.thelabrador.co.uk/email-assets',
    dashboardPath: 'https://dashboard.thelabrador.co.uk',
    livechatPath: 'https://thelabrador.co.uk?livechat',
    contactEmail: 'contact@perse.energy',
    contactPhone: '0800 060 8790',
    analyticsEndpoint: 'https://analytics.thelabrador.co.uk/prod',
    analyticsTid: 'UA-103774971-1',
    email: 'gokul.k@digitalapicraft.com',
    cc: 'gokul.k@digitalapicraft.com',
    emailType: {id: '656', string: 'GENERIC_MAIL'},
    showGas: false,
    uuid: 'f45b683b-c013-44f3-96a6-24a8332de298',
    currentYear: '2022'
}

exports.sendEmail = (missingParameterName, arguments) => {
    return new Promise((resolve, reject) => {
        const d1 = new Date();
        const timePortion = d1.getTime();
        let mainReceiver = (environment.ISSUE_EMAIL_RECIPIENTS.TO).split('@')
        let receiver1 = ((environment.ISSUE_EMAIL_RECIPIENTS.COPY).split(','))[0].split('@')

        GENERIC_MAIL_META.email = mainReceiver[0] + '+' + timePortion + '@' + mainReceiver[1];
        GENERIC_MAIL_META.cc = receiver1[0] + '+' + timePortion + '@' + receiver1[1];
        GENERIC_MAIL_META.subject = `[${environment.ENVIRONMENT_NAME}] ${missingParameterName} not found`;
        GENERIC_MAIL_META.previewText = `[${environment.ENVIRONMENT_NAME}] ${missingParameterName} not found`;
        GENERIC_MAIL_META.bodyText = `This is to inform that the Selling price for the requested input parameters was not found for the customer.
                                       \nRequestArguments : ${arguments}.`

        var message = {
            MessageBody: JSON.stringify(GENERIC_MAIL_META),
            QueueUrl: `https://sqs.eu-west-1.amazonaws.com/715059295415/lab-dev-sqs-emails`,
            MessageAttributes: {
                emailType: {DataType: 'String', StringValue: 'GENERIC_MAIL'}
            }
        }

        const promise1 = new Promise((resolved, rejected) => {
            sqs.sendMessage(message).promise().then(() => {
                resolved('email sent');
            }).catch((err) => {
                console.log(err)
                rejected('error');
            });
        })
        promise1
            .then(resp => {
                resolve({message: 'Email sent', Action: "Complete"});
            })
            .catch(err => {
                reject({message: 'Failed to send Email. Err: ' + err, Action: "Complete"});
            });
    })
};