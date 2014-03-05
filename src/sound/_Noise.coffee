###
	Noise synth
###
class Noise

	constructor: (@audiolet) ->
		@gen = new WhiteNoise(@audiolet)
		@lpf = new LowPassFilter(@audiolet, 200)
		@gain = new Gain(@audiolet, 0.001);
		@limiter = new Limiter(@audiolet, 0.1, 0.1, 0.8)

		@gen.connect     @lpf
		@lpf.connect     @gain
		@gain.connect    @limiter
		@limiter.connect @audiolet.output


Audanism.Sound.Noise = Noise