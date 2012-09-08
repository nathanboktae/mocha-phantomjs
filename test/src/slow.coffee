expect = chai?.expect or require('chai').expect

describe 'Slow tests', ->

  it 'display test start events', (done) ->
    setTimeout((-> done()), 1862)
    expect(true).to.be.true

  it 'and are correctly overwritten', (done) ->
    setTimeout((-> done()), 1538)
    expect(true).to.be.true

  it 'with pass or fail output', (done) ->
    setTimeout((-> done()), 1239)
    expect(true).to.be.true
