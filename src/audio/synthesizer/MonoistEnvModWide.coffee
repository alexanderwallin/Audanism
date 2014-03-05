###
	MonoistEnvMulti synth - multiple oscillators with an envelope
###
class MonoistEnvModWide extends Audanism.Audio.Synthesizer.Voice

	# Constructor
	constructor: (note) ->

		super( note );

		# Envelopes
		@asdr = new Audanism.Audio.Module.ASDR( 0.03, 0.1, 100, 0.1 )

		@envelope = Audanism.Audio.audioContext.createGain()
		@envelope.gain.value = 0
		@envelope.connect( @pan )

		@envelopes.push( @envelope )

		# Oscillator pans
		@pan1 = Audanism.Audio.audioContext.createPanner()
		@pan1.setPosition( -1, 0, 0 )
		@pan1.connect( @envelope )

		@pan2 = Audanism.Audio.audioContext.createPanner()
		@pan2.setPosition( 1, 0, 0 )
		@pan2.connect( @envelope )

		@pan3 = Audanism.Audio.audioContext.createPanner()
		@pan3.setPosition( 0, 0, 0 )
		@pan3.connect( @envelope )

		# Create, connect and start oscillators
		@osc1                 = Audanism.Audio.audioContext.createOscillator()
		@osc1.type            = @getRandomOscType() #'sine'
		@osc1.frequency.value = Audanism.Audio.Module.Harmonizer.getFreqFromNote( @note )
		@osc1.connect( @pan1 )

		@osc2                 = Audanism.Audio.audioContext.createOscillator()
		@osc2.type            = @getRandomOscType() #'sine'
		@osc2.frequency.value = Audanism.Audio.Module.Harmonizer.getFreqFromNote( @note + 15 )
		@osc2.connect( @pan2 )

		@osc3                 = Audanism.Audio.audioContext.createOscillator()
		@osc3.type            = @getRandomOscType() #'triangle'
		@osc3.frequency.value = Audanism.Audio.Module.Harmonizer.getFreqFromNote( @note + 6.5 )
		@osc3.connect( @pan2 )

		@oscillators.push( @osc1 )
		@oscillators.push( @osc2 )
		@oscillators.push( @osc3 )

		# Frequency modulator
		@freqModGain1              = Audanism.Audio.audioContext.createGain()
		@freqModGain1.gain.value   = 5
		@freqModGain1.connect( @osc1.frequency )

		@freqMod1                  = Audanism.Audio.audioContext.createOscillator()
		@freqMod1.type             = 'square'
		@freqMod1.frequency.value  = 8
		@freqMod1.connect( @freqModGain1 )
		@freqMod1.start( 0 )

		@freqModGain2              = Audanism.Audio.audioContext.createGain()
		@freqModGain2.gain.value   = 5
		@freqModGain2.connect( @osc2.frequency )

		@freqMod2                  = Audanism.Audio.audioContext.createOscillator()
		@freqMod2.type             = 'triangle'
		@freqMod2.frequency.value  = 13.123
		@freqMod2.connect( @freqModGain2 )
		@freqMod2.start( 0 )

		@freqModGain3              = Audanism.Audio.audioContext.createGain()
		@freqModGain3.gain.value   = 15
		@freqModGain3.connect( @osc3.frequency )

		@freqMod3                  = Audanism.Audio.audioContext.createOscillator()
		@freqMod3.type             = 'sawtooth'
		@freqMod3.frequency.value  = 0.123
		@freqMod3.connect( @freqModGain3 )
		@freqMod3.start( 0 )

		# Start
		@osc1.start( 0 )
		@osc2.start( 0 )



window.Audanism.Audio.Synthesizer.MonoistEnvModWide = MonoistEnvModWide
