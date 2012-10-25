derby = require 'derby'
{get, view, ready} = derby.createApp module
derby.use(require 'derby-ui-boot', {'styles': ['bootstrap', 'tabs']})
derby.use(require '../../ui')

require './routes'

require './controller'
