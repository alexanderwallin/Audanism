###
	Synth base class
###
class Synth

	constructor: (freq) ->
		console.log 'new Synth', freq

		@freq = freq
		@audiolet = new Audiolet()

		SynthObj = (audiolet, freq) ->
			AudioletGroup.call @, audiolet, 0, 1

			@gen = new Sine(audiolet, freq)
			@mod = new Saw(audiolet, freq * 2)
			@modMulAdd = new MulAdd(audiolet, freq / 2, freq)

			@gain = new Gain(audiolet, 0.01)

			#envEnd = () ->
			#	@audiolet.scheduler.addRelative(0, @remove.bind(this))
			#envEnd.bind(@)

			@env = new PercussiveEnvelope audiolet, 0, 0.1, 0.5

			# Connect
			@mod.connect @modMulAdd
			@modMulAdd.connect @gen
			@env.connect @gain, 0, 1
			@gen.connect @gain
			@gain.connect @outputs[0]

			@

		extend SynthObj, AudioletGroup

		@synth = new SynthObj(@audiolet, freq)
		#@synth.connect @audiolet.output

	hit: () ->
		console.log '--> hit!'

		freqPattern = new PSequence [@freq], 2
		gatePattern = new PSequence [0, 1], 2

		callback = (freq, gate) =>
			@synth.env.gate.setValue gate
			@synth.gen.frequency.setValue freq
		callback.bind @synth

		#@audiolet.scheduler.play [freqPattern, gatePattern], 2, callback







Audanism.Sound.Synth = Synth