(function(){

var NodeComparisonSoundSynth1 = function(audiolet, freq) {
	AudioletGroup.apply(this, [audiolet, 0, 1]);

	// Basic wave
	this.saw = new Sine(audiolet, freq);

	// Filter
	this.filter = new LowPassFilter(audiolet, 200);

	// Filter LFO
	this.filterLFO = new Sine(audiolet, 0.3);
	this.filterMA = new MulAdd(audiolet, freq / 2, freq * 2);

	// Gain envelope
	this.gain = new Gain(audiolet);
	this.env = new ADSREnvelope(audiolet,
								1,    // Gate
								0.01, // Attack
								0.2,  // Decay
								0.2,  // Sustain
								0.4,  // Release
								function() {
									this.audiolet.scheduler.addRelative(0, this.remove.bind(this));
								}.bind(this)
								);

	// Reverb
	this.verb = new Reverb(audiolet, 0.5, 0.5, 0.7);
	this.verbHPF = new HighPassFilter(audiolet, 100);
	//this.gain.connect(this.verb);
	//this.verb.connect(this.verbHPF);
	//this.verbHPF.connect(this.outputs[0]);

	// Main signal path
	this.saw.connect(this.filter);
	this.filter.connect(this.gain);

	// Filter LFO
	this.filterLFO.connect(this.filterMA);
	this.filterMA.connect(this.filter, 0, 1);

	// Envelope
	this.env.connect(this.gain, 0, 1);
	this.gain.connect(this.outputs[0]);
};
extend(NodeComparisonSoundSynth1, AudioletGroup);

var NodeComparisonSound1 = function() {
	this.audiolet = new Audiolet();
}

NodeComparisonSound1.prototype.hit = function(freq, length) {
	var synth = new NodeComparisonSoundSynth1(this.audiolet, freq);

	var gatePattern = new PSequence([1, 0], 1);

	var patterns = [gatePattern];
	this.audiolet.scheduler.play(patterns, length, function(gate) {
			this.env.gate.setValue(gate);
		}.bind(synth)
	);

	synth.connect(this.audiolet.output);
};


window.Audanism.Sound.Instrument.NodeComparisonSound1 = NodeComparisonSound1;

})();