
AudioContext = require '../AudioContext.coffee'

###
	Monoist synth - just a sine
###
class Monoist

	# Constructor
	constructor: (@note) ->

		# Connection point for all voices
		@effectChain        = AudioContext.createGain()

		# Overall volume control node
		@volNode            = AudioContext.createGain()
		@volNode.gain.value = 0.25

		# Hook it up to the "speakers"
		@effectChain.connect( @volNode )
		@volNode.connect( AudioContext.destination )


		# --- #


		# Tone frequency
		@freq = Audanism.Audio.Harmonizer.getFreqFromNote @note

		# Create, connect and start oscillator
		@osc = AudioContext.createOscillator()
		@osc.frequency.setValueAtTime @freq, 0
		@osc.connect @effectChain
		@osc.start 0



	# Play a note
	noteOn: (note) ->
		@osc.frequency.setValueAtTime( Audanism.Audio.Harmonizer.getFreqFromNote( note ), 0 )

	# Stop a note
	noteOff: () ->
		this.osc.stop (AudioContext.currentTime + 0.1)



module.exports = Monoist