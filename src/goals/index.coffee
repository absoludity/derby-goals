derby = require 'derby'
{get, view, ready} = derby.createApp module
derby.use(require '../../ui')


## ROUTES ##

start = +new Date()

get '/', (page) ->
  page.redirect '/goals/example_goal/'

get '/goals/:goalId?/', (page, model, {goalId}) ->
  subgoalsForGoalQuery = model.query('goals').subgoalsForGoal(goalId)
  model.subscribe "goals.#{goalId}", subgoalsForGoalQuery, (error, goal, subgoals) ->
    model.ref '_goal', goal
    subgoalIds = goal.at 'subgoalIds'

    goal.setNull 'description', "Use this space to add a sentence or two outlining <em>why</em> this goal or task is important to you, so you can re-evaluate it in the future."
    goal.setNull 'title', "I want to edit this goal title"

    model.refList '_subgoalList', 'goals', subgoalIds

    page.render
      goalId: goalId


## CONTROLLER FUNCTIONS ##

ready (model) ->
  # This will need to be scoped to a particular goal or user.
  goalList = model.at '_subgoalList'
  newGoal = model.at '_newGoal'

  @addGoal = ->
    return unless goalTitle = view.escapeHtml newGoal.get()
    newGoal.set ''
    goalList.insert 0, {title: goalTitle, parentGoal: model.get '_goal.id'}


  # Tell Firefox to use elements for styles instead of CSS
  # See: https://developer.mozilla.org/en/Rich-Text_Editing_in_Mozilla
  document.execCommand 'useCSS', false, true
  document.execCommand 'styleWithCSS', false, false
