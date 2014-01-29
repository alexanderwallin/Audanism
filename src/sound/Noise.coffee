###
	Noise synth
###
class Noise

	constructor: (@audiolet) ->
		@gen = new WhiteNoise(@audiolet)
		@lpf = new LowPassFilter(@audiolet, 200)
		@gain = new Gain(@audiolet, 0);

		@gen.connect  @lpf
		@lpf.connect  @gain
		@gain.connect @audiolet.output


Audanism.Sound.Noise = Noise