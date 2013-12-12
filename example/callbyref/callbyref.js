var byref = (function (input, output) {
  /* ... maybe each type should know how to initialize itself. */
  var $a = 0;
  var $b = (function () {
    var i, arr = {};
    var init = 0;
    for (i = 1; i <= 10; i++) {
      arr[i] = 0;
    }
    return arr;
  })();
  var $c = (function () {
    var i, arr = {};

    var init = (function () {
      var i, arr = {};
      var init = 0;
      for (i = 1; i <= 10; i++) {
        arr[i] = init;
      }
      return arr;
    });

    for (i = 1; i <= 10; i++) {
      arr[i] = init();
    }
    return arr;
  })();

  function p1($x) {
    output($x());
    $x(1);
  }

  function p2($x) {
    $x()[1] = 3;
    p1(function(val) {
      return (arguments.length) ? ($x()[2] = val) : ($x()[2]);
    });
  }

  $a = 42;

  p1(function(val) {
    return (arguments.length) ? ($a = val) : ($a);
  });

  p2(function(val) {
    return (arguments.length) ? ($b = val) : ($b);
  });

  p2(function(val) {
    return (arguments.length) ? ($c[8] = val) : ($c[8]);
  });

  /* For those playing at home, return the value of the current variables. */
  return { a: $a, b: $b, c: $c };

});

module.exports = byref;
