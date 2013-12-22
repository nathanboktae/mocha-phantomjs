var Base = require('./base')
  , escape = function(x) {
      return (x || '').replace('&', '&amp;').replace('<', '&gt;').replace('>', '&lt;')
    };

exports = module.exports = CustomDoc;

function CustomDoc(runner) {
  Base.call(this, runner);

  var self = this
    , stats = this.stats
    , total = runner.total
    , indents = 2;

  function indent() {
    return Array(indents).join('  ');
  }

  runner.on('suite', function(suite){
    if (suite.root) return;
    ++indents;
    process.stdout.write(indent() + '<section class="suite">\n');
    ++indents;
    process.stdout.write(indent() + '<h1>' + suite.title + '</h1>\n');
    process.stdout.write(indent() + '<dl>\n');
  });

  runner.on('suite end', function(suite){
    if (suite.root) return;
    process.stdout.write(indent() + '</dl>\n');
    --indents;
    process.stdout.write(indent() + '</section>\n');
    --indents;
  });

  runner.on('pass', function(test){
    process.stdout.write(indent() + '  <dt>' + escape(test.title) + '</dt>\n');
    var code = escape(test.fn.toString());
    process.stdout.write(indent() + '  <dd><pre><code>' + code + '</code></pre></dd>\n');
  });
}
