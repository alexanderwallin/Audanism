###
	Voice

	Voice is a super-class for synthesizers. It is only alive during its 
	note's duration.

	It has one dry channel and one wet, containing FXChains. FXChains
	can be added dynamically.
###
class Voice

	# Constructor
	constructor: (@note, @fxIn, @masterWet) ->

		@oscillators = []
		@envelopes   = []

		# The time to wait before playing a note (shuffle)
		@waitTime = 0

		###
		Note: Effects on voices are currently forbidden. Only the master
		end chain will have reverbs and stuff.

		Effects stuff are commented out.
		###

		# Create empty chains and effects lists
		#@fxChains   = []
		#@fxs        = []

		# Create fx in and out (master wet) if not provided
		#@fxIn      ?= Audanism.Audio.audioContext.createGain()
		#@masterWet ?= Audanism.Audio.audioContext.createGain()

		# Create pre- and post-fx panners
		#@panPreFx   = Audanism.Audio.audioContext.createPanner()
		#@panPostFx  = Audanism.Audio.audioContext.createPanner()
		@pan        = Audanism.Audio.audioContext.createPanner()

		# Create a dry controller
		#@dry        = Audanism.Audio.audioContext.createGain()

		# Create a master compressor
		#@masterComp = Audanism.Audio.audioContext.createDynamicsCompressor()

		# Create a master out volume controller
		@masterVol  = Audanism.Audio.audioContext.createGain()
		@masterVol.gain.value = 0.0005


		###
		Connect stuff together
		###

		# Pre-fx
		#@panPreFx.connect( @fxIn )
		#@panPreFx.connect( @dry )

		# Post-fx
		#@dry.connect( @panPostFx )
		#@masterWet.connect( @panPostFx )
		#@panPostFx.connect( @masterComp )
		#@masterComp.connect( @masterVol )

		@pan.connect( @masterVol )
		
		#@masterVol.connect( Audanism.Audio.audioContext.destination )


	noteOn: (length) ->
		#console.log('#noteOn()', @note, @envelopes, @oscillators)
		extraLength = if length > @asdr.attack + @asdr.decay then length - @asdr.attack - @asdr.decay else 0

		now              = Audanism.Audio.audioContext.currentTime + @waitTime
		attackEndTime    = now + @asdr.attack
		decayEndTime     = attackEndTime + @asdr.decay
		releaseStartTime = if length >= 0 then decayEndTime + extraLength else 0
		releaseEndTime   = releaseStartTime + @asdr.release


		# Iterate evelopes
		for i in [0..@envelopes.length-1]
			env = @envelopes[i]

			# Attack
			env.gain.cancelScheduledValues( now )
			env.gain.setValueAtTime( env.gain.value, now )
			env.gain.linearRampToValueAtTime( 1, attackEndTime )
			#env.gain.exponentialRampToValueAtTime( 1, attackEndTime )
			#env.gain.setTargetAtTime( 1, now, attackEndTime )

			# Decay + sustain + extra length
			env.gain.linearRampToValueAtTime( @asdr.sustain, decayEndTime )
			#env.gain.exponentialRampToValueAtTime( @asdr.sustain, decayEndTime )
			#env.gain.setTargetAtTime( @asdr.sustain, attackEndTime, decayEndTime )

			if extraLength > 0
				env.gain.linearRampToValueAtTime( @asdr.sustain, releaseStartTime )

			# Release
			if length >= 0
				env.gain.linearRampToValueAtTime( 0, releaseEndTime )
			#env.gain.setTargetAtTime( 0, decayEndTime, releaseEndTime )


	# Triggers the envelope to end
	noteOff: () ->
		now            = Audanism.Audio.audioContext.currentTime
		releaseEndTime = now + @asdr.release

		for i in [0..@envelopes.length-1]
			env = @envelopes[i]
			env.gain.cancelScheduledValues( now )
			env.gain.setValueAtTime( env.gain.value, now )
			env.gain.linearRampToValueAtTime( 0, releaseEndTime )

			try
				@oscillators[i].stop( releaseEndTime + 0.01 )
			catch e



	# Stops all oscillators
	stop: (wait) ->
		wait ?= 0

		# Stop oscillators when reaching the envelopes end
		for osc in @oscillators
			osc.stop( wait )



	###
	# Creates and returns an fx chain
	createFxChain: () ->

		id = @fxChains.length
		console.log('Voice#createFxChain()')
		console.log('...id', id)

		chain = new Audanism.Audio.FX.FXChain( @fxIn, @masterWet )

		#@fxIn.connect( chain.in )
		#chain.out.connect( @masterWet )

		@fxChains[@fxChains.length] = chain
		return chain


	# Adds an effect to the main signal chain
	# @masterWet -> @fx -> @panPostFx
	addFx: (@fx) ->
		id = @fxs.length

		if id is 0
			@masterWet.disconnect( 0 )
			@masterWet.connect( @fx.in )
		else
			@fxs[id - 1].out.disconnect( 0 )
			@fxs[id - 1].out.connect( @fx.in )
		
		@fx.out.connect( @panPostFx )
		@fxs[id] = @fx

	# Pan pre fx
	setPanPreFx: (pan) ->
		@panPreFx.setPosition( pan, 0, 0 )


	# Pan post fx
	setPanPostFx: (pan) ->
		@panPostFx.setPosition( pan, 0, 0 )


	# Dry amount
	setDryAmunt: (dryAmount) ->
		@dry.gain.value = dryAmount


	# Wet (fx) amount
	setMasterWetAmount: (wetAmount) ->
		@masterWet.gain.value = wetAmount
	###

	# Sets pan
	setPan: (pan) ->
		@pan.setPosition( pan, 0, 0 )


	getRandomOscType: () ->
		oscTypes = ['sine', 'sawtooth', 'square', 'triangle']
		return oscTypes[randomInt( 0, 3 )]


window.Audanism.Audio.Synthesizer.Voice = Voice