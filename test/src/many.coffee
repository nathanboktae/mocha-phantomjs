expect = chai?.expect or require('chai').expect

describe 'Many Tests', ->

  for n in [1..500]
    skip = n % 10 is 0
    fail = n % 100 is 0
    if fail
      it "fails #{n}", -> expect(false).to.be.true
    else if skip
      it.skip "skips #{n}", -> 
    else
      it "passes #{n}", -> expect(n).to.equal n

