module.exports.initSelectOptions = (goal) ->
    goal.set '_statusChoices', ['todo', 'inprogress', 'done', 'backlog']
    goal.set '_reviewPeriods', [
        {name: 'day', numDays: 1},
        {name: 'week', numDays: 7},
        {name: 'month', numDays: 30}
    ]


module.exports.MS_PER_DAY = 24 * 60 * 60 * 1000

module.exports.setGoalDefaults = (goal) ->
    defaults = this.makeGoalDefaults()
    goal.setNull 'description', defaults.description,
    goal.setNull 'title', defaults.title,
    goal.setNull 'status', defaults.status,
    goal.setNull 'lastReviewed', defaults.lastReviewed,
    goal.setNull 'reviewPeriod', defaults.reviewPeriod,
    goal.setNull 'nextReview', defaults.nextReview


module.exports.makeGoalDefaults = () ->
    lastReviewed = new Date()
    return {
        description: "Use this space to add a sentence or two outlining <em>why</em> this goal or task is important to you, so you can re-evaluate it in the future. Click to edit.",
        title: "I want to edit this goal title",
        status: "todo",
        lastReviewed: lastReviewed,
        reviewPeriod: 7,
        nextReview: (new Date(lastReviewed.getTime() + 7 * this.MS_PER_DAY)).toISOString()
    }
