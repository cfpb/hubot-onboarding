# Description
#   Welcome new hires to your organization by gradually providing them scheduled information
#
# Configuration:
#   HUBOT_ONBOARDING_GOOGLE_CLIENT_ID - Google Docs OAUTH2 client ID
#   HUBOT_ONBOARDING_GOOGLE_CLIENT_SECRET - Google Docs OAUTH2 client secret
#   HUBOT_ONBOARDING_GOOGLE_REFRESH_TOKEN - Google Docs OAUTH2 refresh token
#   HUBOT_ONBOARDING_SPREADSHEET_MESSAGES - Google Spreadsheet ID # that contains your onboarding messages.
#   HUBOT_ONBOARDING_SPREADSHEET_TASKS - Google Spreadsheet ID # that contains your onboarding tasks.
#   HUBOT_ONBOARDING_EMPLOYEE_INFO_PAGE - URL of webpage that lists all sort of useful things (e.g. HR, payroll, conf room links)
#
# Commands:
#
# Notes:
#   <optional notes required for the script>
#
# Author:
#   contolini

Conversation = require 'hubot-conversation'
read2me = require 'read2me'
Brain = require './lib/brain'
Checklist = require './lib/checklist'
Scheduler = require './lib/scheduler'
orientation = require './lib/orientation'

orientations = {}

module.exports = (robot) ->
  brain = new Brain robot
  switchBoard = new Conversation robot
  checklist = new Checklist robot, brain
  scheduler = new Scheduler robot, brain

  # HTML checklists
  robot.router.get '/checklist/:username/tasks.json', (req, res) ->
    username = req.params.username
    return res.send {error: "Please specify a username."} unless username
    res.send checklist.getTasks username

  robot.router.post '/checklist/:username/tasks', (req, res) ->
    username = req.params.username
    return res.send 422 unless username
    checklist.setTasks username, req.body.tasks
    res.send 200

  # Admin stuff to aid debugging
  robot.respond /delete onboard(ing)?s?/i, (res) =>
    brain.set {}
    res.send "Okay, I deleted all onboardings."

  robot.respond /onboard(ing)? start scheduler/i, (rest) ->
    scheduler.start()

  robot.respond /onboard(ing)? stop scheduler/i, (rest) ->
    scheduler.stop()

  # Onboarding communications
  # @TODO: clean this up so that it's not callback hell
  robot.respond /(hi|hello|how are you)/i, (msg) ->
    newEmployee =
      name: msg.envelope.user.name
    dialog = switchBoard.startDialog msg, 600000
    dialog.timeout = (msg) ->
      robot.logger.info "Onboarding dialogue with #{msg.envelope.user.name} timed out."

    msg.send "Hi #{msg.envelope.user.name}! I'm #{robot.name.charAt(0).toUpperCase() + robot.name.slice(1)}, T&I's automated assistant. Quick question: Are you a new CFPB employee?"

    dialog.addChoice /(yes|yeah|yup|yep|y)/i, (msg2) ->
      read2me [
        "Welcome to the CFPB! 😸 💃",
        "I'm a basic chat bot built by the people in this office to help you get acquainted with your new job. Someday, I aspire to be Bender from Futurama. https://i.imgur.com/Zm4qfCf.gif",
        "Rather than send you a big list of new employee stuff to do, I'll periodically send you messages with reminders and tasks.",
        "But first tell me a bit about yourself. Which category best describes you: designer or developer?"
      ], (message) ->
        msg2.send message

      dialog.addChoice /dev(eloper)?/i, (msg3) ->
        newEmployee.discipline = 'developer'
        read2me [
          "Awesome -- a new developer! :neckbeard: Someone to build me some new features. 😉",
          "That's all the info I need for now! Expect some automated onboarding messages from me soon. Have a great day. 😃"
        ], (message) ->
          msg2.send message

        orientation.create newEmployee, (err, orientation) ->
          orientations[orientation.slug] = orientation
          brain.set orientations

      dialog.addChoice /design(er)?/i, (msg3) ->
        newEmployee.discipline = 'designer'
        read2me [
          "Nice -- a new designer! 👏 Someone to keep our products user-friendly. 😉",
          "That's all the info I need for now! Expect some automated onboarding messages from me soon. Have a great day. 😃"
        ], (message) ->
          msg2.send message

        orientation.create newEmployee, (err, orientation) ->
          orientations[orientation.slug] = orientation
          brain.set orientations

    dialog.addChoice /(no|nope|nah|negative)/i, (msg2) ->
      msg2.send "Okay, cool. I have some automated messages that I send to new employees but I won't send them to you."
      setTimeout(->
        msg2.send "BTW, have you met my good friend, CFPBot? She can do some pretty neat stuff."
        setTimeout(->
          msg2.send "To see all her commands, send her a message with the word `help`."
          setTimeout(->
            msg2.send "My maintainers are working on a user guide for her! Until it's done, join the `Meta` channel and ask any questions there. The humans there are very polite. 👪"
          , 2000)
        , 2000)
      , 3000)
