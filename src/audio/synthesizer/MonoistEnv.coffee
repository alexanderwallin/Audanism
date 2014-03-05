###
	MonoistEnv synth - sine with an envelope
###
class MonoistEnv extends Audanism.Audio.Synthesizer.Voice

	# Constructor
	constructor: (note) ->

		super(note)

		# Envelope
		@asdr = new Audanism.Audio.Module.ASDR( 0.2, 0.2, 0.7, 0.7 )
		@envelope = Audanism.Audio.audioContext.createGain()
		@envelope.gain.setValueAtTime( 0, 0 )

		@envelopes.push( @envelope )

		# Create, connect and start oscillator
		@osc                 = Audanism.Audio.audioContext.createOscillator()
		@osc.type            = @getRandomOscType()
		@osc.frequency.value = Audanism.Audio.Module.Harmonizer.getFreqFromNote( @note )
		
		@oscillators.push( @osc )

		# Connect and start
		@osc.connect( @envelope )
		@envelope.connect( @pan )
		@osc.start( 0 )



window.Audanism.Audio.Synthesizer.MonoistEnv = MonoistEnv
