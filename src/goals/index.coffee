derby = require 'derby'
{get, view, ready} = derby.createApp module
derby.use(require '../../ui')


## ROUTES ##

start = +new Date()

get '/', (page) ->
  page.redirect '/goals/example_goal/'

get '/goals/:goalId?/', (page, model, {goalId}) ->
  model.subscribe "goals.#{goalId}", (err, goal) ->
    model.ref '_goal', goal
    subgoalIds = goal.at 'subgoalIds'

    goal.setNull 'description', "Add a sentence or two outlining <em>why</em> this goal is important to you."
    goal.setNull 'title', "Give your goal a title"

    # Scope to goal.
    model.refList '_subgoalList', 'goals', subgoalIds

    # Render will use the model data as well as an optional context object
    page.render


## CONTROLLER FUNCTIONS ##

ready (model) ->
  # This will need to be scoped to a particular goal or user.
  goalList = model.at '_subgoalList'
  newGoal = model.at '_newGoal'

  @addGoal = ->
    return unless goalTitle = view.escapeHtml newGoal.get()
    newGoal.set ''
    goalList.insert 0, {title: goalTitle, parentGoal: model.get '_goal.id'}
