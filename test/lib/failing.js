expect = (chai && chai.expect) || require('chai').expect;

describe('Tests Failing', function() {
  it('passes 1', function() {
    expect(1).to.be.ok;
  });

  it('passes 2', function() {
    expect(2).to.be.ok;
  });

  it('passes 3', function() {
    expect(3).to.be.ok;
  });

  it('fails 1', function() {
    expect(false).to.be["true"];
  });

  it('fails 2', function() {
    expect(false).to.be["true"];
  });

  it('fails 3', function() {
    expect('false').to.equal('true');
  });
});
