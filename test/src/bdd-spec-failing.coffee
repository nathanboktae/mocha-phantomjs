expect = chai?.expect or require('chai').expect

describe 'BDD Spec Failing', ->

  it 'passes 1', -> expect(1).to.be.ok
  it 'passes 2', -> expect(2).to.be.ok
  it 'passes 3', -> expect(3).to.be.ok

  it 'fails 1', -> expect(false).to.be.true
  it 'fails 2', -> expect(false).to.be.true
  it 'fails 3', -> expect(false).to.be.true

