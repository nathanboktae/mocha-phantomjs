expect = chai?.expect or require('chai').expect

describe 'Many Passing', ->

  for n in [1..500]
    pass = if n < 10 then true else n % 10
    if pass
      it "passes #{n}", -> expect(n).to.equal n
    else
      it.skip "skips #{n}", -> 

