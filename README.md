Hubot Github Releases
================
Notifier for Github Release, works with Hubot, based on hubot-rss-reader.

[![Circle CI](https://circleci.com/gh/github.com/francishart/hubot-github-releases.svg?style=svg)](https://circleci.com/gh/github.com/francishart/hubot-github-releases)

- https://github.com/github.com/francishart/hubot-github-releases
- https://www.npmjs.org/package/hubot-github-releases

<!-- ![screen shot](http://gyazo.com/234dfb14d76bb3de9efd88bfe8dc6522.png) -->

Requirements
------------

- coffee-script 1.10+
- hubot-brain
  - recommend [hubot-mongodb-brain](http://npmjs.com/package/hubot-mongodb-brain).

Install
-------

    % npm install hubot-github-releases -save
    % npm install coffee-script@">=1.10.0" -save

### edit `external-script.json`

```json
["hubot-github-releases"]
```

### Configure (ENV vars)

    export DEBUG=hubot-github-releases*      # debug print
    export HUBOT_RSS_INTERVAL=600       # 600 sec (default)
    export HUBOT_RSS_HEADER=:sushi:     # RSS Header Emoji (default is "sushi")
    export HUBOT_RSS_USERAGENT=hubot    # (default is "hubot-github-releases/#{package_version}")
    export HUBOT_RSS_PRINTSUMMARY=true  # print summary (default is "true")
    export HUBOT_RSS_PRINTIMAGE=false   # print image in summary (default is "true")
    export HUBOT_RSS_PRINTERROR=false   # print error message (default is "true")
    export HUBOT_RSS_IRCCOLORS=true     # use IRC color message (default is "false")
    export HUBOT_RSS_LIMIT_ON_ADD=false # limit printing entries on add new feed. (default is 5)

Usage
-----

### add

    hubot rss add https://github.com/francishart.atom
    # or
    hubot rss register https://github.com/francishart.atom


### delete

    hubot rss delete https://github.com/francishart.atom
    hubot rss delete #room_name

### list

    hubot rss list
    hubot rss dump


Test
----

    % npm install

    % grunt
    # or
    % npm test
