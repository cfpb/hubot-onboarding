chrono = require 'chrono-node'
slug = require 'slug'
marked = require 'marked'
format = require 'onboarding-scheduler'
moment = require 'moment'
sheets = require './sheets'

CHECKLIST_HOST = "#{process.env.HUBOT_HOSTNAME}/welcome/"

create = (info, opts, cb) ->
  {debug} = opts
  orientation =
    username: info.name
    slug: slug info.name, lower: true
    discipline: info.discipline
    startDate: new Date()
    messages: []
    tasks: []
  orientation.checklist = "#{CHECKLIST_HOST}#{orientation.slug}"
  # status "Getting messages..."
  sheets.getMessages orientation.discipline, (err, messages) ->
    return cb err if err
    for message of messages
      title = messages[message][1].replace '${checklist_url}', orientation.checklist
      title = title.replace '${employee_info_page}', process.env.HUBOT_ONBOARDING_EMPLOYEE_INFO_PAGE
      orientation.messages.push
        title: title
        day: messages[message][2].replace 'Day ', ''
        sent: false
    orientation.messages = format orientation.messages

    if debug
      now = moment()
      orientation.messages.filter (message, i) ->
        message.title += "\n\n*Originally scheduled for #{message.time}*"
        message.time = now.add(30, 's').format()
        return message

    # status "Getting tasks..."
    sheets.getTasks orientation.discipline, (err, tasks) ->
      return cb err if err
      for task of tasks
        orientation.tasks.push
          title: marked tasks[task][1]
          completed: false
      # status "Adding orientation to DB..."
      cb null, orientation

module.exports = {create}
