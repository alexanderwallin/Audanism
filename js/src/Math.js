// Generated by CoffeeScript 1.4.0
(function() {

  window.Math.randomRange = function(max, min) {
    if (max == null) {
      max = null;
    }
    if (min == null) {
      min = null;
    }
    if (!(max != null) && !(min != null)) {
      return Math.random();
    }
    if (min == null) {
      min = 0;
    }
    return min + Math.floor(Math.random() * (max - min + 1));
  };

}).call(this);