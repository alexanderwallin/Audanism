// Generated by CoffeeScript 1.4.0
(function() {
  var getRandomElements, pushMany;

  pushMany = function(arr, objects) {
    var obj, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = objects.length; _i < _len; _i++) {
      obj = objects[_i];
      _results.push(arr.push(obj));
    }
    return _results;
  };

  window.pushMany = pushMany;

  getRandomElements = function(arr, numElements) {
    var copy, elements, i, obj;
    console.log("#getRandomElements", arr, numElements);
    copy = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = arr.length; _i < _len; _i++) {
        obj = arr[_i];
        _results.push(obj);
      }
      return _results;
    })();
    return elements = (function() {
      var _i, _results;
      _results = [];
      for (i = _i = 1; 1 <= numElements ? _i <= numElements : _i >= numElements; i = 1 <= numElements ? ++_i : --_i) {
        _results.push(copy.splice(Math.floor(Math.random() * copy.length), 1)[0]);
      }
      return _results;
    })();
  };

  window.getRandomElements = getRandomElements;

}).call(this);