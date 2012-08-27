module.exports = (store) ->
    store.query.expose 'goals', 'subgoalsForGoal', (goalId) ->
        @where('parentGoal').equals(goalId)

    store.query.expose 'reviews', 'reviewsForGoal', (goalId) ->
        @where('goalId').equals(goalId)
