# PhantomJS Runners for Mocha

[Mocha](http://visionmedia.github.com/mocha/) is a feature-rich JavaScript test framework running on node and the browser. Along with the [Chai](http://chaijs.com) assertion library they make an impressive combo. [PhantomJS](http://phantomjs.org) is a headless WebKit with a JavaScript/CoffeeScript API. It has fast and native support for various web standards like DOM handling, CSS selectors, JSON, Canvas, and SVG.

The mocha-phantomjs project provides a `mocha-phantomjs.coffee` script file and extensions to drive PhantomJS while testing your HTML pages with Mocha from the console. The preferred usage is to install `mocha-phantomjs` via node's packaged modules and use the `mocha-phantomjs` binary wrapper. Tested with Mocha 1.12.x, Chai 1.7.x, and PhantomJS 1.9.1.

  * **Since version 3.0 of mocha-phantomjs, you must use PhantomJS 1.9.1 or higher.**

[![Build Status](https://secure.travis-ci.org/metaskills/mocha-phantomjs.png)](http://travis-ci.org/metaskills/mocha-phantomjs)


# Key Features

### Standard Out

Finally, `process.stdout.write`, done right. Mocha is primarily written for node, hence it relies on writing to standard out without trailing newline characters. This behavior is critical for reporters like the dot reporter. We make up for PhantomJS's lack of stream support by both customizing `console.log` and creating a `process.stdout.write` function to the current PhantomJS process. This technique combined with a handful of fancy [ANSI cursor movement codes](http://web.mit.edu/gnu/doc/html/screen_10.html) allows PhantomJS to support Mocha's diverse reporter options.

### Exit Codes

Proper exit status codes from PhantomJS using Mocha's failures count. So in standard UNIX fashion, a `0` code means success. This means you can use mocha-phantomjs on your CI server of choice.

### Mixed Mode Runs

You can use your existing Mocha HTML file reporters side by side with mocha-phantomjs. This gives you the option to run your tests both in a browser or with PhantomJS. Since mocha-phantomjs needs to control when the `run()` command is sent to the mocha object, we accomplish this by setting the `mochaPhantomJS` on the `window` object to `true`. Below, in the usage section, is an example of a HTML structure that can be used both by opening the file in your browser or choice or using mocha-phantomjs.


# Installation

We distribute [mocha-phantomjs as an npm](https://npmjs.org/package/mocha-phantomjs) that is easy to install. Once done, you will have a `mocha-phantomjs` binary. See the next usage section for docs or use the `-h` flag.

We have an undeclared dependency on PhantomJS. This allows you to choose to install PhantomJS via the node package manager (npm), or to use system PhantomJS downloaded and installed from [the PhantomJS website](http://phantomjs.org). We have heard reports that Windows users have better results with the official PhantomJS download vs the npm.

If you would like to use PhantomJS installed from npm:

```
$ npm install -g mocha-phantomjs phantomjs
```

Otherwise, once you have downloaded and installed PhantomJS yourself:

```
$ npm install -g mocha-phantomjs
```

If you don't install phantomjs using either of these approaches, you will get an unhelpful **ENOENT** error when you try to run `mocha-phantomjs`.

# Usage

```
Usage: mocha-phantomjs [options] page

 Options:

   -h, --help                   output usage information
   -V, --version                output the version number
   -R, --reporter <name>        specify the reporter to use
   -f, --file <filename>        specify the file to dump reporter output
   -t, --timeout <timeout>      specify the test startup timeout to use
   -A, --agent <userAgent>      specify the user agent to use
   -c, --cookies <Object>       phantomjs cookie object http://git.io/RmPxgA
   -h, --header <name>=<value>  specify custom header
   -k, --hooks <path>           path to hooks module
   -s, --setting <key>=<value>  specify specific phantom settings
   -v, --view <width>x<height>  specify phantom viewport size
   -C, --no-color               disable color escape codes
   -p, --path <path>            path to PhantomJS binary


 Examples:

   $ mocha-phantomjs -R dot /test/file.html
   $ mocha-phantomjs http://testserver.com/file.html
   $ mocha-phantomjs -s localToRemoteUrlAccessEnabled=true -s webSecurityEnabled=false http://testserver.com/file.html
   $ mocha-phantomjs -p ~/bin/phantomjs /test/file.html
```

Now as an node package, using `mocha-phantomjs` has never been easier. The page argument can be either a local or fully qualified path or a http or file URL. See the list of reporters below for acceptable options to the `--reporter` argument. See [phantomjs WebPage settings](https://github.com/ariya/phantomjs/wiki/API-Reference-WebPage#wiki-webpage-settings) for options that may be supplied to the `--setting` argument.

Your HTML file's structure should look something like this. The reporter set below to `html` is only needed for viewing the HTML page in your browser. The `mocha-phantomjs.coffee` script overrides that reporter value. The conditional run at the bottom allows the mixed mode feature described above.

```html
<html>
  <head>
    <meta charset="utf-8">
    <link rel="stylesheet" href="mocha.css" />
  </head>
  <body>
    <div id="mocha"></div>
    <script src="mocha.js"></script>
    <script src="chai.js"></script>
    <script>
      mocha.ui('bdd');
      mocha.reporter('html');
      expect = chai.expect;
    </script>
    <script src="test/mycode.js"></script>
    <script>
      if (window.mochaPhantomJS) { mochaPhantomJS.run(); }
      else { mocha.run(); }
    </script>
  </body>
</html>
```


# Supported Reporters

Mocha-phantomjs does not scrap the web page under test! No other PhantomJS driver stacks up to our runner support. Some have used a debounce method to keep duplicate messages in the spec reporter from showing up twice. Loosing one of Mocha's console reporters neatest features, initial test start feedback. The animation below is an example of how our runner script fully compiles with expected Mocha behavior.

<div style="text-align:center;">
  <img src="https://raw.github.com/metaskills/mocha-phantomjs/master/public/images/slow.gif" alt="Slow Tests Example">
</div>

The following is a list of tested reporters. Since moving PhantomJS 1.9.1, most core Mocha reporters should "just work" since we now support stdout properly. Reporters with node dependencies will not work, like `html-cov`. If you have an issue with a reporter, [open a github issue](https://github.com/metaskills/mocha-phantomjs/issues) and let me know.

### Spec Reporter (default)

The default reporter. You can force it using `spec` for the reporter argument.

<div style="text-align:center;">
  <img src="https://raw.github.com/metaskills/mocha-phantomjs/master/public/images/reporter_spec.gif" alt="Spec Reporter" width="616">
</div>

### Dot Matrix Reporter

Use `dot` for the reporter argument.

<div style="text-align:center;">
  <img src="https://raw.github.com/metaskills/mocha-phantomjs/master/public/images/reporter_dot.gif" alt="Dot Matrix Reporter" width="616">
</div>

The PhantomJS process has no way of knowing anything about your console window's width. So we default the width to 75 columns. But if you pass down the `COLUMNS` environment variable, it will pick that up and adjust to your current terminal width. For example, using the `$COLUMNS` variable like so.

```
env COLUMNS=$COLUMNS phantomjs mocha-phantomjs.coffee URL dot
```

[Bundled](http://visionmedia.github.io/mocha/#reporters) and tested reporters include:

````
tap
min
list
doc
teamcity
json
json-cov
xunit
progress
landing
markdown
````

### Third Party Reporters

Mocha has support for custom [3rd party reporters](https://github.com/visionmedia/mocha/wiki/Third-party-reporters), and mocha-phantomjs does support 3rd party reporters, but keep in mind - *the reporter does not run in Node.js, but in the browser, and node modules can't be required.* You need to only use basic, vanilla JavaScript when using third party reporters. However, some things are available:

- `require`: You can only require other reporters, like `require('./base')` to build off of the BaseReporter
- `exports`, `module`: Export your reporter class as normal
- `process`: use `process.stdout.write` preferrably to support the `--file` option over `console.log` (see #114)

Also, no compilers are supported currently, so please provide JavaScript only for your reporters.

# Testing

Simple! Just clone the repo, then run `npm install` and the various node development dependencies will install to the `node_modules` directory of the project. If you have not done so, it is typically a good idea to add `/node_modules/.bin` to your `$PATH` so these modules bins are used. Now run `npm test` to start off the test suite.

We also use Travis CI to run our tests too. The current build status:

[![Build Status](https://secure.travis-ci.org/metaskills/mocha-phantomjs.png)](http://travis-ci.org/metaskills/mocha-phantomjs)


# Alternatives

* OpenPhantomScripts - https://github.com/mark-rushakoff/OpenPhantomScripts
* Front Tests - https://github.com/Backbonist/front-tests


# License

Released under the MIT license. Copyright (c) 2012 Ken Collins.

