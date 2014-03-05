###
	Monoist synth - just a sine
###
class Monoist

	# Constructor
	constructor: (@note) ->

		# Connection point for all voices
		@effectChain        = Audanism.Audio.audioContext.createGain()

		# Overall volume control node
		@volNode            = Audanism.Audio.audioContext.createGain()
		@volNode.gain.value = 0.25

		# Hook it up to the "speakers"
		@effectChain.connect( @volNode )
		@volNode.connect( Audanism.Audio.audioContext.destination )


		# --- #


		# Tone frequency
		@freq = Audanism.Audio.Harmonizer.getFreqFromNote @note

		# Create, connect and start oscillator
		@osc = Audanism.Audio.audioContext.createOscillator()
		@osc.frequency.setValueAtTime @freq, 0
		@osc.connect @effectChain
		@osc.start 0



	# Play a note
	noteOn: (note) ->
		@osc.frequency.setValueAtTime( Audanism.Audio.Harmonizer.getFreqFromNote( note ), 0 )

	# Stop a note
	noteOff: () ->
		this.osc.stop (Audanism.Audio.audioContext.currentTime + 0.1)



window.Audanism.Audio.Synthesizer.Monoist = Monoist