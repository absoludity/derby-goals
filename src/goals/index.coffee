derby = require 'derby'
{get, view, ready} = derby.createApp module
derby.use(require 'derby-ui-boot', {'styles': ['bootstrap', 'tabs']})
derby.use(require '../../ui')
goalHelpers = require './helpers'

get '/', (page) ->
    page.redirect '/goals/example_goal/'

get '/goals/:goalId?/', (page, model, {goalId}) ->
    subgoalsForGoalQuery = model.query('goals').subgoalsForGoal(goalId)
    goalReviewsQuery = model.query('reviews').reviewsForGoal(goalId)
    model.subscribe "goals.#{goalId}", subgoalsForGoalQuery, goalReviewsQuery, (error, goal, subgoals, reviews) ->
        goalHelpers.initSelectOptions(goal)
        model.ref '_goal', goal
        goalHelpers.setGoalDefaults(goal)
        subgoalIds = goal.at 'subgoalIds'
        model.refList '_subgoalList', 'goals', subgoalIds

        model.ref '_goal._goalsTodo', model.filter('_subgoalList')
            .where('status').equals('todo')
        model.ref '_goal._goalsInProgress', model.filter('_subgoalList')
            .where('status').equals('inprogress')
        model.ref '_goal._goalsDone', model.filter('_subgoalList')
            .where('status').equals('done')
        model.ref '_goal._goalsBacklog', model.filter('_subgoalList')
            .where('status').equals('backlog')

        model.ref '_reviewList', reviews
        model.ref '_sortedReviewList', reviews.sort(['timestamp', 'desc'])

        page.render 'goal'


ready (model) ->
  subGoalList = model.at '_subgoalList'
  newGoal = model.at '_newGoal'
  currentGoal = model.at '_goal'
  newReview = model.at '_newReview'
  reviewList = model.at '_reviewList'

  @addGoal = ->
    return unless goalTitle = view.escapeHtml newGoal.get()
    newGoal.set ''
    defaults = goalHelpers.makeGoalDefaults()
    numTodos = currentGoal.at('_goalsTodo').get().length
    if numTodos > 1
        defaults.status = 'backlog'
    defaults.title = goalTitle
    defaults.parentGoal = currentGoal.get('id')

    subGoalList.push defaults

  @expandDetails = ->
      model.set '_goal._expandDetails', !Boolean(model.get('_goal._expandDetails'))

  @expandDBacklog = ->
      model.set '_goal._expandBacklog', !Boolean(model.get('_goal._expandBacklog'))

  @addReview = ->
      return unless progressComment = view.escapeHtml newReview.get()
      newReview.set ''
      progressDate = new Date()
      reviewList.unshift {
          comment: progressComment,
          timestamp: progressDate,
          goalId: currentGoal.get('id')
      }

  currentGoal.on('set', 'reviewPeriod', (newValue, oldValue) ->
    oldNextReview = new Date(currentGoal.get('nextReview'))
    currentGoal.set 'nextReview', (new Date(oldNextReview.getTime() + (newValue - oldValue) * goalHelpers.MS_PER_DAY)).toISOString()
  )

  @goalDragStart = (e) ->
    e.target.classList.add 'dragging'
    goal = model.at(e.target)
    e.dataTransfer.setData 'text/plain', goal.get('id')

  @goalDragEnd = (e) ->
    e.target.classList.remove 'dragging'

  @dragEnter = (e) ->
      e.target.classList.add 'over'

  @dragOver = (e) ->
      e.preventDefault() if e.preventDefault
      e.dataTransfer.dropEffect = 'move'

  @dragLeave = (e) ->
      e.target.classList.remove 'over'

  @goalDrop = (e) ->
      classList = e.target.classList
      classList.remove 'over'
      goalId = e.dataTransfer.getData('text/plain')
      [].forEach.call ['todo', 'inprogress', 'done', 'backlog'], (status) ->
          if classList.contains status
              model.set "goals." + goalId + ".status", status
              return
