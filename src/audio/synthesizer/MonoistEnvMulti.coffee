
AudioContext = require '../AudioContext.coffee'
Voice = require './Voice.coffee'
ASDR = require '../module/ASDR.coffee'
Harmonizer = require '../module/Harmonizer.coffee'

###
	MonoistEnvMulti synth - multiple oscillators with an envelope
###
class MonoistEnvMulti

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

		# Panners
		@panner1            = AudioContext.createPanner()
		@panner1.setPosition( -1, 0, 0 )
		@panner1.connect( @compressor )

		@panner2            = AudioContext.createPanner()
		@panner2.setPosition( 1, 0, 0 )
		@panner2.connect( @compressor )

		@panner3            = AudioContext.createPanner()
		@panner3.setPosition( 0, 0, 0 )
		@panner3.connect( @compressor )

		# Envelopes
		@asdr = new ASDR( 0.1, 0.1, 100, 0.1 )

		@envelope1 = AudioContext.createGain()
		@envelope1.gain.setValueAtTime( 0, 0 )
		@envelope1.connect( @panner1 )

		@envelope2 = AudioContext.createGain()
		@envelope2.gain.setValueAtTime( 0, 0 )
		@envelope2.connect( @panner2 )

		@envelope3 = AudioContext.createGain()
		@envelope3.gain.setValueAtTime( 0, 0 )
		@envelope3.connect( @panner3 )

		# Create, connect and start oscillators
		

		@osc1                 = AudioContext.createOscillator()
		@osc1.type            = 'sine'
		@osc1.frequency.value = Harmonizer.getFreqFromNote( @note )
		@osc1.connect( @envelope1 )
		@osc1.start( 0 )
		
		@osc2                 = AudioContext.createOscillator()
		@osc2.type            = 'triangle'
		@osc2.frequency.value = Harmonizer.getFreqFromNote( @note * 1 )
		@osc2.connect( @envelope2 )
		@osc2.start( 0 )
		###
		@osc3                 = AudioContext.createOscillator()
		@osc3.type            = 'square'
		@osc3.frequency.value = Harmonizer.getFreqFromNote( @note / 2 )
		@osc3.connect( @envelope3 )
		@osc3.start( 0 )
		###


	# Play a note
	noteOn: (note) ->
		now           = AudioContext.currentTime
		attackEndTime = now + @asdr.attack

		# Frequency
		#@osc.frequency.value = Harmonizer.getFreqFromNote( note )

		# Attack
		@envelope1.gain.cancelScheduledValues( now )
		@envelope1.gain.setValueAtTime( @envelope1.gain.value, now )
		@envelope1.gain.linearRampToValueAtTime( 1, attackEndTime )

		@envelope2.gain.cancelScheduledValues( now )
		@envelope2.gain.setValueAtTime( @envelope1.gain.value, now )
		@envelope2.gain.linearRampToValueAtTime( 1, attackEndTime )

		@envelope3.gain.cancelScheduledValues( now )
		@envelope3.gain.setValueAtTime( @envelope1.gain.value, now )
		@envelope3.gain.linearRampToValueAtTime( 1, attackEndTime )

		# Decay + sustain
		@envelope1.gain.setTargetAtTime( @asdr.sustain / 100, attackEndTime, (@asdr.decay / 100) + 0.001 )
		@envelope2.gain.setTargetAtTime( @asdr.sustain / 100, attackEndTime, (@asdr.decay / 100) + 0.001 )
		@envelope3.gain.setTargetAtTime( @asdr.sustain / 100, attackEndTime, (@asdr.decay / 100) + 0.001 )

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

		@envelope2.gain.cancelScheduledValues(now)
		@envelope2.gain.setValueAtTime( @envelope2.gain.value, now )
		@envelope2.gain.linearRampToValueAtTime( 0, releaseTime )

		@envelope3.gain.cancelScheduledValues(now)
		@envelope3.gain.setValueAtTime( @envelope3.gain.value, now )
		@envelope3.gain.linearRampToValueAtTime( 0, releaseTime )

		#@osc.frequency.value = 0
		@noteIsOn = false
		



module.exports = MonoistEnvMulti