# Description
#   Welcome new hires to your organization by gradually providing them scheduled information
#
# Configuration:
#   HUBOT_ONBOARDING_GOOGLE_CLIENT_ID - Describe your environment variable.
#   HUBOT_ONBOARDING_GOOGLE_CLIENT_SECRET - Describe your environment variable.
#   HUBOT_ONBOARDING_GOOGLE_REFRESH_TOKEN - Describe your environment variable.
#
# Commands:
#   hubot hello - <what the respond trigger does>
#   orly - <what the hear trigger does>
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   Chris Contolini

chrono = require 'chrono-node'
sheets = require './lib/sheets'

class OnboardingRobot
  constructor: (@robot) ->
    @connectedToDB = false
    @robot.brain.on 'connected', =>
      console.log @robot.brain.autoSave
      @initBrain()
    # This is a fallback for hubots not using redis or using old versions of
    # redis-brain.coffee that don't emit a 'connected' event.
    setTimeout(=>
      @initBrain() if not @connectedToDB
    , 7000)
  initBrain: ->
    @onboarding = @robot.brain.get 'onboarding' or []
    @robot.brain.set 'onboarding', @onboarding
    @connectedToDB = true
  addOrientation: (item, cb) ->
    @onboarding.push item
    cb()
  removeOrientation: (item) ->
    @onboarding = @onboarding.filter (i) -> i isnt item
  getOrientations: ->
    @onboarding

module.exports = (robot) ->
  onboardingRobot = new OnboardingRobot robot

  robot.respond /onboard (list|ls)/i, (rest) ->
    console.log onboardingRobot.getOrientations()

  robot.respond /onboard (db)/i, (rest) ->
    console.log robot.brain.get 'onboarding'



  robot.respond /onboard ([^\s]*) as a (\w*) (on|starting) (.*)/, (res) ->
    orientation =
      username: res.match[1]
      discipline: res.match[2]
      startDate: chrono.parseDate res.match[4]
      messages: []
      tasks: []
    res.reply "No problem. One #{orientation.discipline} orientation coming right up. Let me check those Google docs..."
    sheets.getMessages orientation.discipline, (messages) ->
      for message of messages
        orientation.messages.push
          title: messages[message][1]
          day: messages[message][2].replace 'Day ', ''
          sent: false
      res.send "Alright, I loaded #{orientation.messages.length} #{orientation.discipline} messages. Now I'll create a checklist for the new employee..."
      sheets.getTasks orientation.discipline, (tasks) ->
        for task of tasks
          orientation.tasks.push
            title: tasks[task][1]
            completed: false
        onboardingRobot.addOrientation orientation, ->
          res.send "Great. I built a [checklist]() for them. Now I just need to schedule everything..."
          setTimeout(->
            res.send "All set! I'll start messaging #{orientation.username} on #{orientation.startDate}."
            console.log onboardingRobot.getOrientations()
          , 3000)
