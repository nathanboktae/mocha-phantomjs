describe 'mocha-phantomjs', ->

  expect = require('chai').expect
  spawn  = require('child_process').spawn

  before ->
    @runner = (done, args, callback) ->
      stdout = ''
      stderr = ''
      args.unshift 'lib/mocha-phantomjs.coffee'
      phantomjs = spawn 'phantomjs', args
      phantomjs.stdout.on 'data', (data) -> stdout = stdout.concat data.toString()
      phantomjs.stderr.on 'data', (data) -> stderr = stderr.concat data.toString()
      phantomjs.on 'exit', (code) -> 
        callback?(code, stdout, stderr)
        done?()

  it 'shows usage when no args are given', (done) ->
    @runner done, [], (code, stdout, stderr) ->
      expect(code).to.equal 1
      expect(stdout).to.match /Usage:/


