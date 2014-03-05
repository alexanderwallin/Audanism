// Generated by CoffeeScript 1.4.0

/*
	MonoistEnv synth - sine with an envelope
*/


(function() {
  var MonoistEnv,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  MonoistEnv = (function(_super) {

    __extends(MonoistEnv, _super);

    function MonoistEnv(note) {
      MonoistEnv.__super__.constructor.call(this, note);
      this.asdr = new Audanism.Audio.Module.ASDR(0.2, 0.2, 0.7, 0.7);
      this.envelope = Audanism.Audio.audioContext.createGain();
      this.envelope.gain.setValueAtTime(0, 0);
      this.envelopes.push(this.envelope);
      this.osc = Audanism.Audio.audioContext.createOscillator();
      this.osc.type = this.getRandomOscType();
      this.osc.frequency.value = Audanism.Audio.Module.Harmonizer.getFreqFromNote(this.note);
      this.oscillators.push(this.osc);
      this.osc.connect(this.envelope);
      this.envelope.connect(this.pan);
      this.osc.start(0);
    }

    return MonoistEnv;

  })(Audanism.Audio.Synthesizer.Voice);

  window.Audanism.Audio.Synthesizer.MonoistEnv = MonoistEnv;

}).call(this);
