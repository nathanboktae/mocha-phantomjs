system  = require 'system'
webpage = require 'webpage'

USAGE = """
        Usage: phantomjs run-mocha.coffee URL REPORTER
        """

class Reporter

  constructor: (@reporter) ->
    @url = system.args[1]
    @mochaStarted = false
    @mochaStartWait = 6000
    @fail(USAGE) unless @url

  run: ->
    @initPage()
    @loadPage()

  # Subclass Hooks

  customizeProcessStdout: -> 
    undefined

  customizeConsole: ->
    undefined

  # Private

  fail: (msg) ->
    console.log msg if msg
    phantom.exit 1

  finish: ->
    phantom.exit @page.evaluate -> mocha.phantomjs?.failures

  initPage: ->
    @page = webpage.create()
    @page.onConsoleMessage = (msg) -> console.log msg
    @page.onInitialized = => 
      @page.evaluate -> window.mochaPhantomJS = true

  loadPage: ->
    @page.open @url
    @page.onLoadFinished = (status) =>
      if status isnt 'success' then @onLoadFailed() else @onLoadSuccess()

  onLoadSuccess: ->
    @injectJS()
    @runMocha()

  onLoadFailed: ->
    @fail "Failed to load the page. Check the url: #{@url}"

  injectJS: ->
    if @page.evaluate(-> window.mocha?)
      @page.injectJs 'mocha-phantomjs/core_extensions.js'
      @customizeProcessStdout()
      @customizeConsole()
    else
      @fail "Failed to find mocha on the page."

  runMocha: ->
    @page.evaluate @runner, @reporter
    @mochaStarted = @page.evaluate -> mocha?.phantomjs?.run or false
    if @mochaStarted
      @mochaRunAt = new Date().getTime()
      @waitForMocha()
    else
      @fail "Failed to start mocha."
  
  waitForMocha: =>
    ended = @page.evaluate -> mocha.phantomjs?.ended
    if ended then @finish() else setTimeout @waitForMocha, 100

  runner: (reporter) ->
    try
      mocha.setup reporter: reporter
      mocha.phantomjs = failures: 0, ended: false, run: false
      runner = mocha.run()
      if runner
        mocha.phantomjs.run = true
        runner.on 'end', ->
          mocha.phantomjs.failures = @failures
          mocha.phantomjs.ended = true
    catch error
      false

class Spec extends Reporter

  constructor: ->
    super 'spec'

  customizeProcessStdout: ->
    @page.evaluate -> 
      process.stdout.write = (string) ->
        return if string is process.cursor.deleteLine or string is process.cursor.beginningOfLine
        console.log string

  customizeConsole: ->
    @page.evaluate ->
      process.cursor.CRMatcher = /\s+◦\s\w/
      process.cursor.CRCleaner = process.cursor.up + process.cursor.deleteLine
      origLog = console.log
      console.log = ->
        string = console.format.apply(console, arguments)
        if process.cursor.CRMatcher and string.match(process.cursor.CRMatcher)
          process.cursor.CRCleanup = true
        else if process.cursor.CRCleanup and process.cursor.CRCleaner
          string = process.cursor.CRCleaner + string
          process.cursor.CRCleanup = false
        origLog.call console, string

class Dot extends Reporter

  constructor: ->
    super 'dot'

  customizeProcessStdout: ->
    @page.evaluate ->
      process.stdout.write = (string) ->
        if string.match /\u001b\[\d\dm\․\u001b\[0m/
          ++process.cursor.count
          forward = process.cursor.count + 2
          string = process.cursor.up + process.cursor.forwardN(forward) + string
        console.log string

reporterString = system.args[2] || 'spec'
reporterString = reporterString.charAt(0).toUpperCase() + reporterString.slice(1)
reporterKlass  = try
                   eval(reporterString)
                 catch error
                   undefined

if reporterKlass
  reporter = new reporterKlass
  reporter.run()
else
  console.log "Reporter class not implemented: #{reporterString}"
  phantom.exit 1


