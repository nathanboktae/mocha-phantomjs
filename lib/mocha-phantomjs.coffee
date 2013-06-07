system  = require 'system'
webpage = require 'webpage'

USAGE = """
        Usage: phantomjs mocha-phantomjs.coffee URL REPORTER [CONFIG]
        """

class Reporter

  constructor: (@reporter, @config) ->
    @url = system.args[1]
    @columns = parseInt(system.env.COLUMNS or 75) * .75 | 0
    @mochaStarted = false
    @mochaStartWait = @config.timeout || 6000
    @startTime = Date.now()
    @fail(USAGE) unless @url

  run: ->
    @initPage()
    @loadPage()

  customizeMocha: (options) ->
    Mocha.reporters.Base.window.width = options.columns
  
  customizeOptions: ->
    columns: @columns

  # Private

  fail: (msg, errno) ->
    console.log msg if msg
    phantom.exit errno || 1

  finish: ->
    phantom.exit @page.evaluate -> mochaPhantomJS.failures

  initPage: ->
    @page = webpage.create
      settings: @config.settings
    @page.customHeaders = @config.headers if @config.headers
    @page.addCookie(cookie) for cookie in @config.cookies
    @page.viewportSize = @config.viewportSize if @config.viewportSize
    @page.onConsoleMessage = (msg) -> system.stdout.writeLine(msg)
    @page.onError = (msg, traces) =>
      for {line, file}, index in traces
        traces[index] = "  #{file}:#{line}"
      @fail "#{msg}\n\n#{traces.join '\n'}"
    @page.onInitialized = =>
      @page.evaluate ->
        window.mochaPhantomJS =
          failures: 0
          ended: false
          started: false
          run: ->
            mochaPhantomJS.started = true
            window.callPhantom 'mochaPhantomJS.run': true

  loadPage: ->
    @page.open @url
    @page.onLoadFinished = (status) =>
      @page.onLoadFinished = ->
      @onLoadFailed() if status isnt 'success'
      @waitForInitMocha()
    @page.onCallback = (data) =>
      if data.hasOwnProperty 'process.stdout.write'
        system.stdout.write data['process.stdout.write']
      else if data.hasOwnProperty 'mochaPhantomJS.run'
        @waitForRunMocha() if @injectJS()
      true

  onLoadFailed: ->
    @fail "Failed to load the page. Check the url: #{@url}"

  injectJS: ->
    if @page.evaluate(-> window.mocha?)
      @page.injectJs 'mocha-phantomjs/core_extensions.js'
      @page.evaluate @customizeMocha, @customizeOptions()
      true
    else
      @fail "Failed to find mocha on the page."
      false

  runMocha: ->
    if @config.useColors is false then @page.evaluate -> Mocha.reporters.Base.useColors = false
    @page.evaluate @runner, @reporter
    @mochaStarted = @page.evaluate -> mochaPhantomJS.runner or false
    if @mochaStarted
      @mochaRunAt = new Date().getTime()
      @waitForMocha()
    else
      @fail "Failed to start mocha."

  waitForMocha: =>
    ended = @page.evaluate -> mochaPhantomJS.ended
    if ended then @finish() else setTimeout @waitForMocha, 100

  waitForInitMocha: =>
    setTimeout @waitForInitMocha, 100 unless @checkStarted()

  waitForRunMocha: =>
    if @checkStarted() then @runMocha() else setTimeout @waitForRunMocha, 100

  checkStarted: =>
    started = @page.evaluate -> mochaPhantomJS.started
    if !started && @mochaStartWait && @startTime + @mochaStartWait < Date.now()
      @fail "Failed to start mocha: Init timeout", 255
    started

  runner: (reporter) ->
    try
      mocha.setup reporter: reporter
      mochaPhantomJS.runner = mocha.run()
      if mochaPhantomJS.runner
        cleanup = ->
          mochaPhantomJS.failures = mochaPhantomJS.runner.failures
          mochaPhantomJS.ended = true
        if mochaPhantomJS.runner?.stats?.end
          cleanup()
        else
          mochaPhantomJS.runner.on 'end', cleanup
    catch error
      false



reporter = system.args[2] || 'spec'
config   = JSON.parse system.args[3] || '{}'

mocha = new Reporter reporter, config
mocha.run()

