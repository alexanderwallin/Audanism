
AudioContext = require '../AudioContext.coffee'
Voice = require './Voice.coffee'
ASDR = require '../module/ASDR.coffee'
Harmonizer = require '../module/Harmonizer.coffee'

###
	MonoistEnvMulti synth - multiple oscillators with an envelope
###
class MonoistEnvMod extends Voice

	# Constructor
	constructor: (note) ->
		super(note)

		# Envelopes
		@asdr = new ASDR( 0.03, 0.01, 100, 1.5 )

		@envelope1 = AudioContext.createGain()
		@envelope1.gain.setValueAtTime( 0, 0 )
		@envelope1.connect( @pan )

		@envelopes.push( @envelope1 )

		# Create, connect and start oscillators
		@osc1                 = AudioContext.createOscillator()
		@osc1.type            = @getRandomOscType() #'sine'
		@osc1.frequency.value = Harmonizer.getFreqFromNote( @note )
		@osc1.connect( @envelope1 )

		@oscillators.push( @osc1 )

		# Frequency modulator
		@freqModGain1              = AudioContext.createGain()
		@freqModGain1.gain.value   = 5
		@freqModGain1.connect( @osc1.frequency )

		@freqMod1                  = AudioContext.createOscillator()
		@freqMod1.type             = @getRandomOscType() #'square'
		@freqMod1.frequency.value  = 20
		@freqMod1.connect( @freqModGain1 )
		@freqMod1.start( 0 )

		@freqModGain2              = AudioContext.createGain()
		@freqModGain2.gain.value   = 7
		@freqModGain2.connect( @osc1.frequency )

		@freqMod2                  = AudioContext.createOscillator()
		@freqMod2.type             = @getRandomOscType() #'triangle'
		@freqMod2.frequency.value  = 6.234
		@freqMod2.connect( @freqModGain2 )
		@freqMod2.start( 0 )

		# Start
		@osc1.start( 0 )

	###
	# Play a note
	noteOn: (note) ->
		now           = AudioContext.currentTime
		attackEndTime = now + @asdr.attack

		# Attack
		@envelope1.gain.cancelScheduledValues( now )
		@envelope1.gain.setValueAtTime( @envelope1.gain.value, now )
		@envelope1.gain.linearRampToValueAtTime( 1, attackEndTime )

		# Decay + sustain
		@envelope1.gain.setTargetAtTime( @asdr.sustain / 100, attackEndTime, (@asdr.decay / 100) + 0.001 )

		@noteIsOn = true


	# Kill a note
	noteOff: () ->
		now         = AudioContext.currentTime
		releaseTime = now + @asdr.release

		console.log(now)

		# Release
		@envelope1.gain.cancelScheduledValues(now)
		@envelope1.gain.setValueAtTime( @envelope1.gain.value, now )
		@envelope1.gain.linearRampToValueAtTime( 0, releaseTime )

		#@osc.frequency.value = 0
		@noteIsOn = false
	###



module.exports = MonoistEnvMod