# Description:
#   Looks up jira issues when they're mentioned in chat
#
#   Will ignore users set in HUBOT_JIRA_ISSUES_IGNORE_USERS (by default, JIRA and GitHub).
#
# Dependencies:
#   None
#
# Configuration:
#   HUBOT_JIRA_URL (format: "https://jira-domain.com:9090")
#   HUBOT_JIRA_IGNORECASE (optional; default is "true")
#   HUBOT_JIRA_USERNAME (optional)
#   HUBOT_JIRA_PASSWORD (optional)
#   HUBOT_JIRA_ISSUES_IGNORE_USERS (optional, format: "user1|user2", default is "jira|github")
#
# Commands:
# 
# Author:
#   stuartf

https = require 'https'
fs = require 'fs'

defaultOptions =
    hostname: process.env.HUBOT_JIRA_URL,
    port: 443,
    method: 'GET',
    ca: fs.readFileSync(process.env.HUBOT_JIRA_CA) ,
    key: fs.readFileSync(process.env.HUBOT_JIRA_CERT),
    cert: fs.readFileSync(process.env.HUBOT_JIRA_CERT),
    agent: false,
    rejectUnauthorized: false

getIssue = (ticket, msg) ->
    options = defaultOptions
    options.path = "/rest/api/latest/issue/#{ticket}"
    req = https.request(options, (res) ->
        data = ""
        res.on('data', (d) -> 
            data += d
        )
        res.on('end', () ->
            if (res.statusCode != 200)
                msg.send "That ticket doesnt exist..."
            else
                content = JSON.parse(data)
                msg.send "#{content.fields.summary} - [ https://#{defaultOptions.hostname}/browse/#{ticket} ]"
        )
    )
    req.end()

module.exports = (robot) ->

    robot.hear /(^|[^-])([0-9]{4,5})/i, (msg) ->
        getIssue('IPLAYER-' + msg.match[2], msg)

    robot.hear /\b([a-z]+-[0-9]+)\b/i, (msg) ->
        getIssue(msg.match[1], msg)
