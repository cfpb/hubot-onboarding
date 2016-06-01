util = require 'util'
events = require 'events'
_ = require 'lodash'

class Brain extends events.EventEmitter

  constructor: (@robot) ->
    @data = {}
    initialized = false
    @robot.brain.on 'loaded', =>
      return if initialized
      initialized = true
      @robot.logger.info 'Initializing onboarding robot...'
      @data = @robot.brain.get 'orientations'
      @data = @data or {}
      @emit 'loaded', @data

  set: (data) =>
    try
      @data = _.cloneDeep data
      @robot.brain.set 'orientations', @data
      @robot.logger.info 'Saved data to brain.'
      @emit 'saved', @data
    catch error
      @emit 'error', new Error 'Attempt to save data failed.'

  get: () ->
    @data

module.exports = Brain
