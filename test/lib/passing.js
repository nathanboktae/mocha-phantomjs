expect = (chai && chai.expect) || require('chai').expect;

describe('Tests Passing', function() {
  it('passes 1', function() {
    expect(1).to.be.ok;
  });
  it('passes 2', function() {
    expect(2).to.be.ok;
  });
  it('passes 3', function() {
    expect(3).to.be.ok;
  });

  xit('skips 1', function() {
    expect(false).to.be.true;
  });
  xit('skips 2', function() {
    expect(false).to.be.true;
  });
  xit('skips 3', function() {
    expect(false).to.be.true;
  });
});