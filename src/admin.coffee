# Description
#   Misc. admin features
#
# Author:
#   contolini

slug = require 'slug'

module.exports = (robot) ->
  initialized = false
  _debug = {}

  robot.brain.on 'loaded', =>
    return if initialized
    initialized = true
    robot.logger.info "Initializing onboarding admin robot..."
    _debug.employees = robot.brain.get 'onboarding' or {}

  robot.respond /onboard(ing)? debug/i, (res) ->
    process.env.HUBOT_ONBOARDING_DEBUG = not not not process.env.HUBOT_ONBOARDING_DEBUG
    res.send "Onboarding debugging is now #{if process.env.HUBOT_ONBOARDING_DEBUG then 'on' else 'off'}."

  robot.respond /onboard(ing)? (dump|list)/i, (res) ->
    res.send robot.brain.get 'onboarding'

  robot.respond /onboard(ing)? next/i, (res) ->
    employee = slug res.envelope.user.name, lower: true
    _debug.employees[employee] = @robot.brain.get('onboarding')[employee] if not _debug.employees[employee].messages.length
    _debug.employees[employee].messages = _debug.employees[employee].messages.filter (message, i) ->
      return not message.sent

    res.send _debug.employees[employee].messages.shift().title

  # robot.respond /delete onboard(ing)?s?/i, (res) ->
  #   onboarding.removeAllOrientations()
  #   res.send "Okay, I deleted all onboardings."
