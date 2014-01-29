###
	Synth base class
###
class Synth

	constructor: (@audiolet, freq) ->
		console.log 'new Synth', freq
		@gen = new Sine(@audiolet, freq)

		@mod = new Saw(@audiolet, freq * 2)
		@modMulAdd = new MulAdd(@audiolet, freq / 2, freq)

		@gain = new Gain(@audiolet)

		#envEnd = () ->
		#	@audiolet.scheduler.addRelative(0, @remove.bind(this))
		#envEnd.bind(@)

		@env = new PercussiveEnvelope @audiolet, 0, 0.02, 0.1

		# Connect
		@mod.connect @modMulAdd
		@modMulAdd.connect @gen
		@env.connect @gain, 0, 1
		@gen.connect @gain
		@gain.connect @audiolet.output





Audanism.Sound.Synth = Synth