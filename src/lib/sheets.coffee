Spreadsheet = require 'edit-google-spreadsheet'

clientId = process.env.HUBOT_ONBOARDING_GOOGLE_CLIENT_ID
clientSecret = process.env.HUBOT_ONBOARDING_GOOGLE_CLIENT_SECRET
refreshToken = process.env.HUBOT_ONBOARDING_GOOGLE_REFRESH_TOKEN

messagesSpreadsheet = process.env.HUBOT_ONBOARDING_SPREADSHEET_MESSAGES
tasksSpreadsheet = process.env.HUBOT_ONBOARDING_SPREADSHEET_TASKS

sheet =
  getMessages: (discipline, cb) ->
    return Spreadsheet.load {
      spreadsheetId: messagesSpreadsheet
      worksheetName: discipline,
      'oauth2':
        'client_id': clientId
        'client_secret': clientSecret
        'refresh_token': refreshToken
    }, (err, spreadsheet) ->
      return console.log err if err
      spreadsheet.receive (err, rows, info) ->
        return cb err if err
        cb null, rows

  getTasks: (discipline, cb) ->
    return Spreadsheet.load {
      spreadsheetId: tasksSpreadsheet
      worksheetName: discipline,
      'oauth2':
        'client_id': clientId
        'client_secret': clientSecret
        'refresh_token': refreshToken
    }, (err, spreadsheet) ->
      return console.log err if err
      spreadsheet.receive (err, rows, info) ->
        return cb err if err
        cb null, rows

module.exports = sheet
