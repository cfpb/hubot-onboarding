# Description:
#   Backend that handles the behind the scenes for the web based part of the
#   package.
#
# Author
#   tombell
#   mattgraham

schedule = require 'node-schedule'
moment = require 'moment'
tickInterval = process.env.HUBOT_ONBOARDING_TICK_INTERVAL_SECONDS || 1

class Scheduler

  constructor: (@robot) ->
    @employees = {}
    @robot.brain.on 'loaded', =>
      # Only continue if an employee has been added or removed
      return if Object.keys(@employees)?.length == Object.keys(@robot.brain.get('onboarding'))?.length
      console.log "Initializing onboarding scheduler..."
      @employees = @robot.brain.get 'onboarding'
      @start()

  sendMessage: (room, msg) ->
    @robot.messageRoom room, msg

  tick: ->
    now = moment()
    for name, info of @employees
      for message in info.messages
        return if message.sent
        buffer = moment(message.time).clone().add(tickInterval, 's');
        if (now.isBetween(moment(message.time), buffer)) {
          @robot.messageRoom info.username, message.title
          message.sent = true
        }

  start: ->
    @ticker = setInterval(=>
      @tick()
    , tickInterval * 1000)

  stop: ->
    clearInterval @ticker

module.exports = (robot) ->
  scheduler = new Scheduler robot

  robot.respond /start scheduler/i, (rest) ->
    scheduler.start()

  robot.respond /stop scheduler/i, (rest) ->
    scheduler.stop()
