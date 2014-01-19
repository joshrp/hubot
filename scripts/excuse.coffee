http = require 'http'

module.exports = (robot) ->
  robot.hear /!excuse/i, (msg) ->
    http.get("http://developerexcuses.com/", (res) ->
      data = ""
      res.on('data', (d) -> data += d)
      res.on('end', () -> 
        matches = data.match /<a [^>]+>(.+)<\/a>/i

        if matches and matches[1]
          msg.send matches[1]
      )
    )
