
AudioContext = require '../AudioContext.coffee'

###
	Monoism synth
###
class Monoista

	# Constructor
	constructor: (@note) ->

		# connection point for all voices
		@effectChain        = AudioContext.createGain()

		# convolver for a global reverb - just an example "global effect"
		@revNode            = AudioContext.createGain() # createConvolver();

		# gain for reverb
		@revGain            = AudioContext.createGain()
		@revGain.gain.value = 0.3

		# gain for reverb bypass.  Balance between this and the previous = effect mix.
		@revBypassGain      = AudioContext.createGain()

		# overall volume control node
		@volNode            = AudioContext.createGain()
		@volNode.gain.value = 0.25

		@effectChain.connect(   @revNode )
		@effectChain.connect(   @revBypassGain )
		@revNode.connect(       @revGain )
		@revGain.connect(       @volNode )
		@revBypassGain.connect( @volNode )

		# hook it up to the "speakers"
		@volNode.connect( AudioContext.destination )




		@freq = Audanism.Audio.Harmonizer.getFreqFromNote @note

		# create oscillator
		@osc = AudioContext.createOscillator()
		@osc.frequency.setValueAtTime @originalFrequency, 0

		# create the volume envelope
		@envelope = audioContext.createGain()
		@osc.connect @envelope
		@envelope.connect effectChain

		# set up the volume ADSR envelope
		@asdr        = new Audanism.Audio.ASDR 7, 15, 50, 20
		now          = AudioContext.currentTime
		envAttackEnd = now + (@asdr.attack / 10.0)

		@envelope.gain.setValueAtTime 0.0, now
		@envelope.gain.linearRampToValueAtTime 1.0, envAttackEnd 
		@envelope.gain.setTargetAtTime (@asdr.sustain/100.0), envAttackEnd, (@asdr.decay/100.0)+0.001

		@osc.start 0

	# Play a note
	noteOn: () ->

	# Stop a note
	noteOff: () ->
		now     =  AudioContext.currentTime
		release = now + (@asdr.release / 10.0)

		this.envelope.gain.cancelScheduledValues now
		this.envelope.gain.setValueAtTime this.envelope.gain.value, now  # this is necessary because of the linear ramp
		this.envelope.gain.setTargetAtTime 0.0, now, (@asdr.release / 100)

		this.osc.stop release



module.exports = Monoista