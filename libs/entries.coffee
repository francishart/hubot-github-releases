# Data Store for entries

module.exports = class Entries

  constructor: (@robot) ->
    @prefix = 'hubot-github-releases:entry:'

  key: (url) ->
    "#{@prefix}#{url}"

  add: (url) ->
    @robot.brain.set @key(url), true

  remove: (url) ->
    @robot.brain.set @key(url), false

  include: (url) ->
    @robot.brain.get @key(url)
