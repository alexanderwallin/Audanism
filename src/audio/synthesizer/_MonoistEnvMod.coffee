###
	MonoistEnvMulti synth - multiple oscillators with an envelope
###
class MonoistEnvMod

	# Constructor
	constructor: () ->

		@note = randomInt 40, 80

		@noteIsOn = false;

		# Chain end + volume control
		@volNode            = Audanism.Audio.audioContext.createGain()
		@volNode.gain.value = 0.25
		@volNode.connect( Audanism.Audio.audioContext.destination )

		# Compressor
		@compressor         = Audanism.Audio.audioContext.createDynamicsCompressor()
		@compressor.connect( @volNode )

		# Panners
		@panner1            = Audanism.Audio.audioContext.createPanner()
		@panner1.setPosition( 0.5 - Math.random() * 1, 0, 0 )
		@panner1.connect( @compressor )

		# Envelopes
		@asdr = new Audanism.Audio.Module.ASDR( 0.03, 0.1, 100, 0.1 )

		@envelope1 = Audanism.Audio.audioContext.createGain()
		@envelope1.gain.setValueAtTime( 0, 0 )
		@envelope1.connect( @panner1 )

		# Create, connect and start oscillators
		@osc1                 = Audanism.Audio.audioContext.createOscillator()
		@osc1.type            = 'sine'
		@osc1.frequency.value = Audanism.Audio.Module.Harmonizer.getFreqFromNote( @note )
		@osc1.connect( @envelope1 )

		# Frequency modulator
		@freqModGain1              = Audanism.Audio.audioContext.createGain()
		@freqModGain1.gain.value   = 10
		@freqModGain1.connect( @osc1.frequency )

		@freqMod1                  = Audanism.Audio.audioContext.createOscillator()
		@freqMod1.type             = 'square'
		@freqMod1.frequency.value  = 20
		@freqMod1.connect( @freqModGain1 )
		@freqMod1.start( 0 )

		@freqModGain2              = Audanism.Audio.audioContext.createGain()
		@freqModGain2.gain.value   = 15
		@freqModGain2.connect( @osc1.frequency )

		@freqMod2                  = Audanism.Audio.audioContext.createOscillator()
		@freqMod2.type             = 'triangle'
		@freqMod2.frequency.value  = 0.5
		@freqMod2.connect( @freqModGain2 )
		@freqMod2.start( 0 )

		# Start
		@osc1.start( 0 )


	# Play a note
	noteOn: (note) ->
		now           = Audanism.Audio.audioContext.currentTime
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
		now         = Audanism.Audio.audioContext.currentTime
		releaseTime = now + @asdr.release

		console.log(now)

		# Release
		@envelope1.gain.cancelScheduledValues(now)
		@envelope1.gain.setValueAtTime( @envelope1.gain.value, now )
		@envelope1.gain.linearRampToValueAtTime( 0, releaseTime )

		#@osc.frequency.value = 0
		@noteIsOn = false
		



window.Audanism.Audio.Synthesizer.MonoistEnvMod = MonoistEnvMod