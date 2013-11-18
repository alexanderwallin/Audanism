// Generated by CoffeeScript 1.4.0

/*
	Factor
*/


(function() {
  var Factor;

  Factor = (function() {

    Factor.TYPE_UNKNOWN = 0;

    Factor.TYPE_OPENNESS = 1;

    Factor.TYPE_CONSCIENTIOUSNESS = 2;

    Factor.TYPE_EXTRAVERSION = 3;

    Factor.TYPE_AGREEABLENESS = 4;

    Factor.TYPE_NEUROTICISM = 5;

    Factor.FACTOR_CORRELATIONS = {
      '1': {
        '2': -15,
        '3': 25
      },
      '2': {
        '3': 30
      },
      '3': {
        '4': 50
      },
      '4': {
        '5': -20
      }
    };

    Factor.createFactor = function(factorType, factorValue) {
      if (factorValue == null) {
        factorValue = 0;
      }
      switch (factorType) {
        case Factor.TYPE_OPENNESS:
          return new OpennessFactor();
        case Factor.TYPE_CONSCIENTIOUSNESS:
          return new ConscientiousnessFactor();
        case Factor.TYPE_EXTRAVERSION:
          return new ExtraversionFactor();
        case Factor.TYPE_AGREEABLENESS:
          return new AgreeablenessFactor();
        case Factor.TYPE_NEUROTICISM:
          return new NeuroticismFactor();
        default:
          return null;
      }
    };

    function Factor(factorType, factorValue) {
      this.factorType = factorType;
      this.factorValue = factorValue != null ? factorValue : 0;
      this.name = this.constructor.name.replace(/^(\w+)Factor$/, "$1");
      this.disharmony = 0;
      this.relativeDisharmony = [];
    }

    Factor.prototype.addValue = function(value) {
      this.factorValue += value;
      if (this.factorValue < 0) {
        this.factorValue = 0;
      }
      if (this.factorValue > 100) {
        return this.factorValue = 100;
      }
    };

    Factor.prototype.toString = function() {
      return "<Factor #" + this.factorType + " (" + this.name + "); factorValue = " + this.factorValue + ">";
    };

    return Factor;

  })();

  window.Factor = Factor;

}).call(this);
