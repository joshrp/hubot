// Description:
//   Commands to alert people in the room
// Commands:
//   hubot logs for (.*)(int|test|stage|live)
module.exports = function(robot) {
    var logAddress = "https://logs.forge.bbc.co.uk/tail/tail/{{env}}/service-pal-{{env}}-app-logs/pal/bbc.co.uk/{{project}}/error_log?lines=100";
    robot.respond(/logs for (.*)(int|test|stage|live)/i, function (msg) {
        var project = msg.match[1].replace(/[^a-z0-9]*/gi, '') || 'tviplayer',
            environment = msg.match[2],
            log = logAddress.replace(/{{env}}/g, environment).replace('{{project}}', project);

        msg.send('Here you go ' + log);
    });
    robot.hear(/canada/i, function (msg) {
        msg.send('Eh?');
    });
}
