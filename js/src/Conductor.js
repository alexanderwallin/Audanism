// Generated by CoffeeScript 1.4.0

/*
	Conductor
*/


(function() {
  var Conductor;

  Conductor = (function() {

    function Conductor() {
      var AudioContext, i;
      try {
        AudioContext = window.AudioContext || window.webkitAudioContext;
        Audanism.Audio.audioContext = new AudioContext;
      } catch (e) {
        alert('Sorry, your browser does not support AudioContext, try Chrome!');
      }
      this.isMuted = false;
      this.createEndChain();
      this.noise = new Audanism.Audio.Instrument.NoisePink(this.instrumentsIn);
      this.factorDrones = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 0, _ref = Audanism.Environment.Organism.NUM_FACTORS - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
          _results.push(new Audanism.Audio.Instrument.Drone(this.instrumentsIn));
        }
        return _results;
      }).call(this);
      this.compareInstr = new Audanism.Audio.Instrument.TestInstrument(this.instrumentsIn);
      this.influencePad = new Audanism.Audio.Instrument.Pad(this.instrumentsIn);
      this.arpeggiator = new Audanism.Audio.Instrument.PercArpeggiator(this.instrumentsIn, 4, 0);
      this.arpeggiator.start();
      EventDispatcher.listen('audanism/iteration', this, this.updateSounds);
      EventDispatcher.listen('audanism/influence/node', this, this.handleNodeInfluence);
      EventDispatcher.listen('audanism/alternodes', this, this.handleNodeComparison);
      EventDispatcher.listen('audanism/performance/bad', this, this.onPermanceBad);
    }

    Conductor.prototype.createEndChain = function() {
      this["void"] = Audanism.Audio.audioContext.createOscillator();
      this["void"].frequency.value = 440;
      this.voidGain = Audanism.Audio.audioContext.createGain();
      this.voidGain.gain.value = 0.0;
      this.instrumentsIn = Audanism.Audio.audioContext.createGain();
      this.instrumentsIn.gain.value = 0.2;
      this.masterRev = new Audanism.Audio.FX.Reverb(2, 50, 1);
      this.compressor = Audanism.Audio.audioContext.createDynamicsCompressor();
      this.compressor.threshold.value = -24;
      this.compressor.ratio.value = 6;
      this.analyser = Audanism.Audio.audioContext.createAnalyser();
      this.analyser.fftSize = 512;
      this["void"].connect(this.voidGain);
      this.voidGain.connect(this.instrumentsIn);
      this["void"].start(0);
      this.instrumentsIn.connect(this.masterRev["in"]);
      this.masterRev.out.connect(this.compressor);
      this.instrumentsIn.connect(this.compressor);
      this.compressor.connect(this.analyser);
      return this.analyser.connect(Audanism.Audio.audioContext.destination);
    };

    Conductor.prototype.getFrequencyData = function() {
      var frequencyData;
      frequencyData = new Uint8Array(this.analyser.frequencyBinCount);
      this.analyser.getByteFrequencyData(frequencyData);
      return frequencyData;
    };

    Conductor.prototype.setOrganism = function(organism) {
      this.organism = organism;
    };

    Conductor.prototype.mute = function() {
      var drone, _i, _j, _len, _len1, _ref, _ref1, _results;
      console.log('Conductor #mute()');
      this.isMuted = true;
      _ref = this.factorDrones;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        drone = _ref[_i];
        drone.notesOff();
      }
      _ref1 = this.factorDrones;
      _results = [];
      for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
        drone = _ref1[_j];
        _results.push(drone.kill());
      }
      return _results;
    };

    Conductor.prototype.unmute = function() {
      var drone, _i, _len, _ref, _results;
      console.log('Conductor #unmute()');
      this.isMuted = false;
      _ref = this.factorDrones;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        drone = _ref[_i];
        _results.push(drone.noteOn(drone.droneNote));
      }
      return _results;
    };

    Conductor.prototype.updateSounds = function(iterationInfo) {
      var disharmonyData, disharmonyNew, disharmonyOld, disharmonyRatio, drone, factors, fd, note, _i, _len, _ref;
      if (this.isMuted) {
        return;
      }
      factors = this.organism.getFactors();
      fd = 0;
      _ref = this.factorDrones;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        drone = _ref[_i];
        note = Audanism.Audio.Module.Harmonizer.getNoteFromFreq(factors[fd].disharmony / 10);
        if (iterationInfo.count === 1) {
          drone.noteOn(note);
        } else {
          drone.setNote(note);
        }
        fd++;
      }
      if (iterationInfo.count % 10 === !0) {
        return;
      }
      disharmonyData = this.organism.getDisharmonyHistoryData(200);
      disharmonyNew = disharmonyData[disharmonyData.length - 1][2];
      disharmonyOld = disharmonyData[0][2];
      disharmonyRatio = disharmonyNew / disharmonyOld;
      if (iterationInfo.count % 4 === 1) {
        this.arpeggiator.midNote += disharmonyRatio > 1 ? 1 : -1;
      }
      if (iterationInfo.count % 9 === 1 && disharmonyData.length > 1) {
        this.arpeggiator.shuffleAmount = 0.01 * (Math.round(disharmonyNew) % 100);
      }
      if (iterationInfo.count % 10 === 1) {
        this.arpeggiator.setFrequency(disharmonyRatio * 2);
      }
      if (this.noise != null) {
        return this.noise.setLpfFrequency(disharmonyRatio * 1000);
      }
    };

    Conductor.prototype.handleNodeComparison = function(comparisonData) {
      var freq, i, node, note, _i, _ref, _results;
      if (this.muted) {
        return;
      }
      _results = [];
      for (i = _i = 0, _ref = comparisonData.nodes.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        node = comparisonData.nodes[i];
        freq = 80 + Math.pow(node.getCell(comparisonData.factorType).factorValue, 1.1);
        note = Audanism.Audio.Module.Harmonizer.getNoteFromFreq(freq);
        _results.push(this.compareInstr.noteOn(note));
      }
      return _results;
    };

    Conductor.prototype.handleNodeInfluence = function(influenceData) {
      var nodeFreq, nodeId, nodePan;
      if (this.muted) {
        return;
      }
      if (!this.organism || !influenceData.meta) {
        return;
      }
      nodeId = influenceData.node.node.nodeId;
      nodeFreq = 80 + (nodeId * 40);
      nodePan = nodeId / this.organism.getNodes().length;
      return this.influencePad.noteOn(Audanism.Audio.Module.Harmonizer.getNoteFromFreq(nodeFreq));
    };

    Conductor.prototype.onPermanceBad = function() {
      var arpFreq,
        _this = this;
      if (this.isMuted) {
        return;
      }
      this.mute();
      console.log(' ··············· pause conductor');
      arpFreq = this.arpeggiator.frequency;
      this.arpeggiator.setFrequency(0.2);
      return setTimeout(function() {
        console.log(' ··············· resume conductor');
        _this.unmute();
        return _this.arpeggiator.setFrequency(arpFreq);
      }, 10000);
    };

    return Conductor;

  })();

  window.Audanism.Audio.Conductor = Conductor;

}).call(this);
