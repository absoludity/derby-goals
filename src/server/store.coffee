derby = require 'derby'
server = require './index'
nconf = require 'nconf'

console.log('mongo-url: ' + nconf.get('mongo-url'))

derby.use require('racer-db-mongo')
module.exports = store = derby.createStore
    listen: server
    db: { type: 'Mongo', uri: nconf.get 'mongo-url' }
