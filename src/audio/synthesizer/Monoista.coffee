###
	Monoism synth
###
class Monoista

	# Constructor
	constructor: (@note) ->

		# connection point for all voices
		@effectChain        = Audanism.Audio.audioContext.createGain()

		# convolver for a global reverb - just an example "global effect"
		@revNode            = Audanism.Audio.audioContext.createGain() # createConvolver();

		# gain for reverb
		@revGain            = Audanism.Audio.audioContext.createGain()
		@revGain.gain.value = 0.3

		# gain for reverb bypass.  Balance between this and the previous = effect mix.
		@revBypassGain      = Audanism.Audio.audioContext.createGain()

		# overall volume control node
		@volNode            = Audanism.Audio.audioContext.createGain()
		@volNode.gain.value = 0.25

		@effectChain.connect(   @revNode )
		@effectChain.connect(   @revBypassGain )
		@revNode.connect(       @revGain )
		@revGain.connect(       @volNode )
		@revBypassGain.connect( @volNode )

		# hook it up to the "speakers"
		@volNode.connect( Audanism.Audio.audioContext.destination )




		@freq = Audanism.Audio.Harmonizer.getFreqFromNote @note

		# create oscillator
		@osc = Audanism.Audio.audioContext.createOscillator()
		@osc.frequency.setValueAtTime @originalFrequency, 0

		# create the volume envelope
		@envelope = audioContext.createGain()
		@osc.connect @envelope
		@envelope.connect effectChain

		# set up the volume ADSR envelope
		@asdr        = new Audanism.Audio.ASDR 7, 15, 50, 20
		now          = Audanism.Audio.audioContext.currentTime
		envAttackEnd = now + (@asdr.attack / 10.0)

		@envelope.gain.setValueAtTime 0.0, now
		@envelope.gain.linearRampToValueAtTime 1.0, envAttackEnd 
		@envelope.gain.setTargetAtTime (@asdr.sustain/100.0), envAttackEnd, (@asdr.decay/100.0)+0.001

		@osc.start 0

	# Play a note
	noteOn: () ->

	# Stop a note
	noteOff: () ->
		now     =  Audanism.Audio.audioContext.currentTime
		release = now + (@asdr.release / 10.0)

		this.envelope.gain.cancelScheduledValues now
		this.envelope.gain.setValueAtTime this.envelope.gain.value, now  # this is necessary because of the linear ramp
		this.envelope.gain.setTargetAtTime 0.0, now, (@asdr.release / 100)

		this.osc.stop release



window.Audanism.Audio.Synthesizer.Monoista = Monoista