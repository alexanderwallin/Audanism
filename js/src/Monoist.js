// Generated by CoffeeScript 1.4.0

/*
	Monoist synth - just a sine
*/


(function() {
  var Monoist;

  Monoist = (function() {

    function Monoist(note) {
      this.note = note;
      this.effectChain = Audanism.Audio.audioContext.createGain();
      this.volNode = Audanism.Audio.audioContext.createGain();
      this.volNode.gain.value = 0.25;
      this.effectChain.connect(this.volNode);
      this.volNode.connect(Audanism.Audio.audioContext.destination);
      this.freq = Audanism.Audio.Harmonizer.getFreqFromNote(this.note);
      this.osc = Audanism.Audio.audioContext.createOscillator();
      this.osc.frequency.setValueAtTime(this.freq, 0);
      this.osc.connect(this.effectChain);
      this.osc.start(0);
    }

    Monoist.prototype.noteOn = function(note) {
      return this.osc.frequency.setValueAtTime(Audanism.Audio.Harmonizer.getFreqFromNote(note), 0);
    };

    Monoist.prototype.noteOff = function() {
      return this.osc.stop(Audanism.Audio.audioContext.currentTime + 0.1);
    };

    return Monoist;

  })();

  window.Audanism.Audio.Synthesizer.Monoist = Monoist;

}).call(this);