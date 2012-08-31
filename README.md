# PhantomJS Runners for Mocha


# TODO

* Real Package - https://github.com/jamescarr/jasmine-tool
* Make sure runner hooks into status code. Test.


# Playing Around

    $ phantomjs lib/mocha-phantomjs.coffee test/array.html


# Exit Code

This runner will use the number of test failures as the exit code for the phantom process. This makes it easy to utilize this runner in your continious integration system. So zero test failures will mean a status code of 0 which is equal to passing. 

