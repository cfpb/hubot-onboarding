# Description:
#   Creates new employee checklists
#
# Author
#   contolini

path = require 'path'
url = require 'url'
connect = require 'connect'

# Brain = require './lib/brain'

routes = {}

class Backend

  constructor: (@robot, @brain) ->
    # @brain = new Brain
    @orientations = {}

    @brain.on 'loaded', (data) =>
      @orientations = data
      @createRoutes()

    @brain.on 'saved', (data) =>
      @orientations = data
      @createRoutes()

  getTasks: (employee) ->
    @orientations[employee]?.tasks

  setTasks: (employee, tasks) ->
    @orientations[employee]?.tasks = tasks
    @brain.set @orientations

  createRoutes: ->
    for name, info of @orientations
      @createChecklistRoute name

  createChecklistRoute: (name) ->
    # return if routes[name]
    routes[name] = "/checklist/#{name}"
    @robot.router.stack.splice @robot.router.stack.length - 1, 0, {
      route: routes[name]
      handle: connect.static path.join(__dirname, '..', '..', 'static')
    }
    @robot.logger.info "Created employee checklist at #{routes[name]}"

module.exports = Backend
