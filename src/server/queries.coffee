module.exports = (store) ->
  store.query.expose 'goals', 'subgoalsForGoal', (goalId) ->
    @where('parentGoal').equals(goalId)
