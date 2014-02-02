(function() {

var NodeInfluenceSoundSynth1 = function(audiolet, frequency, pan) {
	AudioletGroup.call(this, audiolet, 0, 1);
	
	// Basic wave
	this.gen = new Sine(audiolet, frequency);

	// Modulation
	this.modulator = new Saw(this.audiolet, 2 * frequency);
	this.modulatorMulAdd = new MulAdd(audiolet, frequency / 2, frequency);

	// Gain envelope
	this.gain = new Gain(audiolet);
	this.env = new PercussiveEnvelope(audiolet, 1, 0.01, 0.2,
		function() {
			this.audiolet.scheduler.addRelative(0, this.remove.bind(this));
		}.bind(this)
	);
	this.envMulAdd = new MulAdd(audiolet, 0.3, 0);

	// Pan
	pan = pan || 0.5;
	//console.log('	pan =', pan);
	this.pan = new Pan(audiolet, pan);

	// Main signal path
	this.modulator.connect(this.modulatorMulAdd);
	this.modulatorMulAdd.connect(this.gen);
	this.gen.connect(this.gain);
	this.gain.connect(this.pan);
	this.pan.connect(this.outputs[0])

	// Envelope
	this.env.connect(this.envMulAdd);
	this.envMulAdd.connect(this.gain, 0, 1);
};
extend(NodeInfluenceSoundSynth1, AudioletGroup);

var NodeInfluenceSound1 = function(freq, pan) {
	this.audiolet = new Audiolet();

	var freqPattern = new PSequence([freq]);
	var panPattern = new PSequence([pan]);
	
	this.audiolet.scheduler.play([freqPattern, panPattern], 1, this.play.bind(this));
};

NodeInfluenceSound1.prototype.play = function(freq, pan) {
	var synth = new NodeInfluenceSoundSynth1(this.audiolet, freq, pan);
	synth.connect(this.audiolet.output);
};

window.Audanism.Sound.Instrument.NodeInfluenceSound1 = NodeInfluenceSound1;

})();