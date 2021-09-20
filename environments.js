const {stage} = require('./env.json')
const config = require('./config')

const environment = Object.freeze(config[stage]);

module.exports = {
    environment
}
