expect = (chai && chai.expect) || require('chai').expect;

describe('sendEvent', function() {
  it('Send a keydown event', function(done) {
    if (window.callPhantom) {
      window.onkeydown = function(e) {
        expect(e.keyCode).to.eql(38);
        done();
      }
      window.callPhantom({sendEvent: ['keydown', 16777235]});
    }
  });
});
