{get} = require './index'
goalHelpers = require './helpers'

get '/', (page, model) ->
    sessionUserId = model.at '_sessionUserId'
    page.redirect "/users/#{sessionUserId.get()}/"

get '/goals/:goalId?/', (page, model, {goalId}) ->
    subgoalsForGoalQuery = model.query('goals').subgoalsForGoal(goalId)
    goalReviewsQuery = model.query('reviews').reviewsForGoal(goalId)
    model.subscribe "goals.#{goalId}", subgoalsForGoalQuery, goalReviewsQuery, (error, goal, subgoals, reviews) ->
        goalHelpers.initSelectOptions(goal)
        model.ref '_goal', goal
        goalHelpers.setGoalDefaults(goal)
        subgoalIds = goal.at 'subgoalIds'
        model.refList '_goalList', 'goals', subgoalIds

        model.ref '_goalsTodo', model.filter('_goalList')
            .where('status').equals('todo')
        model.ref '_goalsInProgress', model.filter('_goalList')
            .where('status').equals('inprogress')
        model.ref '_goalsDone', model.filter('_goalList')
            .where('status').equals('done')
        model.ref '_goalsBacklog', model.filter('_goalList')
            .where('status').equals('backlog')

        model.ref '_reviewList', reviews
        model.ref '_sortedReviewList', reviews.sort(['timestamp', 'desc'])
        model.fetch "users.#{goal.get('userId')}", (error, user) ->
            model.ref '_goal._user', user
            page.render 'goals'

get '/users/', (page, model) ->
    allUsersQuery = model.query('users').allUsers()
    model.subscribe allUsersQuery, (errors, users) ->
        model.ref '_users', users
        userId = model.get('_sessionUserId')
        user = model.filter('_users')
            .where('id').equals(userId)
        model.ref '_currentUser', user.one()
        page.render 'users'

get '/users/:userId?/', (page, model, {userId}) ->
    goalsForUserQuery = model.query('goals').goalsForUser(userId)
    model.subscribe "users.#{userId}", goalsForUserQuery, (error, user, goals) ->
        model.ref '_goalList', goals
        model.ref '_user', user
        model.ref '_goalsTodo', model.filter('_goalList')
            .where('status').equals('todo')
        model.ref '_goalsInProgress', model.filter('_goalList')
            .where('status').equals('inprogress')
        model.ref '_goalsDone', model.filter('_goalList')
            .where('status').equals('done')
        model.ref '_goalsBacklog', model.filter('_goalList')
            .where('status').equals('backlog')
        page.render 'user',
            newGoalPlaceholder: 'I want to learn to program computers',
            newGoalLabel: 'What do you want to do?'
