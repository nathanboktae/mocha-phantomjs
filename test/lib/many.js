expect = (chai && chai.expect) || require('chai').expect;

describe('Many Tests', function() {
  for (var n = 1; n <= 500; n++) {
    if (n % 10 === 0) {
      xit('skips ' + n, function() {
        expect(false).to.be.true  
      })
    } else if (n % 100 === 2) {
      it('fails ' + n, function() {
        expect(false).to.be.true  
      })
    } else {
      it('passses ' + n, function() {
        expect(n).to.equal(n)
      })
    }
  }
});