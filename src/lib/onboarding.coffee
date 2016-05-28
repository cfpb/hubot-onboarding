class Onboarding
  constructor: (@robot) ->
    initialized = false
    @orientations = {}
    @robot.brain.on 'loaded', =>
      return if initialized
      initialized = true
      robot.logger.info "Initializing onboarding robot..."
      @orientations = @robot.brain.get 'onboarding'
      @orientations = @orientations or {}
      @robot.brain.set 'onboarding', @orientations

  addOrientation: (item, cb) ->
    @orientations[item.slug] = item
    @robot.brain.set 'onboarding', @orientations
    cb item if cb

  removeOrientation: (item) ->
    delete @orientations[item.slug]
    @robot.brain.set 'onboarding', @orientations

  removeAllOrientations: (item) ->
    @orientations = {}
    @robot.brain.set 'onboarding', @orientations

  getOrientations: ->
    @orientations

module.exports = Onboarding
