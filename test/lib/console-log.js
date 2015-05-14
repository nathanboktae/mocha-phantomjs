expect = (chai && chai.expect) || require('chai').expect;

describe('Tests Passing', function() {
  it('passes 1', function() {
    var o = {};
    o['self'] = o;

    console.log(o);
  });
});
