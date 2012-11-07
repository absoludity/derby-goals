{ready, view} = app = require './index'
goalHelpers = require './helpers'

ready (model) ->
    subGoalList = model.at '_goalList'
    currentGoal = model.at '_goal'
    newReview = model.at '_newReview'
    reviewList = model.at '_reviewList'
    sessionUserId = model.at '_sessionUserId'

    @addGoal = ->
        newGoal = model.at '_newGoal'
        return unless goalTitle = view.escapeHtml newGoal.get()
        newGoal.set ''
        defaults = goalHelpers.makeGoalDefaults()
        goalsTodo = currentGoal.at('_goalsTodo').get()
        if goalsTodo and goalsTodo.length > 1
            defaults.status = 'backlog'
        defaults.title = goalTitle
        defaults.parentGoal = currentGoal.get('id')
        defaults.userId = sessionUserId.get()
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
