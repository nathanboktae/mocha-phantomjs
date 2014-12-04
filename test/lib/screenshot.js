expect = (chai && chai.expect) || require('chai').expect;

describe('Screenshot', function() {
  it('takes screenshot', function() {
    if (window.callPhantom) {
      var date = new Date()
      var filename = "screenshot"
      console.log("Taking screenshot " + filename)
      callPhantom({'screenshot': filename})
    }
  });
});
