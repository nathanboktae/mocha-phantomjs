system  = require 'system'
webpage = require 'webpage'

USAGE = """
        Usage: phantomjs run-mocha.coffee URL REPORTER
        """

class Reporter

  constructor: (@reporter) ->
    @url      = system.args[1]
    @timeout  = 6000
    @fail(USAGE) unless @url

  run: ->
    @initPage()
    @loadPage()

  # Subclass Hooks

  didInjectCoreExtensions: ->
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
    @page.injectJs 'mocha-phantomjs/core_extensions.js'
    @didInjectCoreExtensions()

  runMocha: ->
    @page.evaluate @runner, @reporter
    @defer => @page.evaluate -> mocha.phantomjs?.ended    

  defer: (test) ->
    start = new Date().getTime()
    testStart = new Date().getTime()
    passed = false
    func = =>
      if new Date().getTime() - start < @timeout and !passed
        passed = test()
      else
        if !passed
          @fail 'Timeout passed before the tests finished.'
        else
          clearInterval(interval)
          @finish()
    interval = setInterval(func, 100)

  runner: (reporter) ->
    mocha.setup reporter: reporter
    mocha.phantomjs = failures: 0, ended: false
    mocha.run().on 'end', ->
      mocha.phantomjs.failures = @failures
      mocha.phantomjs.ended = true

class Spec extends Reporter

  constructor: ->
    super 'spec'

  didInjectCoreExtensions: ->
    @page.evaluate -> 
      process.cursor.CRMatcher = /\s+◦\s\w/
      process.cursor.CRCleaner = process.cursor.up + process.cursor.deleteLine

class Dot extends Reporter

  constructor: ->
    super 'dot'

  didInjectCoreExtensions: ->
    @page.evaluate ->
      process.stdout.write = (string) ->
        if string.match /\u001b\[\d\dm\․\u001b\[0m/
          ++process.cursor.count
          forward = process.cursor.count + 2
          string = process.cursor.up + process.cursor.forwardN(forward) + string
        console.log string

reporterString = system.args[2] || 'spec'
reporterString = reporterString.charAt(0).toUpperCase() + reporterString.slice(1)
reporterKlass  = eval(reporterString)

reporter = new reporterKlass
reporter.run()


