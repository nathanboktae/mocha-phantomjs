define(
  ['passing'],
  (require) ->
    if window.mochaPhantomJS
      mochaPhantomJS.run()
    else
      mocha.run()
)
