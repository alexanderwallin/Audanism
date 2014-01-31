(function() {

var NodeInfluenceSoundSynth2 = function(audiolet, frequency, pan) {
	AudioletGroup.call(this, audiolet, 0, 1);

	console.log('#NodeInfluenceSoundSynth2', frequency, pan);
	
	// Basic wave
	genType = Math.floor(Math.random() * 4)
	switch (genType) {
		case 0: this.gen = new Sine(audiolet, frequency); break;
		case 1: this.gen = new Saw(audiolet, frequency); break;
		case 2: this.gen = new Triangle(audiolet, frequency); break;
		case 3: this.gen = new Square(audiolet, frequency); break;
	}

	// Modulation
	this.modulator = new Saw(this.audiolet, 2 * frequency);
	this.modulatorMulAdd = new MulAdd(audiolet, frequency / 2, frequency);

	// Gain envelope
	this.gain = new Gain(audiolet);
	/*this.env = new PercussiveEnvelope(audiolet, 0.1, 0.2, 1,
		function() {
			this.audiolet.scheduler.addRelative(0, this.remove.bind(this));
		}.bind(this)
	);*/
	//this.envMulAdd = new MulAdd(audiolet, 0.3, 0);
	this.env = new ADSREnvelope(audiolet,
								1,    // Gate
								0.2, // Attack
								0.1,  // Decay
								0.1,  // Sustain
								2,  // Release
								function() {
									this.audiolet.scheduler.addRelative(0, this.remove.bind(this));
								}.bind(this)
								);

	// Pan
	pan = pan || 0.5;
	console.log('	pan =', pan);
	this.pan = new Pan(audiolet, pan);

	// Main signal path
	//this.modulator.connect(this.modulatorMulAdd);
	//this.modulatorMulAdd.connect(this.gen);
	this.gen.connect(this.gain);
	this.gain.connect(this.pan);
	this.pan.connect(this.outputs[0])

	// Envelope
	//this.env.connect(this.envMulAdd);
	//this.envMulAdd.connect(this.gain, 0, 1);
	this.env.connect(this.gain, 0, 1);
};
extend(NodeInfluenceSoundSynth2, AudioletGroup);

var NodeInfluenceSound2 = function() {
	this.audiolet = new Audiolet();
};

NodeInfluenceSound2.prototype.hit = function(freq, pan, length) {
	console.log('#NodeInfluenceSound2.hit', freq, pan, length);
	var synth = new NodeInfluenceSoundSynth2(this.audiolet, freq, pan);

	//var freqPattern = new PSequence([freq]);
	//var panPattern = new PSequence([pan]);
	var gatePattern = new PSequence([1, 0]);
	
	this.audiolet.scheduler.play([gatePattern], length, function(gate) {
		console.log('influence synth callback ··· gate =', gate, this);
		this.env.gate.setValue(gate);
	}.bind(synth));

	synth.connect(this.audiolet.output);
};

window.Audanism.Sound.Instrument.NodeInfluenceSound2 = NodeInfluenceSound2;

})();