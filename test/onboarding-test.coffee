Helper = require 'hubot-test-helper'
sinon = require 'sinon'
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/index.coffee')

describe 'onboarding', ->
  beforeEach ->
    @room = helper.createRoom()
    @room.user.isAdmin = true
    @room.robot.auth = isAdmin: =>
      return @room.user.isAdmin

  afterEach ->
    @room.destroy()

  it 'greets you back', ->
    @room.user.say('alice', '@hubot hello').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot hello']
        ['hubot', 'Hi alice! I\'m Hubot, T&I\'s automated assistant. Quick question: Are you a new CFPB employee?']
      ]

  xit 'ignores you if you\'re not an admin', ->
    @room.user.isAdmin = false
    @room.user.say('alice', 'orly').then =>
      expect(@room.messages).to.eql [
        ['alice', 'orly'],
        ['hubot', 'Sorry, only admins can do that.']
      ]

  xit 'adds items', ->
    @room.user.say('alice', '@hubot add foo to the thing').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot add foo to the thing']
        ['hubot', 'Alright, I added foo to the thing.']
      ]

  xit 'fails to remove items if you\'re not an admin', ->
    @room.user.isAdmin = false
    @room.user.say('alice', '@hubot remove foo from the thing').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot remove foo from the thing']
        ['hubot', 'Sorry, only admins can remove stuff.']
      ]

  xit 'removes items', ->
    @room.user.say('alice', '@hubot remove foo from the thing').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot remove foo from the thing']
        ['hubot', 'Okay, I removed foo from the thing.']
      ]
