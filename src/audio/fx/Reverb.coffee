
AudioContext = require '../AudioContext.coffee'
FX = require './FX.coffee'
Impulse = require '../module/Impulse.coffee'

###
	Reverb
###
class Reverb extends FX

	constructor: (@seconds, @decay, @wetAmount) ->
		@seconds   ?= 1
		@decay     ?= 0.5
		@wetAmount ?= 1

		# Convolver
		@impulse        = new Impulse( @seconds, @decay )
		@rev            = AudioContext.createConvolver()
		@rev.buffer     = @impulse.getBuffer()

		# Wet gain out
		@wet            = AudioContext.createGain()
		@wet.gain.value = @wetAmount
		@rev.connect( @wet )

		super( @rev, @wet )


module.exports = Reverb