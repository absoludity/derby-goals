derby = require 'derby'
{get, view, ready} = derby.createApp module
derby.use(require 'derby-ui-boot')
derby.use(require '../../ui')

MS_PER_DAY = 24 * 60 * 60 * 1000

initSelectOptions = (model) ->
    model.set '_statusChoices', ['todo', 'doing', 'done', 'backlog']
    model.set '_reviewPeriods', [
        {name: 'day', numDays: 1},
        {name: 'week', numDays: 7},
        {name: 'month', numDays: 30}
    ]

setGoalDefaults = (goal) ->
    defaults = makeGoalDefaults()
    goal.setNull 'description', defaults.description,
    goal.setNull 'title', defaults.title,
    goal.setNull 'status', defaults.status,
    goal.setNull 'lastReviewed', defaults.lastReviewed,
    goal.setNull 'reviewPeriod', defaults.reviewPeriod,
    goal.setNull 'nextReview', defaults.nextReview

makeGoalDefaults = () ->
    lastReviewed = new Date()
    return {
        description: "Use this space to add a sentence or two outlining <em>why</em> this goal or task is important to you, so you can re-evaluate it in the future.",
        title: "I want to edit this goal title",
        status: "todo",
        lastReviewed: lastReviewed,
        reviewPeriod: 7,
        nextReview: (new Date(lastReviewed.getTime() + 7 * MS_PER_DAY)).toISOString()
    }

get '/', (page) ->
  page.redirect '/goals/example_goal/'

get '/goals/:goalId?/', (page, model, {goalId}) ->
  subgoalsForGoalQuery = model.query('goals').subgoalsForGoal(goalId)
  model.subscribe "goals.#{goalId}", subgoalsForGoalQuery, (error, goal, subgoals) ->
    initSelectOptions(model)
    model.ref '_goal', goal
    setGoalDefaults(goal)
    subgoalIds = goal.at 'subgoalIds'
    model.refList '_subgoalList', 'goals', subgoalIds

    model.ref '_goal._goalsTodo', model.filter('_subgoalList')
        .where('status').equals('todo')

    # Why can't I load the reviews within the ready below (ie. they don't need
    # to be rendered initially).
    goalReviewsQuery = model.query('reviews').reviewsForGoal(goalId)
    model.subscribe goalReviewsQuery, (error, reviews) ->
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
    defaults = makeGoalDefaults()
    numTodos = currentGoal.at('_goalsTodo').get().length
    if numTodos > 1
        defaults.status = 'backlog'
    defaults.title = goalTitle
    defaults.parentGoal = currentGoal.get('id')

    subGoalList.push defaults

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
    currentGoal.set 'nextReview', (new Date(oldNextReview.getTime() + (newValue - oldValue) * MS_PER_DAY)).toISOString()
  )
