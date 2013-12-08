(function (_input, _output) {
  // no vars
  function factorial(n) {
    var _ret;
    //no vars
    if (n <= 1) {
      _ret = 1;
    } else {
      _ret = n * factorial(n - 1);
    }
    return _ret;
  }

  _output(factorial(6));
})(undefined, console.log);

