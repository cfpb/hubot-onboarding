Spreadsheet = require 'edit-google-spreadsheet'

clientId = process.env.HUBOT_ONBOARDING_GOOGLE_CLIENT_ID
clientSecret = process.env.HUBOT_ONBOARDING_GOOGLE_CLIENT_SECRET
refreshToken = process.env.HUBOT_ONBOARDING_GOOGLE_REFRESH_TOKEN

sheet =
  getMessages: (discipline, cb) ->
    return Spreadsheet.load {
      spreadsheetId: '1bXSrtvnXek68Zi0oFby3A5OCTdE0ohrM83rXB342gx4'
      worksheetName: discipline,
      'oauth2':
        'client_id': clientId
        'client_secret': clientSecret
        'refresh_token': refreshToken
    }, (err, spreadsheet) ->
      return console.log err if err
      spreadsheet.receive (err, rows, info) ->
        cb(rows);

  getTasks: (discipline, cb) ->
    return Spreadsheet.load {
      spreadsheetId: '1TE8QVbLWhAu3gHdG3xmPDCgC6hmzHd1W72vzQsvBMbI'
      worksheetName: discipline,
      'oauth2':
        'client_id': clientId
        'client_secret': clientSecret
        'refresh_token': refreshToken
    }, (err, spreadsheet) ->
      return console.log err if err
      spreadsheet.receive (err, rows, info) ->
        cb(rows);

module.exports = sheet
