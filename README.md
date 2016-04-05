# PhantomJS Runners for Mocha

[Mocha](http://mochajs.org/) is a feature-rich JavaScript test framework running on node and the browser. Along with the [Chai](http://chaijs.com) assertion library they make an impressive combo. [PhantomJS](http://phantomjs.org) is a headless WebKit with a JavaScript API.

Since 4.0, the phantomjs code now is in [mocha-phantomjs-core](https://github.com/nathanboktae/mocha-phantomjs-core). If you need full control over which phantomjs version to use and where to get it, or want to use it more programatically like a build system plugin, please use that package directly. This project is a node.js CLI around it.

[![Build Status](https://travis-ci.org/nathanboktae/mocha-phantomjs.svg?branch=master)](https://travis-ci.org/nathanboktae/mocha-phantomjs)

# Key Features

### Standard Out

Finally, `process.stdout.write`, done right. Mocha is primarily written for node, hence it relies on writing to standard out without trailing newline characters. This behavior is critical for reporters like the dot reporter. We make up for PhantomJS's lack of stream support by both customizing `console.log` and creating a `process.stdout.write` function to the current PhantomJS process. This technique combined with a handful of fancy [ANSI cursor movement codes](http://web.mit.edu/gnu/doc/html/screen_10.html) allows PhantomJS to support Mocha's diverse reporter options.

### Exit Codes

Proper exit status codes from PhantomJS using Mocha's failures count. So in standard UNIX fashion, a `0` code means success. This means you can use mocha-phantomjs on your CI server of choice.

### Mixed Mode Runs

You can use your existing Mocha HTML file reporters side by side with mocha-phantomjs. This gives you the option to run your tests both in a browser or with PhantomJS, with no changes needed to your existing test setup.

# Installation

We distribute [mocha-phantomjs as an npm package](https://npmjs.org/package/mocha-phantomjs) that is easy to install. Once done, you will have a `mocha-phantomjs` binary. See the next usage section for docs or use the `-h` flag.

# Usage

```
  Usage: mocha-phantomjs [options] page

  Options:

    -h, --help                   output usage information
    -V, --version                output the version number
    -R, --reporter <name>        specify the reporter to use
    -f, --file <filename>        specify the file to dump reporter output
    -t, --timeout <timeout>      specify the test startup timeout to use
    -g, --grep <pattern>         only run tests matching <pattern>
    -i, --invert                 invert --grep matches
    -b, --bail                   exit on the first test failure
    -A, --agent <userAgent>      specify the user agent to use
    -c, --cookies <Object>       phantomjs cookie object http://git.io/RmPxgA
    -h, --header <name>=<value>  specify custom header
    -k, --hooks <path>           path to hooks module
    -s, --setting <key>=<value>  specify specific phantom settings
    -v, --view <width>x<height>  specify phantom viewport size
    -C, --no-color               disable color escape codes
    -p, --path <path>            path to PhantomJS binary
    --ignore-resource-errors     ignore resource errors

  Any other options are passed to phantomjs (see `phantomjs --help`)

  Examples:

    $ mocha-phantomjs -R dot /test/file.html
    $ mocha-phantomjs https://testserver.com/file.html --ignore-ssl-errors=true
    $ mocha-phantomjs -p ~/bin/phantomjs /test/file.html
```

Now as an node package, using `mocha-phantomjs` has never been easier. The page argument can be either a local or fully qualified path or a http or file URL. `--reporter` may be a built-in reporter or a path to your own reporter (see below). See [phantomjs WebPage settings](https://github.com/ariya/phantomjs/wiki/API-Reference-WebPage#wiki-webpage-settings) for options that may be supplied to the `--setting` argument.

Since 4.0, you need no modifications to your test harness markup file to run. Here is an example `test.html`:

```html
<html>
  <head>
    <meta charset="utf-8">
    <!-- encoding must be set for mocha's special characters to render properly -->
    <link rel="stylesheet" href="mocha.css" />
  </head>
  <body>
    <div id="mocha"></div>
    <script src="mocha.js"></script>
    <script src="chai.js"></script>
    <script>
      mocha.ui('bdd')
      expect = chai.expect
    </script>
    <script src="src/mycode.js"></script>
    <script src="test/mycode.js"></script>
    <script>
      mocha.run()
    </script>
  </body>
</html>
```

# Screenshots

Mocha-phantomjs supports creating screenshots from your test code. For example, you could write a function like below into your test code.

```javascript
function takeScreenshot() {
  if (window.callPhantom) {
    var date = new Date()
    var filename = "screenshots/" + date.getTime()
    console.log("Taking screenshot " + filename)
    callPhantom({'screenshot': filename})
  }
}
```

If you want to generate a screenshot for each test failure you could add the following into your test code.

```javascript
  afterEach(function () {
    if (this.currentTest.state == 'failed') {
      takeScreenshot()
    }
  })
```

# Supported Reporters

`mocha-phantomjs` works by piping `Mocha.process.stdout` to PhantomJS's stdout. Any reporter that can work in the browser works with mocha-phantomjs.

[Bundled](http://mochajs.org/#reporters) and tested reporters include:

````
spec (default)
dot
tap
min
nyan
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

When using the `dot` reporter, the PhantomJS process has no way of knowing anything about your console window's width. So we default the width to 75 columns. However, if you set the `COLUMNS` environment variable, it will pick that up and adjust to your current terminal width. For example, using the `$COLUMNS` variable like so.

```
env COLUMNS=$COLUMNS phantomjs mocha-phantomjs.coffee URL dot
```

### Third Party Reporters

Mocha has support for custom [3rd party reporters](https://github.com/mochajs/mocha/wiki/Third-party-reporters), and mocha-phantomjs does support 3rd party reporters, but keep in mind - *the reporter does not run in Node.js, but in the browser, and node modules can't be required.* You need to only use basic, vanilla JavaScript when using third party reporters. However, some things are available:

- `require`: You can only require other reporters, like `require('./base')` to build off of the BaseReporter
- `exports`, `module`: Export your reporter class as normal
- `process`: use `process.stdout.write` preferrably to support the `--file` option over `console.log` (see #114)

Also, no compilers are supported currently, so please provide JavaScript only for your reporters.

# Testing

Simple! Just clone the repo, then run `npm install` and the various node development dependencies will install to the `node_modules` directory of the project. If you have not done so, it is typically a good idea to add `/node_modules/.bin` to your `$PATH` so these modules bins are used. Now run `npm test` to start off the test suite.

We also use Travis CI to run our tests too. The current build status:

[![Build Status](https://secure.travis-ci.org/nathanboktae/mocha-phantomjs.png)](http://travis-ci.org/nathanboktae/mocha-phantomjs)


# License

Released under the MIT license. Copyright (c) 2015 Ken Collins, Nathan Black, and many generous GitHub Contributors.

