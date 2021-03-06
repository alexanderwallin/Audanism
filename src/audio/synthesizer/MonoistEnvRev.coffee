
AudioContext = require '../AudioContext.coffee'

###
	MonoistEnvRev synth - sine with an envelope and reverb
###
class MonoistEnvRev

	# Constructor
	constructor: () ->

		@note = randomInt 40, 80

		@noteIsOn = false;

		# Chain end + volume control
		@volNode            = AudioContext.createGain()
		@volNode.gain.value = 0.25
		@volNode.connect( AudioContext.destination )

		# Compressor
		@compressor         = AudioContext.createDynamicsCompressor()
		@compressor.connect( @volNode )

		# Dry/wet
		@dry                = AudioContext.createGain()
		@dry.gain.value     = 0.8
		@dry.connect( @compressor )
		@wet                = AudioContext.createGain()
		@wet.gain.value     = 0.5
		@wet.connect( @compressor )

		# Reverbs
		@impulse            = new Audanism.Audio.Module.Impulse( 0.2, 50 )
		@rev1               = AudioContext.createConvolver()
		@rev1.buffer        = @impulse.getBuffer()
		@rev1.connect( @wet )

		# Panners
		@panner1            = AudioContext.createPanner()
		@panner1.setPosition( 1 - Math.random() * 2, 0, 0 )
		@panner1.connect( @dry )
		@panner1.connect( @rev1 )

		# Envelope
		@asdr = new Audanism.Audio.Module.ASDR( 0.5, 0.1, 10, 0.1 )
		@envelope = AudioContext.createGain()
		@envelope.gain.setValueAtTime( 0, 0 )
		@envelope.connect( @panner1 )

		# Create, connect and start oscillator
		@osc = AudioContext.createOscillator()
		@osc.frequency.value = Audanism.Audio.Harmonizer.getFreqFromNote( @note )
		@osc.connect( @envelope )
		@osc.start( 0 )


	# Play a note
	noteOn: (note) ->
		now           = AudioContext.currentTime
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
		now         = AudioContext.currentTime
		releaseTime = now + @asdr.release

		console.log(now)

		# Release
		@envelope.gain.cancelScheduledValues(now)
		@envelope.gain.setValueAtTime( @envelope.gain.value, now )
		#@envelope.gain.setTargetAtTime( 0, now, releaseTime )
		@envelope.gain.linearRampToValueAtTime( 0, releaseTime )

		#@osc.frequency.value = 0
		@noteIsOn = false
		



module.exports = MonoistEnvRev