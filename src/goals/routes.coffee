{get} = require './index'
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

        page.render 'goals'

get '/users/:userId?/', (page, model, {userId}) ->
	goalsForUserQuery = model.query('goals').goalsForUser(userId)
	model.subscribe "users.#{userId}", goalsForUserQuery, (error, goals) ->
		model.ref '_goals', goals
		page.render 'users'
