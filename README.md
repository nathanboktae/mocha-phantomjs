# PhantomJS Runners for Mocha


# TODO

* Real Package - https://github.com/jamescarr/jasmine-tool
* Make sure runner hooks into status code. Test.


# Details

* Talk about `window.mochaPhantomJS` being set to true by PhantomJS on page initialization.


# Playing Around
  
    $ cake test
    $ phantomjs lib/mocha-phantomjs.coffee test/bdd.html


    $ cake build
    $ mocha -r chai/chai.js -u bdd -R spec test/lib/bdd-spec-passing.js


      bdd-spec-passing
        ✓ passes 1 
        ✓ passes 2 
        ✓ passes 3 
        - skips 1
        - skips 2
        - skips 3


      ✔ 6 tests complete (4ms)
      • 3 tests pending


# Exit Code

This runner will use the number of test failures as the exit code for the phantom process. This makes it easy to utilize this runner in your continious integration system. So zero test failures will mean a status code of 0 which is equal to passing. 




