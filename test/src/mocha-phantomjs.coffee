describe 'mocha-phantomjs', ->

  expect = require('chai').expect
  spawn  = require('child_process').spawn
  url    = require('url')
  fs     = require('fs')

  fileURL = (file) ->
    fullPath = fs.realpathSync "#{process.cwd()}/test/#{file}.html"
    fullPath = fullPath.replace /\\/g, '\/'
    urlString = url.format { protocol: 'file', hostname: '', pathname: fullPath }
    return urlString

  before ->
    @runner = (done, args, callback) ->
      stdout = ''
      stderr = ''
      spawnArgs = ["#{process.cwd()}/bin/mocha-phantomjs"].concat(args)
      mochaPhantomJS = spawn 'node', spawnArgs
      mochaPhantomJS.stdout.on 'data', (data) -> stdout = stdout.concat data.toString()
      mochaPhantomJS.stderr.on 'data', (data) -> stderr = stderr.concat data.toString()
      mochaPhantomJS.on 'exit', (code) ->
        callback?(code, stdout, stderr)
        done?()

  it 'returns a failure code and shows usage when no args are given', (done) ->
    @runner done, [], (code, stdout, stderr) ->
      expect(code).to.equal 1
      expect(stdout).to.match /Usage: mocha-phantomjs/

  it 'returns a failure code and notifies of bad url when given one', (done) ->
    @runner done, ['foo/bar.html'], (code, stdout, stderr) ->
      expect(code).to.equal 1
      expect(stdout).to.match /failed to load the page/i
      expect(stdout).to.match /check the url/i
      expect(stdout).to.match /foo\/bar.html/i

  it 'returns a failure code and notifies of no such runner class', (done) ->
    @runner done, ['-R', 'nonesuch', fileURL('passing')], (code, stdout, stderr) ->
      expect(code).to.equal 1
      expect(stdout).to.match /Failed to start mocha./

  it 'returns a failure code when mocha can not be found on the page', (done) ->
    @runner done, [fileURL('blank')], (code, stdout, stderr) ->
      expect(code).to.equal 1
      expect(stdout).to.match /Failed to find mocha on the page./

  it 'returns a failure code when mocha fails to start for any reason', (done) ->
    @runner done, [fileURL('bad')], (code, stdout, stderr) ->
      expect(code).to.equal 1
      expect(stdout).to.match /Failed to start mocha./

  it 'returns a failure code when mocha is not started in a timely manner', (done) ->
    @runner done, ['-t', 500, fileURL('timeout')], (code, stdout, stderr) ->
      expect(code).to.equal 255
      expect(stdout).to.match /Failed to start mocha: Init timeout/

  it 'returns a failure code when there is a page error', (done) ->
    @runner done, [fileURL('error')], (code, stdout, stderr) ->
      expect(code).to.equal 1
      expect(stdout).to.match /ReferenceError/

  it 'does not fail when an iframe is used', (done) ->
    @runner done, [fileURL('iframe')], (code, stdout, stderr) ->
      expect(stdout).to.not.match /Failed to load the page\./m
      expect(code).to.equal 0

  describe 'spec', ->

    passRegExp   = (n) -> ///\u001b\[32m\s\s[✔✓]\u001b\[0m\u001b\[90m\spasses\s#{n}///
    skipRegExp   = (n) -> ///\u001b\[36m\s\s-\sskips\s#{n}\u001b\[0m///
    failRegExp   = (n) -> ///\u001b\[31m\s\s#{n}\)\sfails\s#{n}\u001b\[0m///
    passComplete = (n) -> ///\u001b\[0m\n\n\n\u001b\[92m\s\s[✔✓]\u001b\[0m\u001b\[32m\s#{n}\stests\scomplete///
    pendComplete = (n) -> ///\u001b\[36m\s+•\u001b\[0m\u001b\[36m\s#{n}\stests\spending///
    failComplete = (x,y) -> ///\u001b\[91m\s\s✖\u001b\[0m\u001b\[31m\s#{x}\sof\s#{y}\stests\sfailed///

    describe 'passing', ->

      ###
      $ ./bin/mocha-phantomjs -R spec test/passing.html
      $ mocha -r chai/chai.js -R spec --globals chai.expect test/lib/passing.js
      ###

      before ->
        @args = [fileURL('passing')]

      it 'returns a passing code', (done) ->
        @runner done, @args, (code, stdout, stderr) ->
          expect(code).to.equal 0

      it 'writes all output in color', (done) ->
        @runner done, @args, (code, stdout, stderr) ->
          expect(stdout).to.match /Tests Passing/
          expect(stdout).to.match passRegExp(1)
          expect(stdout).to.match passRegExp(2)
          expect(stdout).to.match passRegExp(3)
          expect(stdout).to.match skipRegExp(1)
          expect(stdout).to.match skipRegExp(2)
          expect(stdout).to.match skipRegExp(3)

    describe 'failing', ->

      ###
      $ ./bin/mocha-phantomjs -R spec test/failing.html
      $ mocha -r chai/chai.js -R spec --globals chai.expect test/lib/failing.js
      ###

      before ->
        @args = [fileURL('failing')]

      it 'returns a failing code equal to the number of mocha failures', (done) ->
        @runner done, @args, (code, stdout, stderr) ->
          expect(code).to.equal 3

      it 'writes all output in color', (done) ->
        @runner done, @args, (code, stdout, stderr) ->
          expect(stdout).to.match /Tests Failing/
          expect(stdout).to.match passRegExp(1)
          expect(stdout).to.match passRegExp(2)
          expect(stdout).to.match passRegExp(3)
          expect(stdout).to.match failRegExp(1)
          expect(stdout).to.match failRegExp(2)
          expect(stdout).to.match failRegExp(3)
          expect(stdout).to.match failComplete(3,6)

    describe 'requirejs', ->

      before ->
        @args = [fileURL('requirejs')]

      it 'returns a passing code', (done) ->
        @runner done, @args, (code, stdout, stderr) ->
          expect(code).to.equal 0

      it 'writes all output in color', (done) ->
        @runner done, @args, (code, stdout, stderr) ->
          expect(stdout).to.match /Tests Passing/
          expect(stdout).to.match passRegExp(1)
          expect(stdout).to.match passRegExp(2)
          expect(stdout).to.match passRegExp(3)
          expect(stdout).to.match skipRegExp(1)
          expect(stdout).to.match skipRegExp(2)
          expect(stdout).to.match skipRegExp(3)

  describe 'dot', ->

    ###
    $ ./bin/mocha-phantomjs -R dot test/mixed.html
    $ mocha -r chai/chai.js -R dot --globals chai.expect test/lib/mixed.js
    ###

    before ->
      @args = ['-R', 'dot', fileURL('mixed')]

    it 'uses dot reporter', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        expect(stdout).to.match /\u001b\[90m\․\u001b\[0m/ # grey
        expect(stdout).to.match /\u001b\[36m\․\u001b\[0m/ # cyan
        expect(stdout).to.match /\u001b\[31m\․\u001b\[0m/ # red

    ###
    $ ./bin/mocha-phantomjs -R dot test/many.html
    $ mocha -r chai/chai.js -R dot --globals chai.expect test/lib/many.js
    ###

    before ->
      @args = ['-R', 'dot', fileURL('many')]

    it 'wraps lines correctly and has only one double space for the last dot', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        matches = stdout.match /\d\dm\․\u001b\[0m(\r\n\r\n|\n\n)/g
        expect(matches.length).to.equal 1

  describe 'tap', ->

    ###
    $ ./bin/mocha-phantomjs -R tap test/mixed.html
    $ mocha -r chai/chai.js -R tap --globals chai.expect test/lib/mixed.js
    ###

    before ->
      @args = ['-R', 'tap', fileURL('mixed')]

    it 'basically works', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        expect(stdout).to.match /Tests Mixed/

  describe 'list', ->

    ###
    $ ./bin/mocha-phantomjs -R list test/mixed.html
    $ mocha -r chai/chai.js -R list --globals chai.expect test/lib/mixed.js
    ###

    before ->
      @args = ['-R', 'list', fileURL('mixed')]

    it 'basically works', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        expect(stdout).to.match /Tests Mixed/

  describe 'doc', ->

    ###
    $ ./bin/mocha-phantomjs -R doc test/mixed.html
    $ mocha -r chai/chai.js -R doc --globals chai.expect test/lib/mixed.js
    ###

    before ->
      @args = ['-R', 'doc', fileURL('mixed')]

    it 'basically works', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        expect(stdout).to.match /<h1>Tests Mixed<\/h1>/


  describe 'xunit', ->

    ###
    $ ./bin/mocha-phantomjs -R xunit test/mixed.html
    $ mocha -r chai/chai.js -R xunit --globals chai.expect test/lib/mixed.js
    ###

    before ->
      @args = ['-R', 'xunit', fileURL('mixed')]

    it 'basically works', (done) ->
      @runner done, @args, (code, stdout, stderr) ->
        expect(stdout).to.match /<testcase classname="Tests Mixed" name="passes 1" time=".*"\/>/


  describe 'config', ->

    describe 'user-agent', ->

      ###
      $ ./bin/mocha-phantomjs -R spec test/user-agent.html
      ###

      it 'has the default user agent', (done) ->
        @runner done, [fileURL('user-agent')], (code, stdout, stderr) ->
          expect(stdout).to.match /PhantomJS\//

      it 'has a custom user agent', (done) ->
        @runner done, ['-A', 'cakeUserAgent', fileURL('user-agent')], (code, stdout, stderr) ->
          expect(stdout).to.match /^cakeUserAgent/

      it 'has a custom user agent via setting flag', (done) ->
        @runner done, ['-s', 'userAgent=cakeUserAgent', fileURL('user-agent')], (code, stdout, stderr) ->
          expect(stdout).to.match /^cakeUserAgent/

    describe 'cookies', ->

      ###
      $ ./bin/mocha-phantomjs -R spec test/cookie.html
      ###

      it 'has passed cookies', (done) ->
        c1Opt = '{"name":"foo","value":"bar"}'
        c2Opt = '{"name":"baz","value":"bat","path":"/"}'
        @runner done, ['-c', c1Opt, '--cookies', c2Opt, fileURL('cookie')], (code, stdout, stderr) ->
          expect(stdout).to.match /foo=bar; baz=bat/

    describe 'viewport', ->

      ###
      $ ./bin/mocha-phantomjs -R spec test/viewport.html
      ###

      it 'has passed cookies', (done) ->
        @runner done, ['-v', '123x456', fileURL('viewport')], (code, stdout, stderr) ->
          expect(stdout).to.match /123x456/

    describe 'no-colors', ->

      it 'suppresses color output', (done) ->
        @runner done, ['-C', fileURL('mixed')], (code, stdout, stderr) ->
          expect(stdout).to.not.match /\u001b\[\d\dm/
