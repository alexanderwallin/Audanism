
AudioContext = require '../AudioContext.coffee'
Voice = require './Voice.coffee'
ASDR = require '../module/ASDR.coffee'
Harmonizer = require '../module/Harmonizer.coffee'

###
	MonoistEnvMulti synth - multiple oscillators with an envelope
###
class MonoistEnvModWide extends Voice

	# Constructor
	constructor: (note, @unison = true) ->

		super( note );

		@extraNotes = [19, 27, 13]
		@extraNotes.shuffle()

		# Envelopes
		@asdr = new ASDR( 0.03, 0.1, 100, 0.1 )

		@envelope = AudioContext.createGain()
		@envelope.gain.value = 0
		@envelope.connect( @pan )

		@envelopes.push( @envelope )

		# Oscillator pans
		@pan1 = AudioContext.createPanner()
		@pan1.setPosition( -1, 0, 0 )
		@pan1.connect( @envelope )

		@pan2 = AudioContext.createPanner()
		@pan2.setPosition( 1, 0, 0 )
		@pan2.connect( @envelope )

		@pan3 = AudioContext.createPanner()
		@pan3.setPosition( 0, 0, 0 )
		@pan3.connect( @envelope )

		# Create, connect and start oscillators
		@osc1                 = AudioContext.createOscillator()
		@osc1.type            = @getRandomOscType() #'sine'
		@osc1.frequency.value = Harmonizer.getFreqFromNote( @note + (if @unison then 0 else @extraNotes[0]) )
		@osc1.connect( @pan1 )

		@osc2                 = AudioContext.createOscillator()
		@osc2.type            = @getRandomOscType() #'sine'
		@osc2.frequency.value = Harmonizer.getFreqFromNote( @note + (if @unison then 0 else @extraNotes[1]) )
		@osc2.connect( @pan2 )

		@osc3                 = AudioContext.createOscillator()
		@osc3.type            = @getRandomOscType() #'triangle'
		@osc3.frequency.value = Harmonizer.getFreqFromNote( @note + (if @unison then 0 else @extraNotes[2]) )
		@osc3.connect( @pan2 )

		@oscillators.push( @osc1 )
		@oscillators.push( @osc2 )
		@oscillators.push( @osc3 )

		# Frequency modulator
		@freqModGain1              = AudioContext.createGain()
		@freqModGain1.gain.value   = 5
		@freqModGain1.connect( @osc1.frequency )

		@freqMod1                  = AudioContext.createOscillator()
		@freqMod1.type             = @getRandomOscType() # 'square'
		@freqMod1.frequency.value  = 8
		@freqMod1.connect( @freqModGain1 )
		@freqMod1.start( 0 )

		@freqModGain2              = AudioContext.createGain()
		@freqModGain2.gain.value   = 5
		@freqModGain2.connect( @osc2.frequency )

		@freqMod2                  = AudioContext.createOscillator()
		@freqMod2.type             = @getRandomOscType() # 'triangle'
		@freqMod2.frequency.value  = 13.123
		@freqMod2.connect( @freqModGain2 )
		@freqMod2.start( 0 )

		@freqModGain3              = AudioContext.createGain()
		@freqModGain3.gain.value   = 15
		@freqModGain3.connect( @osc3.frequency )

		@freqMod3                  = AudioContext.createOscillator()
		@freqMod3.type             = @getRandomOscType() # 'sawtooth'
		@freqMod3.frequency.value  = 0.123
		@freqMod3.connect( @freqModGain3 )
		@freqMod3.start( 0 )

		# Start
		@osc1.start( 0 )
		@osc2.start( 0 )
		@osc3.start( 0 )

	setUnison: (@unison) ->
		#console.log 'MonoistEnvModWide #setUnison', @unison

		for i in [0..@oscillators.length-1]
			extraNote = if @unison then 0 else @extraNotes[i]
			@oscillators[i].frequency.value = Harmonizer.getFreqFromNote( @note + extraNote )

module.exports = MonoistEnvModWide
