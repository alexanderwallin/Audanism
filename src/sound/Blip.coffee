
BlipObj = (audiolet) ->
	AudioletGroup.apply(@, [audiolet, 0, 1])

	# Basic wave
	@gen = new Sine(audiolet, 200 + (Math.random() * 1000))

	# Gain envelope
	envEnd = () ->
		console.log 'envelope end', @
		@audiolet.scheduler.addRelative(0, @remove.bind(this))
	envEnd.bind(@)

	@gain = new Gain(audiolet, 0.5)
	@env = new ADSREnvelope(audiolet, 1, .1, 0.2, 0.9, 0.5) #, envEnd)
	#, envEnd

	# Main signal path
	@env.connect(@gain, 0, 1)
	@gain.connect(@outputs[0])

extend(BlipObj, AudioletGroup)


###
	Blip
###
class Blip

	constructor: (freq) ->
		console.log 'new Synth', freq

		@freq = freq
		@audiolet = new Audiolet()

		@synth = new BlipObj(@audiolet)
		@synth.connect(@audiolet.output)


	hit: () ->
		console.log '--> hit!'

		gatePattern = new PSequence([1, 0], 2)

		patterns = [gatePattern]

		callback = (gate) ->
			console.log('callback', @, gate)
			@env.gate.setValue(gate)
		callback.bind(@synth)

		@audiolet.scheduler.play patterns, 2, (gate) =>
			console.log('callback', @, gate);
			@.synth.env.gate.setValue(gate)

		return
		



Audanism.Sound.BlipObj = BlipObj
Audanism.Sound.Blip = Blip