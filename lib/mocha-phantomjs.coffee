system  = require 'system'
webpage = require 'webpage'

fail   = -> phantom.exit 1
finish = (failures) -> phantom.exit failures

if system.args.length < 2
  console.log 'Usage: phantomjs run-mocha.coffee URL [timeout]'
  fail()

url     = system.args[1]
timeout = system.args[2] or 6000

page = webpage.create()
page.onConsoleMessage = (msg) -> console.log(msg)
page.onInitialized = -> page.evaluate -> window.mochaPhantomJS = true
  
# page.onInitialized = ->
#   page.injectJs '../src/bind.js'
#   page.injectJs '../src/console.js'
#   page.injectJs '../src/process.stdout.write.js'
# page.onResourceRequested = (resource) -> console.log(JSON.stringify(resource))

defer = (test) ->
  start = new Date().getTime()
  testStart = new Date().getTime()
  condition = false
  func = ->
    if new Date().getTime() - start < timeout and !condition
      condition = test()
    else
      if !condition
        console.log 'Timeout passed before the tests finished.'
        fail()
      else
        clearInterval(interval)
        finish page.evaluate -> mocha.failures
  interval = setInterval(func, 100)

run = ->
  page.injectJs 'mocha-phantomjs.js'
  page.evaluate ->
    mocha.setup ui: 'bdd', reporter: 'spec' # dot, spec
    mocha.phantomjs = failures: 0, ended: false
    mocha.run().on 'end', ->
      mocha.phantomjs.failures = @failures
      mocha.phantomjs.ended = true
  defer -> page.evaluate -> mocha.phantomjs.ended

page.open(url)
page.onLoadFinished = (status) ->
  if status isnt 'success' 
    console.log 'Failed to load the page. Check the url'
    fail()
  else 
    run()


