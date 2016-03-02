// Generated by CoffeeScript 1.10.0

/*
	Instrument super-class
 */

(function() {
  var Instrument;

  Instrument = (function() {
    function Instrument(instrumentsIn, synthesizer, autoRelease) {
      var i;
      this.instrumentsIn = instrumentsIn;
      this.synthesizer = synthesizer;
      this.autoRelease = autoRelease;
      if (this.autoRelease == null) {
        this.autoRelease = true;
      }
      this.voices = (function() {
        var j, results;
        results = [];
        for (i = j = 0; j <= 120; i = ++j) {
          results.push(null);
        }
        return results;
      })();
      this.noteTimers = (function() {
        var j, results;
        results = [];
        for (i = j = 0; j <= 120; i = ++j) {
          results.push(null);
        }
        return results;
      })();
    }

    Instrument.prototype.createVoice = function(note) {
      if (this.beforeCreateVoice) {
        this.beforeCreateVoice(note);
      }
      if (!this.voices[note]) {
        this.voices[note] = new Audanism.Audio.Synthesizer[this.synthesizer](note);
        if (this.setupVoice) {
          this.setupVoice(this.voices[note]);
        }
        this.voices[note].masterVol.connect(this.instrumentsIn);
      }
      return this.voices[note];
    };

    Instrument.prototype.killVoiceAtNote = function(note) {
      if (this.voices[note]) {
        return setTimeout((function(_this) {
          return function() {
            return _this.voices[note] = null;
          };
        })(this), (this.voices[note].asdr.getEnvelopeDuration() * 1000) + 1);
      }
    };

    Instrument.prototype.noteOn = function(note, length) {
      var noteLength, voice;
      if (this.noteTimers[note]) {
        clearTimeout(this.noteTimers[note]);
        this.noteTimers[note] = null;
      }
      voice = this.createVoice(note);
      if (length == null) {
        length = 0;
      }
      noteLength = this.autoRelease ? length : -1;
      voice.noteOn(noteLength);
      if (this.autoRelease) {
        this.noteTimers[note] = setTimeout((function(_this) {
          return function() {
            _this.voices[note].stop();
            _this.voices[note].masterVol.disconnect(0);
            _this.voices[note] = null;
            clearTimeout(_this.noteTimers[note]);
            _this.noteTimers[note] = null;
            if (_this.onNoteOff) {
              return _this.onNoteOff(note);
            }
          };
        })(this), (voice.asdr.getEnvelopeDuration() * 1000) + 10);
      }
      if (this.onNoteOn) {
        return this.onNoteOn(note, length);
      }
    };

    Instrument.prototype.notesOff = function() {
      var j, len, note, ref, results, voice;
      ref = this.voices;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        voice = ref[j];
        if (!voice) {
          continue;
        }
        note = voice.note;
        voice.noteOff();
        results.push(setTimeout((function(_this) {
          return function() {
            _this.voices[note] = null;
            clearTimeout(_this.noteTimers[note]);
            _this.noteTimers[note] = null;
            if (_this.onNoteOff) {
              return _this.onNoteOff(note);
            }
          };
        })(this), voice.asdr.release + 1));
      }
      return results;
    };

    return Instrument;

  })();

  window.Audanism.Audio.Instrument.Instrument = Instrument;

}).call(this);
