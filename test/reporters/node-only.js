var Base = require('./base')
  , fs = require('fs')

exports = module.exports = NodeOnly;

function NodeOnly(runner) {
  Base.call(this, runner);

  runner.on('suite end', function(suite){
    fs.writeFile('myresults', function(err) {
      // do some stuff
    });
  });
}
