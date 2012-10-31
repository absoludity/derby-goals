derby = require 'derby'

module.exports =
    middleware: (request, result, next) ->
        checkUser(request.getModel())
        next()

checkUser = (model) ->
    session = model.session
    unless session.userId
        session.userId = derby.uuid()
        model.set "users.#{session.userId}", {auth:{}}
    model.set "_sessionUserId", session.userId
