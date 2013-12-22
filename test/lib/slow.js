expect = (chai && chai.expect) || require('chai').expect;

describe('Slow tests', function() {
  it('display test start events', function(done) {
    setTimeout((function() {
      done();
    }), 1862);
    expect(true).to.be.true;
  });

  it('and are correctly overwritten', function(done) {
    setTimeout((function() {
      expect(true).to.be.true;
      done();
    }), 1538);
  });

  it('with pass or fail output', function(done) {
    setTimeout((function() {
      done();
    }), 1239);
    expect(true).to.be.true;
  });
});