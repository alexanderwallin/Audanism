###
	Synth2
###
class Synth2

	constructor: (freq) ->
		console.log 'new Synth', freq

		@freq = freq
		@audiolet = new Audiolet()

		SynthObj = (audiolet) ->
			AudioletGroup.apply(@, [audiolet, 0, 1])

			# Basic wave
			@saw = new Saw(audiolet, 500)

			# Frequency LFO
			@frequencyLFO = new Sine(audiolet, 2)
			@frequencyMA = new MulAdd(audiolet, 10, 100)

			# Filter
			@filter = new LowPassFilter(audiolet, 1000)

			# Filter LFO
			@filterLFO = new Sine(audiolet, 8)
			@filterMA = new MulAdd(audiolet, 900, 1000)

			# Gain envelope
			envEnd = () ->
				console.log 'envelope end', @
				@audiolet.scheduler.addRelative(0, @remove.bind(this))
			envEnd.bind(@)

			@gain = new Gain(audiolet)
			@gain.gain.setValue(0)
			@env = new ADSREnvelope audiolet, 0, .1, 0.2, 0.9, 0.5
			#, envEnd

			# Main signal path
			@saw.connect(@filter)
			@filter.connect(@gain)
			@gain.connect(@outputs[0])

			# Frequency LFO
			@frequencyLFO.connect(@frequencyMA)
			@frequencyMA.connect(@saw)

			# Filter LFO
			@filterLFO.connect(@filterMA)
			@filterMA.connect(@filter, 0, 1)

			# Envelope
			@env.connect(@gain, 0, 1)
		
		extend(SynthObj, AudioletGroup)

		@synth = new SynthObj(@audiolet)
		@synth.connect(@audiolet.output)


	hit: () ->
		console.log '--> hit!'

		frequencyPattern = new PSequence([55, 98], 2)
		filterLFOPattern = new PChoose([2, 4], 2)
		gatePattern = new PSequence([1, 0], 2)

		patterns = [frequencyPattern, filterLFOPattern, gatePattern]

		callback = (frequency, filterLFOFrequency, gate) =>
			console.log('callback', @, frequency, filterLFOFrequency, gate)
			@synth.frequencyMA.add.setValue(frequency)
			@synth.filterLFO.frequency.setValue(filterLFOFrequency)
			@synth.env.gate.setValue(gate)
		#callback.bind(@synth)

		@audiolet.scheduler.play(patterns, 2, callback)
		



Audanism.Sound.Synth2 = Synth2