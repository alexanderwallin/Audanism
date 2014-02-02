(function(){

var InfluenceActionSoundSynth1 = function(audiolet, modRate, modFreq1, modFreq2) {

	AudioletGroup.apply(this, [audiolet, 0, 1]);
	// Basic wave
	this.saw = new Sine(audiolet, 6000);

	// Frequency LFO
	this.frequencyLFO = new Sine(audiolet, modRate);
	this.frequencyMA = new MulAdd(audiolet, modFreq1, modFreq2);

	// Filter
	this.filter = new LowPassFilter(audiolet, 200);

	// Filter LFO
	this.filterLFO = new Sine(audiolet, 0.3);
	this.filterMA = new MulAdd(audiolet, 40, 440);

	// Gain envelope
	this.gain = new Gain(audiolet, 1);
	this.env = new ADSREnvelope(audiolet,
								1, // Gate
								0.01, // Attack
								0.1, // Decay
								0.1, // Sustain
								0.1); // Release

	// Reverb
	/*
	this.verb = new Reverb(audiolet, 0.5, 0.5, 0.7);
	this.verbHPF = new HighPassFilter(audiolet, 100);
	this.gain.connect(this.verb);
	this.verb.connect(this.verbHPF);
	this.verbHPF.connect(this.outputs[0]);
	*/

	// Pan
	this.pan = new Pan(audiolet, 1 - (Math.random() * 2));

	// Main signal path
	this.saw.connect(this.filter);
	this.filter.connect(this.gain);
	this.gain.connect(this.pan);
	this.pan.connect(this.outputs[0]);

	// Frequency LFO
	this.frequencyLFO.connect(this.frequencyMA);
	this.frequencyMA.connect(this.saw);

	// Filter LFO
	this.filterLFO.connect(this.filterMA);
	this.filterMA.connect(this.filter, 0, 1);

	// Envelope
	this.env.connect(this.gain, 0, 1);
};
extend(InfluenceActionSoundSynth1, AudioletGroup);

var InfluenceActionSound1 = function() {
	this.audiolet = new Audiolet();

	this.modRate = 1 + Math.random() * 2;
	this.modFreqs = {
		'low': 800 + Math.random() * 400,
		'high': 1600 + Math.random() * 800
	};
}

InfluenceActionSound1.prototype.hit = function() {
	var synth = new InfluenceActionSoundSynth1(this.audiolet, this.modRate, this.modFreqs.low, this.modFreqs.high);

	var frequencyPattern = new PChoose([55, 55, 98, 98, 73, 73, 98, 98], Infinity);
	var filterLFOPattern = new PChoose([2, 4, 6, 8], Infinity);
	var gatePattern = new PChoose([1, 0, 1, 0, 0, 1, 0, 1, 0, 1, 0, 0, 0, 1, 0], Infinity);

	var patterns = [frequencyPattern, filterLFOPattern, gatePattern];
	this.audiolet.scheduler.play(patterns, 0.3,
		function(frequency, filterLFOFrequency, gate) {
			//this.saw.frequency.set(frequency);
			//this.frequencyMA.add.setValue(frequency);
			//this.filterLFO.frequency.setValue(filterLFOFrequency);
			this.env.gate.setValue(gate);
		}.bind(synth)
	);

	synth.connect(this.audiolet.output);
};

window.Audanism.Sound.Instrument.InfluenceActionSound1 = InfluenceActionSound1;

})();