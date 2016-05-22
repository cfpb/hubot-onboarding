Helper = require 'hubot-test-helper'
sinon = require 'sinon'
chai = require 'chai'

expect = chai.expect

helper = new Helper('../src/onboarding.coffee')

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
        ['hubot', '@alice hello!']
      ]

  it 'ignores you if you\'re not an admin', ->
    @room.user.isAdmin = false
    @room.user.say('alice', 'orly').then =>
      expect(@room.messages).to.eql [
        ['alice', 'orly'],
        ['hubot', 'Sorry, only admins can do that.']
      ]

  it 'adds items', ->
    @room.user.say('alice', '@hubot add foo to the thing').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot add foo to the thing']
        ['hubot', 'Alright, I added foo to the thing.']
      ]

  it 'fails to remove items if you\'re not an admin', ->
    @room.user.isAdmin = false
    @room.user.say('alice', '@hubot remove foo from the thing').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot remove foo from the thing']
        ['hubot', 'Sorry, only admins can remove stuff.']
      ]

  it 'removes items', ->
    @room.user.say('alice', '@hubot remove foo from the thing').then =>
      expect(@room.messages).to.eql [
        ['alice', '@hubot remove foo from the thing']
        ['hubot', 'Okay, I removed foo from the thing.']
      ]
