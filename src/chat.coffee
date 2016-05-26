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

CHECKLIST_HOST = "#{process.env.HUBOT_HOSTNAME}/welcome/"

Conversation = require 'hubot-conversation'
Onboarding = require './lib/onboarding'
orientation = require './lib/orientation'

module.exports = (robot) ->
  onboarding = new Onboarding robot
  switchBoard = new Conversation robot

  robot.respond /onboard(ing)? (list|ls)/i, (res) ->
    console.log onboarding.getOrientations()

  robot.respond /onboard(ing)? dump/i, (res) ->
    console.log robot.brain.get 'onboarding'

  robot.respond /delete onboard(ing)?s?/i, (res) ->
    onboarding.removeAllOrientations()
    res.send "Okay, I deleted all onboardings."


  robot.respond /(hi|hello|how are you)/i, (msg) ->
    newEmployee =
      name: msg.envelope.user.name
    dialog = switchBoard.startDialog msg
    dialog.timeout = (msg) ->
      robot.logger.info "Onboarding dialogue with #{msg.envelope.user.name} timed out."

    msg.send "Hi #{msg.envelope.user.name}! I'm Bradbot -- CFPB's chat bot. Quick question: Are you a new CFPB employee?"

    dialog.addChoice /(yes|yeah|yup|yep|y)/i, (msg2) ->
      msg2.send "Welcome to CFPB! 😸👏💃"
      msg2.send "I'll help you get acquainted with the Bureau by sending you some automated messages. But first tell me a bit about yourself. Were you hired as a designer or a developer?"
      dialog.addChoice /(dev)/i, (msg3) ->
        newEmployee.discipline = 'developer'
        msg3.send "Awesome -- a new developer! Someone to build me some new features. 😉"
        setTimeout(->
          msg3.send "Hang on for just one second while I build a new employee checklist for you..."
        , 1000)
        orientation.create newEmployee, (err, orientation) ->
          onboarding.addOrientation orientation
          msg3.send "All done! Here are some things for you to do: #{CHECKLIST_HOST}#{orientation.slug}"

      dialog.addChoice /(design)/i, (msg3) ->
        newEmployee.discipline = 'designer'
        onboarding.initOrientation newEmployee, (err, orientation) ->
          onboarding.addOrientation orientation
          console.log orientation
        msg3.reply "You're a designer!"

    dialog.addChoice /(no|nope|nah|negative)/i, (msg2) ->
      msg2.reply "Okay, cool. I have some automated messages that I send to new employees but I won't send them to you."


  # robot.respond /onboard ([^\s]*) as a (\w*) (on|starting) (.*)/, (res) ->
  #   orientation =
  #     username: res.match[1]
  #     discipline: res.match[2]
  #     startDate: chrono.parseDate res.match[4]
  #     messages: []
  #     tasks: []
  #   res.reply "No problem. One #{orientation.discipline} orientation coming right up. Let me check those Google docs..."
  #   sheets.getMessages orientation.discipline, (messages) ->
  #     for message of messages
  #       orientation.messages.push
  #         title: messages[message][1]
  #         day: messages[message][2].replace 'Day ', ''
  #         sent: false
  #     res.send "Alright, I loaded #{orientation.messages.length} #{orientation.discipline} messages. Now I'll create a checklist for the new employee..."
  #     sheets.getTasks orientation.discipline, (tasks) ->
  #       for task of tasks
  #         orientation.tasks.push
  #           title: tasks[task][1]
  #           completed: false
  #       onboarding.addOrientation orientation, ->
  #         res.send "Great. I built a [checklist]() for them. Now I just need to schedule everything..."
  #         setTimeout(->
  #           res.send "All set! I'll start messaging #{orientation.username} on #{orientation.startDate}."
  #           console.log onboarding.getOrientations()
  #         , 3000)
