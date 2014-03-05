###
	MonoistEnv synth - sine with an envelope
###
class MonoistPerc

	# Constructor
	constructor: () ->

		# Chain end + volume control
		@volNode            = Audanism.Audio.audioContext.createGain()
		@volNode.gain.value = 0.25
		@volNode.connect( Audanism.Audio.audioContext.destination )

		# Compressor
		@compressor         = Audanism.Audio.audioContext.createDynamicsCompressor()
		@compressor.connect( @volNode )

		# Panner
		@panner             = Audanism.Audio.audioContext.createPanner()
		@panner.setPosition( 1 - Math.random() * 2, 0, 0 )
		@panner.connect( @compressor )

		# Envelope
		@asdr = new Audanism.Audio.Module.ASDR( 0.1, 0.1, 0.1, 0.5 )
		@envelope = Audanism.Audio.audioContext.createGain()
		@envelope.gain.setValueAtTime( 0, 0 )
		@envelope.connect( @panner )

		# Create, connect and start oscillator
		@osc = Audanism.Audio.audioContext.createOscillator()
		@osc.frequency.value = 440
		@osc.connect( @envelope )
		@osc.start( 0 )


	# Play a note
	hit: (note) ->
		now            = Audanism.Audio.audioContext.currentTime
		attackEndTime  = now + @asdr.attack
		decayEndTime   = attackEndTime + @asdr.decay
		releaseEndTime = decayEndTime + @asdr.release

		# Frequency
		@osc.frequency.value = Audanism.Audio.Harmonizer.getFreqFromNote( note )

		# Attack
		@envelope.gain.cancelScheduledValues( now )
		@envelope.gain.setValueAtTime( 0, now )

		#@envelope.gain.linearRampToValueAtTime( 1, attackEndTime )
		#@envelope.gain.linearRampToValueAtTime( @asdr.sustain, decayEndTime )
		#@envelope.gain.linearRampToValueAtTime( 0, releaseEndTime )

		@envelope.gain.exponentialRampToValueAtTime( 1, attackEndTime )
		@envelope.gain.exponentialRampToValueAtTime( @asdr.sustain, decayEndTime )
		@envelope.gain.exponentialRampToValueAtTime( 0, releaseEndTime + 0.2 )

		# Decay + sustain
		#@envelope.gain.setTargetAtTime( @asdr.sustain / 100, attackEndTime, (@asdr.decay / 100) + 0.001 )


		#@envelope.gain.setTargetAtTime( 0, now, releaseTime )

		



window.Audanism.Audio.Synthesizer.MonoistPerc = MonoistPerc