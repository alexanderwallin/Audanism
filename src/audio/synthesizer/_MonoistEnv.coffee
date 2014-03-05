###
	MonoistEnv synth - sine with an envelope
###
class MonoistEnv extends Audanism.Audio.Synthesizer.Voice

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

		# Panner
		@panner             = Audanism.Audio.audioContext.createPanner()
		@panner.setPosition( 1 - Math.random() * 2, 0, 0 )
		@panner.connect( @compressor )

		# Envelope
		@asdr = new Audanism.Audio.Module.ASDR( 0.5, 1, 10, 0.1 )
		@envelope = Audanism.Audio.audioContext.createGain()
		@envelope.gain.setValueAtTime( 0, 0 )
		@envelope.connect( @panner )

		# Create, connect and start oscillator
		@osc = Audanism.Audio.audioContext.createOscillator()
		@osc.frequency.value = Audanism.Audio.Harmonizer.getFreqFromNote( @note )
		@osc.connect( @envelope )
		@osc.start( 0 )


	# Play a note
	noteOn: (note) ->
		now           = Audanism.Audio.audioContext.currentTime
		attackEndTime = now + @asdr.attack

		# Frequency
		#@osc.frequency.value = Audanism.Audio.Harmonizer.getFreqFromNote( note )

		# Attack
		@envelope.gain.cancelScheduledValues( now )
		@envelope.gain.setValueAtTime( @envelope.gain.value, now )
		@envelope.gain.linearRampToValueAtTime( 1, attackEndTime )

		# Decay + sustain
		@envelope.gain.setTargetAtTime( @asdr.sustain / 100, attackEndTime, (@asdr.decay / 100) + 0.001 )

		@noteIsOn = true


	# Kill a note
	noteOff: () ->
		now         = Audanism.Audio.audioContext.currentTime
		releaseTime = now + @asdr.release

		console.log(now)

		# Release
		@envelope.gain.cancelScheduledValues(now)
		@envelope.gain.setValueAtTime( @envelope.gain.value, now )
		#@envelope.gain.setTargetAtTime( 0, now, releaseTime )
		@envelope.gain.linearRampToValueAtTime( 0, releaseTime )

		#@osc.frequency.value = 0
		@noteIsOn = false
		



window.Audanism.Audio.Synthesizer.MonoistEnv = MonoistEnv