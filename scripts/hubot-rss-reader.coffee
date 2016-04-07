# Description:
#   Hubot Github Releases Notifier
#
# Commands:
#   hubot gitreleases add https://github.com/shokai.atom
#   hubot gitreleases delete http://shokai.org/blog/feed
#   hubot gitreleases delete #room_name
#   hubot gitreleases list
#   hubot gitreleases dump
#
# Author:
#   @franciahsrt

'use strict'

path       = require 'path'
_          = require 'lodash'
debug      = require('debug')('hubot-github-releases')
Promise    = require 'bluebird'
RSSChecker = require path.join __dirname, '../libs/rss-checker'
FindRSS    = Promise.promisify require 'find-rss'

## config
package_json = require path.join __dirname, '../package.json'
process.env.HUBOT_RSS_INTERVAL     ||= 60*1  # 1 minutes
process.env.HUBOT_RSS_HEADER       ||= 'New Release: '
process.env.HUBOT_RSS_USERAGENT    ||= "hubot-github-releases/#{package_json.version}"
process.env.HUBOT_RSS_PRINTSUMMARY ||= "true"
process.env.HUBOT_RSS_PRINTIMAGE   ||= "false"
process.env.HUBOT_RSS_PRINTERROR   ||= "true"
process.env.HUBOT_RSS_IRCCOLORS    ||= "false"
process.env.HUBOT_RSS_LIMIT_ON_ADD ||= 5

module.exports = (robot) ->

  logger =
    info: (msg) ->
      return debug msg if debug.enabled
      msg = JSON.stringify msg if typeof msg isnt 'string'
      robot.logger.info "#{debug.namespace}: #{msg}"
    error: (msg) ->
      return debug msg if debug.enabled
      msg = JSON.stringify msg if typeof msg isnt 'string'
      robot.logger.error "#{debug.namespace}: #{msg}"

  send_queue = []
  send = (envelope, body) ->
    send_queue.push {envelope: envelope, body: body}

  getRoom = (msg) ->
    switch robot.adapterName
      when 'hipchat'
        msg.message.user.reply_to
      else
        msg.message.room

  setInterval ->
    return if typeof robot.send isnt 'function'
    return if send_queue.length < 1
    msg = send_queue.shift()
    try
      robot.send msg.envelope, msg.body
    catch err
      logger.error "Error on sending to room: \"#{room}\""
      logger.error err
  , 2000

  checker = new RSSChecker robot

  ## wait until connect redis
  robot.brain.once 'loaded', ->
    run = (opts) ->
      logger.info "checker start"
      checker.check opts
      .then ->
        logger.info "wait #{process.env.HUBOT_RSS_INTERVAL} seconds"
        setTimeout run, 1000 * process.env.HUBOT_RSS_INTERVAL
      , (err) ->
        logger.error err
        logger.info "wait #{process.env.HUBOT_RSS_INTERVAL} seconds"
        setTimeout run, 1000 * process.env.HUBOT_RSS_INTERVAL

    run()


  last_state_is_error = {}

  checker.on 'new entry', (entry) ->
    last_state_is_error[entry.feed.url] = false
    for room, feeds of checker.getAllFeeds()
      if room isnt entry.args.room and
         _.includes feeds, entry.feed.url
        logger.info "#{entry.title} #{entry.url} => #{room}"
        send {room: room}, entry.toString()

  checker.on 'error', (err) ->
    logger.error err
    if process.env.HUBOT_RSS_PRINTERROR isnt "true"
      return
    if last_state_is_error[err.feed.url]  # reduce error notify
      return
    last_state_is_error[err.feed.url] = true
    for room, feeds of checker.getAllFeeds()
      if _.includes feeds, err.feed.url
        send {room: room}, "[ERROR] #{err.feed.url} - #{err.error.message or err.error}"

  robot.respond /gitreleases\s+(add|register)\s+(https?:\/\/[^\s]+)$/im, (msg) ->
    url = msg.match[2].trim()
    last_state_is_error[url] = false
    logger.info "add #{url}"
    room = getRoom msg
    checker.addFeed(room, url)
    .then (res) ->
      new Promise (resolve) ->
        msg.send res
        resolve url
    .then (url) ->
      checker.fetch {url: url, room: room}
    # .then (entries) ->
    #   entry_limit =
    #     if process.env.HUBOT_RSS_LIMIT_ON_ADD is 'false'
    #       entries.length
    #     else
    #       process.env.HUBOT_RSS_LIMIT_ON_ADD - 0
    #   for entry in entries.splice 0, entry_limit
    #     send {room: room}, entry.toString()
    #   if entries.length > 0
    #     send {room: room},
    #     "#{process.env.HUBOT_RSS_HEADER} #{entries.length} entries has been omitted"
    , (err) ->
      msg.send "[ERROR] #{err}"
      return if err.message isnt 'Not a feed'
      checker.deleteFeed(room, url)
      .then ->
        FindRSS url
      .then (feeds) ->
        return if feeds?.length < 1
        msg.send _.flatten([
          "found some Feeds from #{url}"
          feeds.map (i) -> " * #{i.url}"
        ]).join '\n'
    .catch (err) ->
      msg.send "[ERROR] #{err}"
      logger.error err.stack


  robot.respond /gitreleases\s+delete\s+(https?:\/\/[^\s]+)$/im, (msg) ->
    url = msg.match[1].trim()
    logger.info "delete #{url}"
    checker.deleteFeed(getRoom(msg), url)
    .then (res) ->
      msg.send res
    .catch (err) ->
      msg.send err
      logger.error err.stack

  robot.respond /gitreleases\s+delete\s+#([^\s]+)$/im, (msg) ->
    room = msg.match[1].trim()
    logger.info "delete ##{room}"
    checker.deleteRoom room
    .then (res) ->
      msg.send res
    .catch (err) ->
      msg.send err
      logger.error err.stack

  robot.respond /gitreleases\s+list$/i, (msg) ->
    feeds = checker.getFeeds getRoom(msg)
    if feeds.length < 1
      msg.send "nothing"
    else
      msg.send feeds.join "\n"

  robot.respond /gitreleases dump$/i, (msg) ->
    feeds = checker.getAllFeeds()
    msg.send JSON.stringify feeds, null, 2
