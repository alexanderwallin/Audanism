
AudioContext = require '../AudioContext.coffee'
Voice = require './Voice.coffee'
ASDR = require '../module/ASDR.coffee'
Harmonizer = require '../module/Harmonizer.coffee'

###
	MonoistEnv synth - sine with an envelope
###
class MonoistEnv extends Voice

	# Constructor
	constructor: (note) ->

		super(note)

		# Envelope
		@asdr = new ASDR( 0.2, 0.1, 0.7, 0.2 )
		@envelope = AudioContext.createGain()
		@envelope.gain.setValueAtTime( 0, 0 )

		@envelopes.push( @envelope )

		# Create, connect and start oscillator
		@osc                 = AudioContext.createOscillator()
		@osc.type            = 'sine' #@getRandomOscType()
		@osc.frequency.value = Harmonizer.getFreqFromNote( @note )
		
		@oscillators.push( @osc )

		# Connect and start
		@osc.connect( @envelope )
		@envelope.connect( @pan )
		@osc.start( 0 )



module.exports = MonoistEnv
