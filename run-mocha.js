
(function () {
  var url, timeout, defer;

  if (phantom.args.length < 1) {
    console.log("Usage: phantomjs run-mocha.js URL [timeout]");
    phantom.exit();
  }

  url = phantom.args[0];
  timeout = phantom.args[1] || 6000;

  defer = function (test) {
    var start, condition, func, interval, time, testStart;
    start = new Date().getTime();
    testStart = new Date().getTime();
    condition = false;
    func = function () {
      if (new Date().getTime() - start < timeout && !condition) {
        condition = test();
      } else {
        if (!condition) {
          console.log("Timeout passed before the tests finished.");
          phantom.exit();
        } else {
          clearInterval(interval);
          phantom.exit();
        }
      }
    };
    interval = setInterval(func, 100);
  };

  var page = require('webpage').create();
  page.onConsoleMessage = function(msg) { console.log(msg); };

  var failed = function() {
    console.log("Failed to load the page. Check the url");
    phantom.exit();
  }

  var run = function() {

    var test;
    
    page.injectJs('lib/bind.js');
    page.injectJs('lib/console.js');
    page.injectJs('lib/process.stdout.write.js');

    page.evaluate(function(){
      // setup mocha with the [spec reporter](http://visionmedia.github.com/mocha/#spec-reporter)
      mocha.setup({
        ui: 'bdd',
        // TODO: it could be great to pass `spec` has an option in the command line.
        // <https://github.com/ariya/phantomjs/commit/81794f90960>
        reporter: mocha.reporters.Spec
      });

      // wait for dom loaded
      // console.log('BEFORE: DOMContentLoaded');
      // document.addEventListener('DOMContentLoaded', function(){
        // console.log('DOMContentLoaded');
        mocha.run().on('end', function(){
          mocha.end = true;
        });
      // }, false);
      
    });

    // to know if mocha has finished running or not.
    test = function () {
      return page.evaluate(function(){
        return mocha.end;
      });
    };

    defer(test);

  };
  
  page.open(url);
  page.onLoadFinished = function(status) {
    if (status !== "success") { fail(); } else { run(); };
  };


}());
