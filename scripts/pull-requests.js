var url = require('url');
var querystring = require('querystring');

var processPayload = function (payload, robot) {
    var gh_users = robot.brain.get('gh_users') || {};
    if (payload.action === 'closed') {
        var owner = gh_users[payload.pull_request.user.login] || payload.pull_request.user.login;
        var sender = gh_users[payload.sender.login] || payload.sender.login;
        if (!payload.pull_request.merged_at) {
            return owner + ', "' + payload.pull_request.title + '" has just been closed without a merge by ' + sender;
        }
        return owner + ', "' + payload.pull_request.title + '" has just been merged by ' + sender;
    }

    if (payload.action === 'opened') {
        var owner = gh_users[payload.pull_request.user.login] || payload.pull_request.user.login;
        return owner + ' has just submitted a new pull request, "' + payload.pull_request.title + '" - ' + payload.pull_request.html_url;
    }

    return "";
}

module.exports = function (robot) {
    robot.respond(/associate github user (.+) with (.+)/i, function (msg) {
        var github = msg.match[1],
            irc = msg.match[2],
            gh_users = robot.brain.get('gh_users');
        if (!gh_users) {
            gh_users = {};
        }

        gh_users[github] = irc;
        robot.brain.set('gh_users', gh_users);
        msg.send("Got it! Github user '" + github + "' is the same person as '" + irc + "'");
    });

    robot.router.post("/hubot/gh-pull-requests", function (req, res) {
        var query = querystring.parse(url.parse(req.url).query);
        var data = req.body;
        var room = query.room;
        var payload = JSON.parse(data.payload);
        var response = processPayload(payload, robot);

        robot.send({user: {name: 'broadcast', room: room}}, response);
        res.end("github pinged me");
    });
};
