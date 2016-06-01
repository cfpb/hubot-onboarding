# Description:
#   Schedules messages for new employees.
#
# Author
#   contolini

moment = require 'moment'
# Brain = require './lib/brain'
tickInterval = process.env.HUBOT_ONBOARDING_TICK_INTERVAL_SECONDS || 5

class Scheduler

  constructor: (@robot, @brain) ->
    # @brain = new Brain
    @orientations = {}

    @brain.on 'loaded', (data) =>
      @orientations = data
      @start()

    @brain.on 'saved', (data) =>
      @orientations = data

  sendMessage: (room, msg) ->
    @robot.messageRoom room, msg

  saveMessages: ->
    @brain.set @orientations

  tick: ->
    now = moment()
    somethingWasSent = false
    for name, info of @orientations
      for message in info.messages
        if not message.sent
          buffer = moment(message.time).clone().add(tickInterval * 2, 's');
          if now.isBetween moment(message.time), buffer
            @robot.messageRoom info.username, message.title
            somethingWasSent = true
            message.sent = true
    @saveMessages() if somethingWasSent

  start: ->
    @ticker = setInterval(=>
      @tick()
    , tickInterval * 1000)

  stop: ->
    clearInterval @ticker

module.exports = Scheduler
