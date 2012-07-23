module.exports = (store) ->
  store.query.expose 'goals', 'subgoalsForGoal', (goalId) ->
    @where('parentGoalId').equals(goalId)
