// Generated by CoffeeScript 1.4.0

/*
	Pink noise
*/


(function() {
  var NoisePink,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  NoisePink = (function(_super) {

    __extends(NoisePink, _super);

    function NoisePink(instrumentsIn) {
      this.instrumentsIn = instrumentsIn;
      NoisePink.__super__.constructor.call(this, this.instrumentsIn, null, false);
      this.createNoise();
    }

    NoisePink.prototype.createNoise = function() {
      var bufferSize, _createPinkNoiseNode;
      bufferSize = 4096;
      _createPinkNoiseNode = function() {
        b0;

        b1;

        b2;

        b3;

        b4;

        b5;

        b6;

        var b0, b1, b2, b3, b4, b5, b6, node,
          _this = this;
        b0 = b1 = b2 = b3 = b4 = b5 = b6 = 0.0;
        node = Audanism.Audio.audioContext.createScriptProcessor(bufferSize, 1, 1);
        node.onaudioprocess = function(e) {
          var i, output, white, _i, _ref, _results;
          output = e.outputBuffer.getChannelData(0);
          _results = [];
          for (i = _i = 0, _ref = bufferSize - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
            white = Math.random() * 2 - 1;
            b0 = 0.99886 * b0 + white * 0.0555179;
            b1 = 0.99332 * b1 + white * 0.0750759;
            b2 = 0.96900 * b2 + white * 0.1538520;
            b3 = 0.86650 * b3 + white * 0.3104856;
            b4 = 0.55000 * b4 + white * 0.5329522;
            b5 = -0.7616 * b5 - white * 0.0168980;
            output[i] = b0 + b1 + b2 + b3 + b4 + b5 + b6 + white * 0.5362;
            output[i] *= 0.11;
            _results.push(b6 = white * 0.115926);
          }
          return _results;
        };
        return node;
      };
      this.noiseVol = Audanism.Audio.audioContext.createGain();
      this.noiseVol.gain.value = 0.1;
      this.noiseLpf = Audanism.Audio.audioContext.createBiquadFilter();
      this.noiseLpf.type = 'lowpass';
      this.noiseLpf.frequency.value = 10000;
      this.noise = _createPinkNoiseNode();
      this.noise.connect(this.noiseLpf);
      this.noiseLpf.connect(this.noiseVol);
      return this.noiseVol.connect(this.instrumentsIn);
    };

    NoisePink.prototype.start = function() {
      return this.noiseVol.gain.value = 0.1;
    };

    NoisePink.prototype.stop = function() {
      return this.noiseVol.gain.value = 0;
    };

    NoisePink.prototype.setLpfFrequency = function(frequency) {
      return this.noiseLpf.frequency.value = frequency;
    };

    return NoisePink;

  })(Audanism.Audio.Instrument.Instrument);

  window.Audanism.Audio.Instrument.NoisePink = NoisePink;

}).call(this);
