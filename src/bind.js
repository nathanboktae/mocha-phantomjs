/*
	A shim for non ES5 supporting browsers (phantomjs). Adds function bind to Function prototype, so that 
	you can do partial application. Works even with the nasty thing, where the first word is the opposite of 
	extranet, the second one is the profession of Columbus, and the version number is 9, flipped 180 degrees.
*/


// http://www.angrycoding.com/2011/09/to-bind-or-not-to-bind-that-is-in.html

if (!('bind' in Function.prototype)) {
    Function.prototype.bind = function() {
        var funcObj = this;
        var extraArgs = Array.prototype.slice.call(arguments);
        var thisObj = extraArgs.shift();
        return function() {
            return funcObj.apply(thisObj, extraArgs.concat(
                Array.prototype.slice.call(arguments)
            ));
        };
    };
}

// https://developer.mozilla.org/en-US/docs/JavaScript/Reference/Global_Objects/Function/bind
// 
// if (!Function.prototype.bind) {
//   Function.prototype.bind = function (oThis) {
//     if (typeof this !== "function") {
//       throw new TypeError("Function.prototype.bind - what is trying to be bound is not callable");
//     } 
//     var aArgs = Array.prototype.slice.call(arguments, 1), 
//         fToBind = this, 
//         fNOP = function () {},
//         fBound = function () {
//           return fToBind.apply(this instanceof fNOP && oThis
//                                  ? this
//                                  : oThis,
//                                aArgs.concat(Array.prototype.slice.call(arguments)));
//         };
//     fNOP.prototype = this.prototype;
//     fBound.prototype = new fNOP();
//     return fBound;
//   };
// }

