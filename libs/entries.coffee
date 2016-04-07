# Data Store for entries

module.exports = class Entries

  constructor: (@robot) ->
    @prefix = 'hubot-github-releases:entry:'

  key: (guid) ->
    "#{@prefix}#{guid}"

  add: (guid) ->
    @robot.brain.set @key(guid), true

  remove: (guid) ->
    @robot.brain.set @key(guid), false

  include: (guid) ->
    @robot.brain.get @key(guid)
