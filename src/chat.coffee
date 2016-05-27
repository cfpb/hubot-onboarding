# Description
#   Welcome new hires to your organization by gradually providing them scheduled information
#
# Configuration:
#   HUBOT_ONBOARDING_GOOGLE_CLIENT_ID - Describe your environment variable.
#   HUBOT_ONBOARDING_GOOGLE_CLIENT_SECRET - Describe your environment variable.
#   HUBOT_ONBOARDING_GOOGLE_REFRESH_TOKEN - Describe your environment variable.
#   HUBOT_ONBOARDING_SPREADSHEET_MESSAGES - Google Spreadsheet ID # that contains your onboarding messages.
#   HUBOT_ONBOARDING_SPREADSHEET_TASKS - Google Spreadsheet ID # that contains your onboarding tasks.
#   HUBOT_ONBOARDING_EMPLOYEE_INFO_PAGE - URL of webpage that lists all sort of useful things (e.g. HR, payroll, conf room links)
#   HUBOT_ONBOARDING_DEBUG - Set to true if you want messages to be queued thirty seconds apart instead of days apart.
#
# Commands:
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   contolini

Conversation = require 'hubot-conversation'
Onboarding = require './lib/onboarding'
orientation = require './lib/orientation'

module.exports = (robot) ->
  onboarding = new Onboarding robot
  switchBoard = new Conversation robot

  robot.respond /(hi|hello|how are you)/i, (msg) ->
    newEmployee =
      name: msg.envelope.user.name
    dialog = switchBoard.startDialog msg, 600000
    dialog.timeout = (msg) ->
      robot.logger.info "Onboarding dialogue with #{msg.envelope.user.name} timed out."

    msg.send "Hi #{msg.envelope.user.name}! I'm #{robot.name} -- CFPB's chat bot. Quick question: Are you a new CFPB employee?"

    dialog.addChoice /(yes|yeah|yup|yep|y)/i, (msg2) ->
      msg2.send "Welcome to CFPB! 😸👏💃"
      setTimeout(->
        msg2.send "I'm a basic chat bot built by the people in this office to help you get acquainted with your new job. Someday, I aspire to be Bender from Futurama. http://i.giphy.com/vSoHbyABFCunS.gif"
        setTimeout(->
          msg2.send "Rather than send you a big list of stuff to do, I'll periodically send you messages with reminders and tasks."
          setTimeout(->
            msg2.send "But first tell me a bit about yourself. Were you hired as a designer or a developer?"
          , 5000)
        , 7000)
      , 2000)

      dialog.addChoice /dev(eloper)?/i, (msg3) ->
        newEmployee.discipline = 'developer'
        msg3.send "Awesome -- a new developer! :neckbeard: Someone to build me some new features. 😉"
        setTimeout(->
          msg3.send "That's all the info I need for now! Expect some automated onboarding messages from me soon. Have a great day. 😃"
        , 3000)
        orientation.create newEmployee, debug: !!process.env.HUBOT_ONBOARDING_DEBUG, (err, orientation) ->
          onboarding.addOrientation orientation

      dialog.addChoice /design(er)?/i, (msg3) ->
        newEmployee.discipline = 'designer'
        msg3.send "Nice -- a new designer! 👏 Someone to keep our products user-friendly. 😉"
        setTimeout(->
          msg3.send "That's all the info I need for now! Expect some automated onboarding messages from me soon. Have a great day. 😃"
        , 3000)
        orientation.create newEmployee, debug: !!process.env.HUBOT_ONBOARDING_DEBUG, (err, orientation) ->
          orientation.checklist = "#{CHECKLIST_HOST}#{orientation.slug}"
          onboarding.addOrientation orientation

    dialog.addChoice /(no|nope|nah|negative)/i, (msg2) ->
      msg2.reply "Okay, cool. I have some automated messages that I send to new employees but I won't send them to you."
      setTimeout(->
        msg3.send "I'm a simple bot but I can do all sorts of neat stuff."
        setTimeout(->
          msg3.send "To see all my commands, type: `cfpbot help`"
          setTimeout(->
            msg3.send "My maintainers are working on a user guide! Until it's done, join the `Meta` channel and ask any questions there. The humans there are very polite. 👪"
          , 2000)
        , 2000)
      , 3000)
