chrono = require 'chrono-node'
slug = require 'slug'
format = require 'onboarding-scheduler'
sheets = require './sheets'

create = (info, cb) ->
  orientation =
    username: info.name
    slug: slug info.name, lower: true
    discipline: info.discipline
    startDate: new Date()
    messages: []
    tasks: []
  # status "Getting messages..."
  sheets.getMessages orientation.discipline, (err, messages) ->
    return cb err if err
    for message of messages
      orientation.messages.push
        title: messages[message][1]
        day: messages[message][2].replace 'Day ', ''
        sent: false
    orientation.messages = format orientation.messages
    console.log orientation.messages
    # status "Getting tasks..."
    sheets.getTasks orientation.discipline, (err, tasks) ->
      return cb err if err
      for task of tasks
        orientation.tasks.push
          title: tasks[task][1]
          completed: false
      # status "Adding orientation to DB..."
      cb null, orientation

module.exports = {create}
