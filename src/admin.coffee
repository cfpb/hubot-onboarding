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
    _debug.employees = Object.assign({}, robot.brain.get 'onboarding' or {})

  # robot.respond /onboard(ing)? debug/i, (res) ->
  #   @HUBOT_ONBOARDING_DEBUG = not not not @HUBOT_ONBOARDING_DEBUG
  #   res.send "Onboarding debugging is now #{if @HUBOT_ONBOARDING_DEBUG then 'on' else 'off'}."

  robot.respond /onboard(ing)? (dump|list)/i, (res) ->
    res.send robot.brain.get 'onboarding'

  robot.respond /onboard(ing)? next/i, (res) ->
    employee = slug res.envelope.user.name, lower: true
    if not _debug.employees[employee].messages?.length
      _debug.employees[employee] = Object.assign({}, robot.brain.get('onboarding')[employee] or {})
    _debug.employees[employee].messages = _debug.employees[employee].messages.filter (message, i) ->
      return not message.sent

    msg = _debug.employees[employee].messages.shift()
    msg = "#{msg.title}\n\n*Originally scheduled for #{msg.time}*"
    res.send msg

  robot.respond /delete onboard(ing)?s?/i, (res) ->
    robot.brain.set 'onboarding', {}
    res.send "Okay, I deleted all onboardings."
