
AudioContext = require '../AudioContext.coffee'
Voice = require './Voice.coffee'
ASDR = require '../module/ASDR.coffee'
Harmonizer = require '../module/Harmonizer.coffee'

###
	MonoistEnv synth - sine with an envelope
###
class MonoistPerc extends Voice

	# Constructor
	constructor: (note) ->
		#console.log('MonoistPerc', note)
		super( note )

		# Delay
		@delay               = AudioContext.createDelay()
		@delay.delayTime     = 4
		@delay.connect( @pan )

		# LPF and HPF
		@lpf                 = AudioContext.createBiquadFilter()
		@lpf.type            = 'lowpass'
		@lpf.frequency.value = 20000
		
		@hpf                 = AudioContext.createBiquadFilter()
		@hpf.type            = 'highpass'
		@hpf.frequency.value = 0

		@hpf.connect( @lpf )
		@lpf.connect( @delay )

		# Envelope
		@asdr = new ASDR( 0.01, 0, 1, 0.2 )
		@envelope = AudioContext.createGain()
		@envelope.gain.setValueAtTime( 0, 0 )
		@envelope.connect( @hpf )

		@envelopes.push( @envelope )

		# Distortion
		#@dist = AudioContext.createWaveShaper()
		#@curve = (Math.sin(i ))

		# Create, connect and start oscillator
		@osc = AudioContext.createOscillator()
		@osc.frequency.value = Harmonizer.getFreqFromNote( @note )
		@osc.connect( @envelope )
		@osc.start( 0 )

		@oscillators.push( @osc )

		# Modulation
		@mod = AudioContext.createOscillator()
		@mod.type = @getRandomOscType()
		@mod.frequency = randomInt( 10, 20 )
		@mod.start( 0 )

		@modGain = AudioContext.createGain()
		@modGain.gain.value = 20

		@mod.connect( @modGain )
		@modGain.connect( @osc.frequency )

		@mod2 = AudioContext.createOscillator()
		@mod2.type = 'sawtooth' # @getRandomOscType()
		@mod2.frequency = randomInt( 500, 1000 )
		@mod2.start( 0 )

		@modGain2 = AudioContext.createGain()
		@modGain2.gain.value = 100

		@mod2.connect( @modGain2 )
		@modGain2.connect( @osc.frequency )

	# Play a note
	noteOn: () ->
		#console.log('... wait for', @waitTime)
		now            = AudioContext.currentTime + @waitTime
		attackEndTime  = now + @asdr.attack
		decayEndTime   = attackEndTime + @asdr.decay
		releaseEndTime = attackEndTime + @asdr.release

		# Attack
		@envelope.gain.cancelScheduledValues( now )
		@envelope.gain.setValueAtTime( 0, now )
		@envelope.gain.linearRampToValueAtTime( 1, attackEndTime )
		#@envelope.gain.setTargetAtTime( 1, now, @asdr.attack / 100 )

		# Decay
		#@envelope.gain.linearRampToValueAtTime( @asdr.sustain, decayEndTime )

		# Release + stop
		#@envelope.gain.setValueAtTime( 1, attackEndTime + 0.001 )
		@envelope.gain.linearRampToValueAtTime( 0, releaseEndTime )
		#@envelope.gain.setTargetAtTime( 1, attackEndTime, @asdr.release / 100 )

		#@osc.stop( releaseEndTime + 0.01 )
		



module.exports = MonoistPerc