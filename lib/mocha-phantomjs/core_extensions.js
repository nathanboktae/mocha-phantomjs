(function(){

  // A shim for non ES5 supporting browsers, like PhantomJS. Lovingly inspired by:
  // http://www.angrycoding.com/2011/09/to-bind-or-not-to-bind-that-is-in.html
  if (!('bind' in Function.prototype)) {
    Function.prototype.bind = function() {
      var funcObj = this;
      var extraArgs = Array.prototype.slice.call(arguments);
      var thisObj = extraArgs.shift();
      return function() {
        return funcObj.apply(thisObj, extraArgs.concat(Array.prototype.slice.call(arguments)));
      };
    };
  }

  // Mocha need process.stdout.write in order to change the cursor position. However,
  // PhantomJS console.log always puts a new line character when logging. To work around
  // this, we try to cleanup when needed.
  process.cursor = {
    needsCrCleanup:  false,
    needsCrMatcher:  undefined,
    hide:            '\u001b[?25l',
    show:            '\u001b[?25h',
    deleteLine:      '\u001b[2K',
    beginningOfLine: '\u001b[0G',
    up:              '\u001b[A',
    down:            '\u001b[B'
  }
  process.stdout.write = function(string) {
    if (string === process.cursor.deleteLine || string === process.cursor.beginningOfLine) {
      return;
    } else {
      console.log(string);
    }
  }

  // Mocha needs the formating feature of console.log so copy node's format function and  
  // monkey-patch it into place. This code is copied from node's, links copyright applies.
  // We also check the CR cleanup needed in this over ride too.
  // https://github.com/joyent/node/blob/master/lib/util.js
  var formatRegExp = /%[sdj%]/g;
  format = function(f) {
    if (typeof f !== 'string') {
      var objects = [];
      for (var i = 0; i < arguments.length; i++) {
        objects.push(inspect(arguments[i]));
      }
      return objects.join(' ');
    }
    var i = 1;
    var args = arguments;
    var len = args.length;
    var str = String(f).replace(formatRegExp, function(x) {
      if (x === '%%') return '%';
      if (i >= len) return x;
      switch (x) {
        case '%s': return String(args[i++]);
        case '%d': return Number(args[i++]);
        case '%j': return JSON.stringify(args[i++]);
        default:
          return x;
      }
    });
    for (var x = args[i]; i < len; x = args[++i]) {
      if (x === null || typeof x !== 'object') {
        str += ' ' + x;
      } else {
        str += ' ' + inspect(x);
      }
    }
    return str;
  };
  var origError = console.error;
  console.error = function(){ origError.call(console, format.apply(this, arguments)); };
  var origLog = console.log;
  console.log = function(){
    var string = format.apply(this, arguments);
    if (process.cursor.needsCrMatcher && string.match(process.cursor.needsCrMatcher)) {
      process.cursor.needsCrCleanup = true;
    } else if (process.cursor.needsCrCleanup) {
      string = process.cursor.up + process.cursor.deleteLine + string;
      process.cursor.needsCrCleanup = false;
    }
    origLog.call(console, string);
  };

})();




