class Onboarding
  constructor: (@robot) ->
    initialized = false
    @robot.brain.on 'loaded', =>
      return if initialized
      initialized = true
      robot.logger.info "Initializing onboarding robot..."
      @onboarding = @robot.brain.get 'onboarding' or {}
      @robot.brain.set 'onboarding', @onboarding

  addOrientation: (item, cb) ->
    @onboarding[item.slug] = item
    @robot.brain.set 'onboarding', @onboarding
    cb item if cb

  removeOrientation: (item) ->
    delete @onboarding[item.slug]
    @robot.brain.set 'onboarding', @onboarding

  removeAllOrientations: (item) ->
    @onboarding = {}
    @robot.brain.set 'onboarding', @onboarding

  getOrientations: ->
    @onboarding

module.exports = Onboarding
