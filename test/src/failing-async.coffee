expect = chai?.expect or require('chai').expect

describe 'Async Tests Failing', ->

  it 'passes 1', -> expect(1).to.be.ok
  it 'passes 2', -> expect(2).to.be.ok
  it 'passes 3', -> expect(3).to.be.ok

  it 'fails 1', (done) ->
    test = ->
      expect(false).to.be.true
      done()
    setTimeout test, 0

  it 'fails 2', (done) ->
    test = ->
      expect(false).to.be.true
      done()
    setTimeout test, 0

  it 'fails 3', (done) ->
    test = ->
      expect('false').to.equal('true')
      done()
    setTimeout test, 0


