/*
* Mocha need process.stdout.write in order to change the cursor position,
* So I implemented a dummy `process.stdout.write` that debounces a `console.log`
* and enqueues the logs to print.
* */
(function(){

  process.stdout.write = function() {
    console.log.apply(console, arguments);
  }
  
  // Returns a function, that, as long as it continues to be invoked, will not
  // be triggered. The function will be called after it stops being called for
  // N milliseconds. The first argument (a string) is appended each time debouceAndAppend is called.

  // process.stdout.write = debouceAndAppend(function(){ console.log.apply(console, arguments); }, 300);  
  // function debouceAndAppend(func, wait) {
  //   var timeout, firstArg = '';
  //   return function() {
  //     var context = this, args = arguments;
  //     firstArg = firstArg + arguments[0].toString();
  //     var later = function() {
  //       timeout = null;
  //       args[0] = firstArg;
  //       func.apply(context, args);
  //       firstArg = '';
  //     };
  //     clearTimeout(timeout);
  //     timeout = setTimeout(later, wait);
  //   };
  // }

})();
