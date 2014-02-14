module.exports = (robot) ->
    robot.hear /!nick (.+)/i, (msg) ->
        nick = msg.match[1]
        # Disabled
        #robot.adapter.command('NICK', nick)
    robot.hear /(any|every)(one|body)/i, (msg) ->
        name = msg.message.user.name
        sender = robot.brain.userForName name

        users = robot.brain.users()
        nicks = []
        for k, user of users
            if (user.name != sender.name && user.name != 'Hubot' && user.name != 'Shell')
                nicks.push(user.name)

        nicks = nicks.join(', ')
        # msg.send "Everyone, #{sender.name} is desperate for attention."
