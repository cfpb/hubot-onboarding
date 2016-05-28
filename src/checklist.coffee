# Description:
#   Creates new employee checklists
#
# Author
#   contolini

path = require 'path'
url = require 'url'

connect = require 'connect'

# checklists = {}

# createChecklist = (robot, User, cb) ->
#   user = slug User
#   return if checklists[user]
#   route = "/checklist/#{user}"
#   robot.router.stack.splice robot.router.stack.length - 1, 0, {
#     route: route
#     handle: connect.static path.join(__dirname, '..', 'static')
#   }
#   robot.logger.info "Created new employee checklist for #{User}"
#   checklists[user] =
#     slug: user
#     username: User
#     route: route
#   cb checklists[user]

class Backend

  constructor: (@robot) ->
    @orientations = {}
    @robot.brain.on 'loaded', =>
      # Only continue if an employee has been added or removed
      return if Object.keys(@orientations)?.length is Object.keys(@robot.brain.get('onboarding'))?.length
      robot.logger.info "Initializing onboarding backend..."
      @orientations = @robot.brain.get 'onboarding'
      @createRoutes()

  getTasks: (employee) ->
    @orientations[employee]?.tasks

  setTasks: (employee, tasks) ->
    @orientations[employee]?.tasks = tasks
    @robot.brain.set 'onboarding', @orientations

  createRoutes: ->
    for name, info of @orientations
      @createChecklistRoute name

  createChecklistRoute: (name) ->
    # return if @names[name.slug]?.route?
    route = "/checklist/#{name}"
    @robot.router.stack.splice robot.router.stack.length - 1, 0, {
      route: route
      handle: connect.static path.join(__dirname, '..', 'static')
    }
    robot.logger.info "Created employee checklist for #{name}"

module.exports = (robot) ->
  backend = new Backend robot

  robot.router.get '/checklist/:username/tasks.json', (req, res) ->
    username = req.params.username
    return res.send {error: "Please specify a username."} unless username
    res.send backend.getTasks username

  robot.router.post '/checklist/:username/tasks', (req, res) ->
    username = req.params.username
    return res.send 422 unless username
    backend.setTasks username, req.body.tasks


  # this is a really dirty JS abusing hack that probably should never be used
  # but it let's us put middleware into the stack even after the app has
  # started listening - yolo
  # robot.router.stack.splice(robot.router.stack.length - 1, 0, {
  #   route:  '/checklist'
  #   handle: connect.static(path.join(__dirname, '..', 'static'))
  # })

  # # verify that the submitted username exists on github
  # robot.router.post '/github/identity/username', (req, res) ->
  #   return res.send 422 unless req.body.username
  #
  #   username = req.body.username
  #
  #   github.request "/users/#{username}", null, (err, data) ->
  #     return res.send 404 if err or data.message is 'Not Found'
  #     res.send data
  #
  # # verify that the submitted token works for the username
  # robot.router.post '/github/identity/token', (req, res) ->
  #   return res.send 422 unless req.body.username and req.body.token
  #
  #   username = req.body.username
  #   token = req.body.token
  #
  #   github.request '/user', req.body.token, (err, data) ->
  #     return res.send 404 if err or data.message is 'Bad credentials'
  #     return res.send 404 if data.login isnt username
  #
  #     robot.identity.setGitHubUserAndToken username, token, (err, reply) ->
  #       res.send reply
