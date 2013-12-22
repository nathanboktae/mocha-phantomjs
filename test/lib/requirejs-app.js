define(['passing'], function(require) {
  if (window.mochaPhantomJS) {
    return mochaPhantomJS.run();
  } else {
    return mocha.run();
  }
});
