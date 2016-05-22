# Description:
#   Backend that handles the behind the scenes for the web based part of the
#   package.
#
# Author
#   tombell
#   mattgraham

path = require 'path'
url = require 'url'

connect = require 'connect'

module.exports = (robot) ->

  # this is a really dirty JS abusing hack that probably should never be used
  # but it let's us put middleware into the stack even after the app has
  # started listening - yolo
  robot.router.stack.splice(robot.router.stack.length - 1, 0, {
    route:  '/welcome'
    handle: connect.static(path.join(__dirname, '..', 'static'))
  })

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
