# Description:
#   Schedules messages for new employees.
#
# Author
#   contolini

moment = require 'moment'
tickInterval = process.env.HUBOT_ONBOARDING_TICK_INTERVAL_SECONDS || 5

class Scheduler

  constructor: (@robot) ->
    @orientations = {}
    @robot.brain.on 'loaded', =>
      # Only continue if an employee has been added or removed
      return if Object.keys(@orientations)?.length == Object.keys(@robot.brain.get('onboarding'))?.length
      robot.logger.info "Initializing onboarding scheduler..."
      @orientations = @robot.brain.get 'onboarding'
      @start()

  sendMessage: (room, msg) ->
    @robot.messageRoom room, msg

  saveMessages: ->
    @robot.brain.set 'onboarding', @orientations

  tick: ->
    now = moment()
    for name, info of @orientations
      for message in info.messages
        if not message.sent
          buffer = moment(message.time).clone().add(tickInterval * 2, 's');
          if now.isBetween moment(message.time), buffer
            @robot.messageRoom info.username, message.title
            message.sent = true
    @saveMessages()

  start: ->
    @ticker = setInterval(=>
      @tick()
    , tickInterval * 1000)

  stop: ->
    clearInterval @ticker

module.exports = (robot) ->
  scheduler = new Scheduler robot

  robot.respond /onboard(ing)? start scheduler/i, (rest) ->
    scheduler.start()

  robot.respond /onboard(ing)? stop scheduler/i, (rest) ->
    scheduler.stop()
