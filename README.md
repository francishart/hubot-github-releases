Hubot Github Releases
================
Notifier for Github Release, works with Hubot, based on [hubot-rss-reader](https://github.com/shokai/hubot-rss-reader).

[![Circle CI](https://circleci.com/gh/francishart/hubot-github-releases.svg?style=svg)](https://circleci.com/gh/francishart/hubot-github-releases)

- https://github.com/github.com/francishart/hubot-github-releases
- https://www.npmjs.org/package/hubot-github-releases


Requirements
------------

- coffee-script 1.10+
- hubot-brain
  - recommend [hubot-mongodb-brain](http://npmjs.com/package/hubot-mongodb-brain).

Install
-------

    % npm install https://github.com/github.com/francishart/hubot-github-releases -save
    % npm install coffee-script@">=1.10.0" -save

### edit `external-script.json` -->

```json
["hubot-github-releases"]
```

### Configure (ENV vars)

    export DEBUG=hubot-github-releases*      # debug print
    export HUBOT_RSS_INTERVAL=600       # 600 sec (default)
    export HUBOT_RSS_HEADER=New Release:     # RSS Header Emoji (default is "@channel: :warning: New Release:")
    export HUBOT_RSS_USERAGENT=hubot    # (default is "hubot-github-releases/#{package_version}")
    export HUBOT_RSS_PRINTSUMMARY=true  # print summary (default is "true")
    export HUBOT_RSS_PRINTIMAGE=false   # print image in summary (default is "true")
    export HUBOT_RSS_PRINTERROR=false   # print error message (default is "true")
    export HUBOT_RSS_IRCCOLORS=true     # use IRC color message (default is "false")

Usage
-----

### add

    hubot gitreleases add https://github.com/francishart.atom
    # or
    hubot gitreleases register https://github.com/francishart.atom


### delete

    hubot gitreleases delete https://github.com/francishart.atom
    hubot gitreleases delete #room_name

### list

    hubot gitreleases list
    hubot gitreleases dump


Test
----

    % npm install

    % grunt
    # or
    % npm test
