_ = require('lodash')
browsers = require('../browsers')
os = require('os')

remoteProtractor = _.reduce(browsers, (memo, config, browser) ->
  return _.reduce(['e2e', 'wd'], (memo, test) ->
    options =
      configFile: 'config/protractor.js'
      specs: ["../test/#{test}/*.coffee"]
      args:
        capabilities:
          name: "quill-#{test}"
          platform: config[0]
          browserName: config[1]
          version: config[2]
        sauceUser: process.env.SAUCE_USERNAME
        sauceKey: process.env.SAUCE_ACCESS_KEY
      jasmineNodeOpts:
        isVerbose: false
    if process.env.TRAVIS
      options.args.capabilities.build = 'travis-' + process.env.TRAVIS_BUILD_ID
    else
      options.args.capabilities.build = os.hostname() + '-' + _.random(16*16*16*16).toString(16)
    memo["#{test}-#{browser}"] = { options: options }
    return memo
  , memo)
, {})

module.exports = (grunt) ->
  grunt.config('protractor', _.extend(remoteProtractor,
    coverage:
      options:
        configFile: 'config/protractor.coverage.js'
    test:
      options:
        configFile: 'config/protractor.js'
        specs: ['../test/wd/*.coffee']
    e2e:
      options:
        configFile: 'config/protractor.js'
        specs: ['../test/e2e/*.coffee']
  ))

  grunt.registerMultiTask('webdriver-manager', 'Protractor webdriver manager', ->
    grunt.util.spawn(
      cmd: './node_modules/protractor/bin/webdriver-manager'
      args: [this.target]
      opts:
        stdio: 'inherit'
    , this.async())
  )

  grunt.config('webdriver-manager',
    start: {}
    status: {}
    update: {}
  )
