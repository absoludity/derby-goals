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
    model.set('_statusChoices', ['todo', 'doing', 'done', 'backlog'])
    model.ref '_goal', goal
    subgoalIds = goal.at 'subgoalIds'

    goal.setNull 'description', "<p>Use this space to add a sentence or two outlining <em>why</em> this goal or task is important to you, so you can re-evaluate it in the future.</p>"
    goal.setNull 'title', "I want to edit this goal title"
    goal.setNull 'status', 'todo'
    goal.setNull 'reviewPeriod', 7

    model.refList '_subgoalList', 'goals', subgoalIds

    numTodo = 0
    numTodo++ for subgoal in subgoals when subgoal.status == 'todo'
    model.set('_numTodo', numTodo)

    page.render 'goal'

## CONTROLLER FUNCTIONS ##

ready (model) ->
  # This will need to be scoped to a particular goal or user.
  goalList = model.at '_subgoalList'
  newGoal = model.at '_newGoal'

  @addGoal = ->
    return unless goalTitle = view.escapeHtml newGoal.get()
    newGoal.set ''
    if model.get('_numTodo') > 1
        status = 'backlog'
    else
        status = 'todo'
        model.incr('_numTodo')
    goalList.push title: goalTitle, status: status, reviewPeriod: 7, parentGoal: model.get '_goal.id'
