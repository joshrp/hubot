module.exports = (robot) ->
    robot.hear /!nick (.+)/i, (msg) ->
        nick = msg.match[1]
        robot.adapter.command('NICK', nick)
