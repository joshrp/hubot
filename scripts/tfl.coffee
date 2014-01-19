http = require 'http'

module.exports = (robot) ->
    robot.respond /tube/i, (msg) ->
        http.get("http://api.tubeupdates.com/?method=get.status&format=json&lines=all", (res) ->
            data = ""
            res.on('data', (d) -> 
                data += d
            )
            res.on('end', () -> 
                content = JSON.parse(data)
                response = content.response
                if (response && response.lines)
                    for line in response.lines
                        msg.send line.name + ' - ' + line.status
            )
        )
