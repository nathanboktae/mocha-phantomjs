describe 'mocha-phantomjs', ->

  chai = require 'chai'
  expect = chai.expect
  should = chai.should()
  spawn  = require('child_process').spawn
  url    = require 'url'
  fs     = require 'fs'

  fileURL = (file) ->
    fullPath = fs.realpathSync "#{process.cwd()}/test/#{file}.html"
    fullPath = fullPath.replace /\\/g, '\/'
    urlString = fullPath
    urlString = url.format { protocol: 'file', hostname: '', pathname: fullPath } if process.platform isnt 'win32'

  run = (args) ->
    new Promise (resolve, reject) ->
      stdout = ''
      stderr = ''
      spawnArgs = ["#{process.cwd()}/bin/mocha-phantomjs"].concat(args)
      mochaPhantomJS = spawn 'node', spawnArgs
      mochaPhantomJS.stdout.on 'data', (data) -> stdout = stdout.concat data.toString()
      mochaPhantomJS.stderr.on 'data', (data) -> stderr = stderr.concat data.toString()
      mochaPhantomJS.on 'exit', (code) ->
        resolve { code, stdout, stderr }
      mochaPhantomJS.on 'error', (err) -> reject err

  it 'returns a failure code and shows usage when no args are given', ->
    { code, stdout } = yield run []
    code.should.equal 1
    stdout.should.match /Usage: mocha-phantomjs/

  it 'returns a failure code and notifies of bad url when given one', ->
    { code, stderr } = yield run ['foo/bar.html']
    code.should.equal 1
    stderr.should.match /failed to load the page/i
    stderr.should.match /check the url/i
    stderr.should.match /foo\/bar.html/i

  it 'returns a failure code and notifies of no such runner class', ->
    { code, stderr } = yield run ['-R', 'nonesuch', fileURL('passing')]
    code.should.equal 1
    stderr.should.match /Unable to open file 'nonesuch'/

  it 'returns a failure code when mocha fails to run any tests', ->
    { code, stderr } = yield run [fileURL('no-tests')]
    code.should.equal 1
    stderr.should.match /mocha.run\(\) was called with no tests/

  it 'returns a failure code when mocha is not started in a timely manner', ->
    { code, stderr } = yield run ['-t', 500, fileURL('timeout')]
    stderr.should.match /mocha.run\(\) was not called within 500ms of the page loading/
    code.should.not.equal 0

  it 'returns a failure code when there is a page error', ->
    { code, stderr } = yield run [fileURL('error')]
    code.should.equal 1
    stderr.should.match /ReferenceError/

  it 'does not fail when console.log is used with circular reference object', ->
    { code, stdout, stderr } = yield run [fileURL('console-log')]
    code.should.equal 0
    stderr.should.not.match /cannot serialize cyclic structures\./m
    stdout.should.not.match /cannot serialize cyclic structures\./m
    stdout.should.contain '[Circular]'

  it 'returns the mocha runner from run() and allows modification of it', ->
    { code, stdout } = yield run [fileURL('mocha-runner')]
    stdout.should.not.match /Failed via an Event/m
    code.should.equal 1

  it 'returns the mocha runner from run() and allows modification of it', ->
    { code, stdout } = yield run [fileURL('mocha-runner')]
    stdout.should.not.match /Failed via an Event/m
    code.should.equal 1

  it 'passes the arguments along to mocha.run', ->
    { stdout } = yield run [fileURL('mocha-runner')]
    stdout.should.match /Run callback fired/m

  it 'passes all unknown arguments to phantomjs', ->
    { stderr } = yield run ['--unknown=true', fileURL('mocha-runner')]
    stderr.should.match /Error: Unknown option: unknown/m

  it 'can use a different reporter', ->
    { stdout } = yield run ['-R', 'xunit', fileURL('mixed')]
    stdout.should.match /<testcase classname="Tests Mixed" name="passes 1" time=".*"\/>/

  it 'does not allow phantomjs >= 1.9.8 < 2 due to ariya/phantomjs#12697', ->
    { stdout, stderr } = yield run ['-R', 'xunit', fileURL('no-tests')]
    stdout.should.not.contain 'Unsafe JavaScript attempt'
    stderr.should.not.contain 'Unsafe JavaScript attempt'

  describe 'exit code', ->
    it 'returns 0 when all tests pass', ->
      { code } = yield run fileURL('passing')
      code.should.equal 0

    it 'returns a failing code equal to the number of mocha failures', ->
      { code } = yield run fileURL('failing')
      code.should.equal 3

    it 'returns a failing code correctly even with async failing tests', ->
      { code } = yield run fileURL('failing-async')
      code.should.equal 3

  describe 'screenshot', ->
    it 'takes a screenshot into given file, suffixed with .png', ->
      { code } = yield run fileURL('screenshot')
      code.should.equal 0
      fileName = 'screenshot.png'
      fs.existsSync(fileName).should.be.true
      fs.unlinkSync(fileName)

  describe 'third party reporters', ->
    it 'loads and wraps node-style reporters to run in the browser', ->
      { stdout } = yield run ['-R', 'test/reporters/3rd-party', fileURL('mixed')]

      stdout.should.match /<section class="suite">/
      stdout.should.match /<h1>Tests Mixed<\/h1>/

    it 'gives a useful error when trying to require a node module', ->
      { code, stderr } = yield run ['-R', 'test/reporters/node-only', fileURL('mixed')]

      stderr.should.match /Node modules cannot be required/
      code.should.not.equal 0

  describe 'hooks', ->
    it 'should fail gracefully if they do not exist', ->
      { code, stderr } = yield run ['-k', 'nonexistant-file.js', fileURL('passing')]

      code.should.not.equal 0
      stderr.should.contain('Error loading hooks').and.contain "nonexistant-file.js"

    it 'has a hook for before tests are started', ->
      { code, stdout } = yield run ['-k', 'test/hooks/before-start.js', fileURL('passing')]

      stdout.should.contain 'Before start called!'
      code.should.equal 0

    it 'has a hook for after the test run finishes', ->
      { code, stdout } = yield run ['-k', 'test/hooks/after-end.js', fileURL('passing')]

      stdout.should.contain 'After end called!'
      code.should.equal 0

  describe 'parameters', ->
    describe 'user-agent', ->
      it 'has the default user agent', ->
        { stdout } = yield run [fileURL('user-agent')]
        stdout.should.match /PhantomJS\//

      it 'has a custom user agent', ->
        { stdout } = yield run ['-A', 'mochaUserAgent', fileURL('user-agent')]
        stdout.should.match /^mochaUserAgent/

      it 'has a custom user agent via setting flag and 2 equal signs', ->
        { stdout } = yield run ['-s', 'userAgent=mocha=UserAgent', fileURL('user-agent')]
        stdout.should.match /^mocha=UserAgent/

    describe 'cookies', ->
      it 'has passed cookies', ->
        c1Opt = '{"name":"foo","value":"bar"}'
        c2Opt = '{"name":"baz","value":"bat","path":"/"}'
        { stdout } = yield run ['-c', c1Opt, '--cookies', c2Opt, fileURL('cookie')]
        stdout.should.match /foo=bar; baz=bat/

    describe 'viewport', ->
      it 'has the specified dimensions', ->
        { stdout } = yield run ['-v', '123x456', fileURL('viewport')]
        stdout.should.match /123x456/

    describe 'grep', ->
      it 'filters tests to match the criteria', ->
        { code, stdout } = yield run ['-g', 'pass', fileURL('mixed')]
        code.should.equal 0
        stdout.should.not.match /fail/

      it 'can be inverted to filter out tests matching the criteria', ->
        { code, stdout } = yield run ['--grep', 'pass', '-i', fileURL('mixed')]
        code.should.equal 6
        stdout.should.not.match /passes/

    describe 'no-colors', ->
      it 'by default will output in color', ->
        { stdout } = yield run ['-R', 'dot', fileURL('mixed')]

        stdout.should.match /\u001b\[90m\․\u001b\[0m/ # grey
        stdout.should.match /\u001b\[36m\․\u001b\[0m/ # cyan
        stdout.should.match /\u001b\[31m\․\u001b\[0m/ # red

      it 'suppresses color output', ->
        { stdout } = yield run ['-C', fileURL('mixed')]
        stdout.should.not.match /\u001b\[\d\dm/

      it 'suppresses color output plural long form', ->
        { stdout } = yield run ['--no-colors', fileURL('mixed')]
        stdout.should.not.match /\u001b\[\d\dm/

    describe 'bail', ->
      it 'should bail on the first error', ->
        { stdout } = yield run ['-b', fileURL('mixed')]
        stdout.should.contain '1 failing'

    describe 'path', ->
      it 'will use the custom path to phantomjs', ->
        { stderr } = yield run ['-p', 'fake/path/to/phantomjs', fileURL('passing')]
        stderr.should.contain "PhantomJS does not exist at 'fake/path/to/phantomjs'"

      it 'provides a useful error when phantomjs cannot be launched', ->
        { stderr } = yield run ['-p', 'package.json', fileURL('passing')]
        stderr.should.contain "An error occurred trying to launch phantomjs"

    describe 'file', ->
      it 'pipes reporter output to a file', ->
        { stdout } = yield run ['-f', 'reporteroutput.json', '-R', 'json', fileURL('file')]
        stdout.should.contain 'Extraneous'
        results = JSON.parse fs.readFileSync 'reporteroutput.json', { encoding: 'utf8' }
        results.passes.length.should.equal 6
        results.failures.length.should.equal 6

      after ->
        fs.unlinkSync 'reporteroutput.json'

    describe 'ignore resource errors', ->
      it 'by default shows resource errors', ->
        { code, stderr } = yield run [fileURL('resource-errors')]
        stderr.should.contain('Error loading resource').and.contain('nonexistant-file.css')
        code.should.equal 0

      it 'can suppress resource errors', ->
        { stderr } = yield run ['--ignore-resource-errors', fileURL('resource-errors')]
        stderr.should.be.empty

  describe 'env', ->
    it 'has passed environment variables', ->
      process.env.FOO = 'yowzer'
      { stdout } = yield run [fileURL('env')]
      stdout.should.match /^yowzer/
