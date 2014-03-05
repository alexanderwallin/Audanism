###
	Reverb
###
class Reverb extends Audanism.Audio.FX.FX

	constructor: (@seconds, @decay, @wetAmount) ->
		@seconds   ?= 1
		@decay     ?= 0.5
		@wetAmount ?= 1

		# Convolver
		@impulse        = new Audanism.Audio.Module.Impulse( @seconds, @decay )
		@rev            = Audanism.Audio.audioContext.createConvolver()
		@rev.buffer     = @impulse.getBuffer()

		# Wet gain out
		@wet            = Audanism.Audio.audioContext.createGain()
		@wet.gain.value = wetAmount
		@rev.connect( @wet )

		super( @rev, @wet )


window.Audanism.Audio.FX.Reverb = Reverb