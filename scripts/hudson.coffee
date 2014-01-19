querystring = require 'querystring'
fs = require 'fs'
https = require 'https'
querystring = require 'querystring'

# Holds a list of jobs, so we can trigger them with a number
# instead of the job's name. Gets populated on when calling
# list.
jobList = []

defaultOptions =
    port: 443,
    method: 'GET',
    ca: fs.readFileSync(process.env.HUBOT_HUDSON_CA) ,
    key: fs.readFileSync(process.env.HUBOT_HUDSON_CERT),
    cert: fs.readFileSync(process.env.HUBOT_HUDSON_CERT),
    agent: false,
    rejectUnauthorized: false

hudsonGetDefaults = (job, env, callback) ->
    path = "/hudson/view/iPlayer/job/#{job}/api/json"
    options = defaultOptions
    if (env == 'int')
        options.hostname = process.env.HUBOT_HUDSON_INT_URL
    else
        options.hostname = process.env.HUBOT_HUDSON_TEST_URL
    options.path = path
    req = https.request(options, (res) ->
        data = ""
        res.on('data', (d) ->
            data += d
        )
        res.on('end', () ->
            content = JSON.parse(data)
            qs = ""
            if (content.actions.length)
                definitions = content.actions[0].parameterDefinitions
                params = {}
                for param in definitions
                    params[param.name] = param.defaultParameterValue.value
                qs = querystring.stringify(params)
            callback(qs)
        )
    )
    req.end()

hudsonBuild = (msg, buildWithEmptyParameters) ->
    job = querystring.escape msg.match[1]
    env = msg.match[2]
    hudsonGetDefaults(job, env, (params) ->
        path = if params then "/hudson/job/#{job}/buildWithParameters?#{params}" else "/hudson/job/#{job}/build"

        options = defaultOptions
        if (env == 'int')
            options.hostname = process.env.HUBOT_HUDSON_INT_URL
        else
            options.hostname = process.env.HUBOT_HUDSON_TEST_URL
        options.path = path
        options.method = 'POST'
        req = https.request(options, (res) ->
            data = ""
            res.on('data', (d) ->
                data += d
            )
            res.on('end', () ->
                if (200 <= res.statusCode < 400)
                    msg.reply "(#{res.statusCode}) Build started for #{job} #{options.hostname}/job/#{job}"
                else if 400 == res.statusCode
                    hudsonBuild(msg, true)
                else
                    msg.reply "Hudson says: Status #{res.statusCode} #{data}"
            )
        )
        req.end()
    )

hudsonList = (msg) ->
    filter = new RegExp(msg.match[2], 'i')
    env = msg.match[3]
    options = defaultOptions
    if (env == 'int')
        options.hostname = process.env.HUBOT_HUDSON_INT_URL
    else
        options.hostname = process.env.HUBOT_HUDSON_TEST_URL

    options.path = '/hudson/view/iPlayer/api/json'
    req = https.request(options, (res) ->
        data = ""
        res.on('data', (d) ->
            data += d
        )
        res.on('end', () ->
            response = ""
            content = JSON.parse(data)
            for job in content.jobs
              # Add the job to the jobList
              index = jobList.indexOf(job.name)
              if index == -1
                jobList.push(job.name)
                index = jobList.indexOf(job.name)

              state = if job.color == "red" then "FAIL" else "PASS"
              if filter.test job.name
                response += "[#{index + 1}] #{state} #{job.name}\n"
            msg.send response
        )
    )
    req.end()

module.exports = (robot) ->

    robot.respond /h(?:udson)? b(?:uild)? ([\w\.\-_ ]+) (int|test)/i, (msg) ->
        hudsonBuild(msg, false)

    robot.respond /h(?:udson)? list( (.+))? (int|test)/i, (msg) ->
        hudsonList(msg)

    robot.hudson = {
        list: hudsonList,
        build: hudsonBuild
    }
