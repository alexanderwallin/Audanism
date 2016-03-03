
AudioContext = require '../AudioContext.coffee'

###
	Impulse module
###
class Impulse

	constructor: (@seconds, @decay, @reverse) ->
		@reverse ?= false
		rate      = AudioContext.sampleRate
		length    = rate * @seconds
		@impulse  = AudioContext.createBuffer( 2, length, rate )
		impulseL  = @impulse.getChannelData( 0 )
		impulseR  = @impulse.getChannelData( 1 )
		n

		for i in [0..length-1]
			n = if @reverse then length - i else i
			impulseL[i] = (1 - Math.random() * 2) * Math.pow(1 - n / length, @decay)
			impulseR[i] = (1 - Math.random() * 2) * Math.pow(1 - n / length, @decay)


	getBuffer: () ->
		return @impulse


module.exports = Impulse