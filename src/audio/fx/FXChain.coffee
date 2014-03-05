###
	FX chain
###
class FXChain

	constructor: (@in, @out) ->
		@fxs  = []

		# Make sure we have an in and out provided
		if not @in?
			throw new Exception("No @in provided to FXChain.")
		if not @out?
			throw new Exception("No @out provided to FXChain.")

		# The @wet gain provides a way of balancing different chains
		# between each other
		@wet = Audanism.Audio.audioContext.createGain()
		@wet.connect( @out )

	addFx: (@fx) ->
		id = @fxs.length

		if id is 0
			@in.connect( @fx.in )
		else
			@fxs[id - 1].out.disconnect( 0 )
			@fxs[id - 1].out.connect( @fx.in )

		@fx.out.connect( @wet )
		@fxs[id] = @fx

	setWetAmount: (wetAmount) ->
		@wet.gain.value = wetAmount


window.Audanism.Audio.FX.FXChain = FXChain