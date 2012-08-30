fs      = require 'fs'
path    = require 'path'
async   = require 'async'
{print} = require 'util'
{spawn} = require 'child_process'

testCodes  = []

task 'build', 'Build project', ->
  build()

task 'test', 'Run tests', ->
  build -> test

build = (callback) ->
  builder = (src, dest) ->
    (callback) ->
      coffee = spawn 'coffee', ['-c', '-o', dest, src]
      coffee.stderr.on 'data', (data) -> process.stderr.write data.toString()
      coffee.stdout.on 'data', (data) -> print data.toString()
      coffee.on 'exit', (code) -> callback?(code,code)
  async.parallel [
    builder('src','lib'),
    builder('test/src','test/lib')
  ], (err, results) -> callback?() unless err

test = (callback) ->
  testDir = './test'
  testFiles = (file for file in fs.readdirSync testDir when /.*\.html$/.test(file))
  remaining = testFiles.length
  for file in testFiles
    filePath = fs.realpathSync "#{testDir}/#{file}"
    phantomjs = spawn 'phantomjs', ['test/lib/run-jasmine.phantom.js', "file://#{filePath}"]
    phantomjs.stdout.on 'data', (data) -> 
      print data.toString()
    phantomjs.on 'exit', (code) ->
      testCodes.push code
      callback?() if --remaining is 0
  exitWithTestsCode()

exitWithTestsCode = ->
  process.once 'exit', ->
    passed = testCodes.every (code) -> code is 0
    process.exit if passed then 0 else 1  
  exitWithTestsCode = ->

