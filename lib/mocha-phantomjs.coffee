system  = require 'system'
webpage = require 'webpage'

USAGE = """
        Usage: phantomjs run-mocha.coffee URL [timeout]
        """


class Reporter

  constructor: (@ui, @reporter) ->
    @url      = system.args[1]
    @timeout  = system.args[2] or 6000
    @fail(USAGE) unless @url

  run: ->
    @initPage()
    @loadPage()

  # Subclass Hooks

  injectJS: ->
    @page.injectJs 'mocha-phantomjs/core_extensions.js'

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
    @fail 'Failed to load the page. Check the url'

  runMocha: ->
    @page.evaluate @runner, @ui, @reporter
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

  runner: (ui, reporter) ->
    mocha.setup ui: ui, reporter: reporter
    mocha.phantomjs = failures: 0, ended: false
    mocha.run().on 'end', ->
      mocha.phantomjs.failures = @failures
      mocha.phantomjs.ended = true


class Spec extends Reporter

  constructor: ->
    super 'bdd', 'spec'


reporter = new Spec
reporter.run()


# @page.onInitialized = =>
#   @page.injectJs 'mocha-phantomjs/core_extensions.js'
# @page.onResourceRequested = (resource) -> 
#   console.log(JSON.stringify(resource))


