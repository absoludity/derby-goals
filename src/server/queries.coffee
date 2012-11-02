module.exports = (store) ->
    store.query.expose 'goals', 'subgoalsForGoal', (goalId) ->
        @where('parentGoal').equals(goalId)

    store.query.expose 'goals', 'goalsForUser', (userId) ->
        @where('userId').equals(userId)

    store.query.expose 'reviews', 'reviewsForGoal', (goalId) ->
        @where('goalId').equals(goalId)

    # Just for prototype, normal use would restrict to only
    # users who requestor is helping.
    store.query.expose 'users', 'allUsers', ->
        @users
