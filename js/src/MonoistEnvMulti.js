// Generated by CoffeeScript 1.4.0

/*
	MonoistEnvMulti synth - multiple oscillators with an envelope
*/


(function() {
  var MonoistEnvMulti;

  MonoistEnvMulti = (function() {

    function MonoistEnvMulti() {
      this.note = randomInt(40, 80);
      this.noteIsOn = false;
      this.volNode = Audanism.Audio.audioContext.createGain();
      this.volNode.gain.value = 0.25;
      this.volNode.connect(Audanism.Audio.audioContext.destination);
      this.compressor = Audanism.Audio.audioContext.createDynamicsCompressor();
      this.compressor.connect(this.volNode);
      this.panner1 = Audanism.Audio.audioContext.createPanner();
      this.panner1.setPosition(-1, 0, 0);
      this.panner1.connect(this.compressor);
      this.panner2 = Audanism.Audio.audioContext.createPanner();
      this.panner2.setPosition(1, 0, 0);
      this.panner2.connect(this.compressor);
      this.panner3 = Audanism.Audio.audioContext.createPanner();
      this.panner3.setPosition(0, 0, 0);
      this.panner3.connect(this.compressor);
      this.asdr = new Audanism.Audio.Module.ASDR(0.1, 0.1, 100, 0.1);
      this.envelope1 = Audanism.Audio.audioContext.createGain();
      this.envelope1.gain.setValueAtTime(0, 0);
      this.envelope1.connect(this.panner1);
      this.envelope2 = Audanism.Audio.audioContext.createGain();
      this.envelope2.gain.setValueAtTime(0, 0);
      this.envelope2.connect(this.panner2);
      this.envelope3 = Audanism.Audio.audioContext.createGain();
      this.envelope3.gain.setValueAtTime(0, 0);
      this.envelope3.connect(this.panner3);
      this.osc1 = Audanism.Audio.audioContext.createOscillator();
      this.osc1.type = 'sine';
      this.osc1.frequency.value = Audanism.Audio.Harmonizer.getFreqFromNote(this.note);
      this.osc1.connect(this.envelope1);
      this.osc1.start(0);
      this.osc2 = Audanism.Audio.audioContext.createOscillator();
      this.osc2.type = 'triangle';
      this.osc2.frequency.value = Audanism.Audio.Harmonizer.getFreqFromNote(this.note * 1);
      this.osc2.connect(this.envelope2);
      this.osc2.start(0);
      /*
      		@osc3                 = Audanism.Audio.audioContext.createOscillator()
      		@osc3.type            = 'square'
      		@osc3.frequency.value = Audanism.Audio.Harmonizer.getFreqFromNote( @note / 2 )
      		@osc3.connect( @envelope3 )
      		@osc3.start( 0 )
      */

    }

    MonoistEnvMulti.prototype.noteOn = function(note) {
      var attackEndTime, now;
      now = Audanism.Audio.audioContext.currentTime;
      attackEndTime = now + this.asdr.attack;
      this.envelope1.gain.cancelScheduledValues(now);
      this.envelope1.gain.setValueAtTime(this.envelope1.gain.value, now);
      this.envelope1.gain.linearRampToValueAtTime(1, attackEndTime);
      this.envelope2.gain.cancelScheduledValues(now);
      this.envelope2.gain.setValueAtTime(this.envelope1.gain.value, now);
      this.envelope2.gain.linearRampToValueAtTime(1, attackEndTime);
      this.envelope3.gain.cancelScheduledValues(now);
      this.envelope3.gain.setValueAtTime(this.envelope1.gain.value, now);
      this.envelope3.gain.linearRampToValueAtTime(1, attackEndTime);
      this.envelope1.gain.setTargetAtTime(this.asdr.sustain / 100, attackEndTime, (this.asdr.decay / 100) + 0.001);
      this.envelope2.gain.setTargetAtTime(this.asdr.sustain / 100, attackEndTime, (this.asdr.decay / 100) + 0.001);
      this.envelope3.gain.setTargetAtTime(this.asdr.sustain / 100, attackEndTime, (this.asdr.decay / 100) + 0.001);
      return this.noteIsOn = true;
    };

    MonoistEnvMulti.prototype.noteOff = function() {
      var now, releaseTime;
      now = Audanism.Audio.audioContext.currentTime;
      releaseTime = now + this.asdr.release;
      console.log(now);
      this.envelope1.gain.cancelScheduledValues(now);
      this.envelope1.gain.setValueAtTime(this.envelope1.gain.value, now);
      this.envelope1.gain.linearRampToValueAtTime(0, releaseTime);
      this.envelope2.gain.cancelScheduledValues(now);
      this.envelope2.gain.setValueAtTime(this.envelope2.gain.value, now);
      this.envelope2.gain.linearRampToValueAtTime(0, releaseTime);
      this.envelope3.gain.cancelScheduledValues(now);
      this.envelope3.gain.setValueAtTime(this.envelope3.gain.value, now);
      this.envelope3.gain.linearRampToValueAtTime(0, releaseTime);
      return this.noteIsOn = false;
    };

    return MonoistEnvMulti;

  })();

  window.Audanism.Audio.Synthesizer.MonoistEnvMulti = MonoistEnvMulti;

}).call(this);