moves = [
    'twerks',
    'dances',
    'boogies',
    'jives',
    'waltzes',
    'body pops',
    'pirouettes',
    'does the electric boogaloo',
    'busts some shapes'
]
module.exports = (robot) ->

    robot.respond /dance with (.+)$/i, (msg) ->
        dance = msg.random moves
        msg.emote dance + ' with ' + msg.match[1]

    robot.respond /dance$/i, (msg) ->
        dance = msg.random moves
        msg.emote dance
