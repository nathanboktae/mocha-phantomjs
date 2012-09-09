# PhantomJS Runners for Mocha


# TODO

* Real Package - https://github.com/jamescarr/jasmine-tool
* Make sure runner hooks into status code. Test.


# Supported Reporters

* spec (default)
* dot
* tap
* min
* list
* doc

### Spec Reporter

<div style="text-align:center;">
  <img src="https://raw.github.com/metaskills/mocha-phantomjs/master/public/images/reporter_spec.gif" alt="Spec Reporter" width="770">
</div>



# Details

* Talk about `window.mochaPhantomJS` being set to true by PhantomJS on page initialization.
  - Used so you can manually run HTML files as well as avoid run() in PhantomJS.
* Talk about `process.stdout.write` done right!


# Exit Code

This runner will use the number of test failures as the exit code for the phantom process. This makes it easy to utilize this runner in your continious integration system. So zero test failures will mean a status code of 0 which is equal to passing. 


<style type="text/css">
  section { width: 782px; }
</style>

