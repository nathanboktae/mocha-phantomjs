expect = chai?.expect or require('chai').expect

describe 'Many Passing', ->

  for n in [1..500]
    it "passes #{n}", -> expect(n).to.equal n

