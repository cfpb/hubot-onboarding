chrono = require 'chrono-node'
slug = require 'slug'
marked = require 'marked'
format = require 'onboarding-scheduler'
moment = require 'moment';
sheets = require './sheets'

CHECKLIST_HOST = "#{process.env.HUBOT_HOSTNAME}/checklist/"

create = (info, cb) ->
  # {debug} = opts
  orientation =
    username: info.name
    slug: slug info.name, lower: true
    discipline: info.discipline
    startDate: new Date()
    messages: []
    tasks: []
  orientation.checklist = "#{CHECKLIST_HOST}#{orientation.slug}"

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
    if process.env.HUBOT_ONBOARDING_DEBUG
      now = moment(new Date()).utcOffset '-04:00'
      orientation.messages.map (message) ->
        message.time = now.add(15, 's').format()
        return message

    sheets.getTasks orientation.discipline, (err, tasks) ->
      return cb err if err
      for task of tasks
        # Remove paragraph tags that wrap the html
        title = marked(tasks[task][1]).trim().replace(/^(?:<p>)(.*?)(?:<\/p>)$/ig, "$1")
        orientation.tasks.push
          title: title
          completed: false
      cb null, orientation

module.exports = {create}
