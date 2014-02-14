module.exports = function(robot) {
    var alerts = [
        "Yo",
        "Listen up",
        "Pay attention"
    ];
    robot.respond(/add (.+) to (developers|testers)/i, function (msg) {
        var nick = msg.match[1],
            type = msg.match[2],
            users = robot.brain.get(type);
        if (!users) {
            users = [];
        }
        if(users.indexOf(nick) == -1) {
            users.push(nick);
            robot.brain.set(type, users);
            msg.send("Okay! I've added " + nick + " to " + type);
        } else {
            msg.send("But " + nick + " is already in " + type);
        }
    });
    robot.respond(/remove (.+) from (developers|testers)/i, function (msg) {
        var nick = msg.match[1],
            type = msg.match[2],
            users = robot.brain.get(type),
            index;
        if (!users) {
            users = [];
        }
        if(users.indexOf(nick) == -1) {
            msg.send("But " + nick + " is already in " + type);
            return;
        } else {
            index = users.indexOf(nick);
            users.splice(index, 1);
            robot.brain.set(type, users);
            msg.send("Okay! I've removed " + nick + " from " + type);
        }
    });
    robot.hear(/^(developers|testers)/i, function (msg) {
        var type = msg.match[1],
            users = robot.brain.get(type),
            alert;
        if (!users) {
            users = [];
            msg.send("There aren't any " + type);
            return;
        }

        alert = msg.random(alerts);
        msg.send(alert + "! " + users.join(', '));
    });
    robot.hear(/^(any|every)(one|body)/i, function (msg) {
        var developers = robot.brain.get('developers'),
            testers = robot.brain.get('testers'),
            users = developers.concat(testers),
            alert = msg.random(alerts);

        msg.send(alert + "! " + users.join(', '));
    });
}
