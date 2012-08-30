system  = require 'system'
webpage = require 'webpage'

if system.args.length < 1
  console.log 'Usage: phantomjs run-mocha.coffee URL [timeout]'
  phantom.exit()

url     = system.args[1]
timeout = system.args[2] or 6000

page = webpage.create()
page.onConsoleMessage = (msg) -> console.log(msg)

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
        phantom.exit()
      else
        clearInterval(interval)
        phantom.exit()
  interval = setInterval(func, 100)

fail = ->
  console.log 'Failed to load the page. Check the url'
  phantom.exit()

run = ->
  page.injectJs 'lib/bind.js'
  page.injectJs 'lib/console.js'
  page.injectJs 'lib/process.stdout.write.js'
  page.evaluate ->
    mocha.setup ui: 'bdd', reporter: mocha.reporters.Spec
    mocha.run().on 'end', -> mocha.end = true
  defer -> page.evaluate -> mocha.end

page.open(url)
page.onLoadFinished = (status) ->
  if status isnt 'success' then fail() else run()


