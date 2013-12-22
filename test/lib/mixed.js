expect = (chai && chai.expect) || require('chai').expect;

describe('Tests Mixed', function() {
  it('passes 1', function() {
    expect(1).to.be.ok;
  });
  it('passes 2', function() {
    expect(2).to.be.ok;
  });
  it('passes 3', function() {
    expect(3).to.be.ok;
  });

  it('skips 1');
  it('skips 2');
  it('skips 3');

  it('fails 1', function() {
    expect(false).to.be.true;
  });
  it('fails 2', function() {
    expect(false).to.be.true;
  });
  it('fails 3', function() {
    expect(false).to.be.true;
  });
  it('passes 4', function() {
    expect(1).to.be.ok;
  });
  it('passes 5', function() {
    expect(2).to.be.ok;
  });
  it('passes 6', function() {
    expect(3).to.be.ok;
  });
  it('fails 4', function() {
    expect(false).to.be.true;
  });
  it('fails 5', function() {
    expect(false).to.be.true;
  });
  it('fails 6', function() {
    expect(false).to.be.true;
  });

  xit('skips 4', function() {
    expect(false).to.be.true;
  });
  xit('skips 5', function() {
    expect(false).to.be.true;
  });
  xit('skips 6', function() {
    expect(false).to.be.true;
  });
});