// Generated by CoffeeScript 1.10.0

/*
	FX chain
 */

(function() {
  var FXChain;

  FXChain = (function() {
    function FXChain(_in, out) {
      this["in"] = _in;
      this.out = out;
      this.fxs = [];
      if (this["in"] == null) {
        throw new Exception("No @in provided to FXChain.");
      }
      if (this.out == null) {
        throw new Exception("No @out provided to FXChain.");
      }
      this.wet = Audanism.Audio.audioContext.createGain();
      this.wet.connect(this.out);
    }

    FXChain.prototype.addFx = function(fx) {
      var id;
      this.fx = fx;
      id = this.fxs.length;
      if (id === 0) {
        this["in"].connect(this.fx["in"]);
      } else {
        this.fxs[id - 1].out.disconnect(0);
        this.fxs[id - 1].out.connect(this.fx["in"]);
      }
      this.fx.out.connect(this.wet);
      return this.fxs[id] = this.fx;
    };

    FXChain.prototype.setWetAmount = function(wetAmount) {
      return this.wet.gain.value = wetAmount;
    };

    return FXChain;

  })();

  window.Audanism.Audio.FX.FXChain = FXChain;

}).call(this);
