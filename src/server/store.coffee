derby = require 'derby'
server = require './index'
nconf = require 'nconf'

mongo_url = nconf.get 'mongo-url'
if mongo_url
	derby.use require('racer-db-mongo')
	module.exports = store = derby.createStore
		listen: server
		db:
			type: 'Mongo'
			uri: mongo_url
else
	module.exports = store = derby.createStore
		listen: server
