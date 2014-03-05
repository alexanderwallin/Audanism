###
	ASDR value wrapper
###
class ASDR

	constructor: (@attack, @decay, @sustain, @release) ->

	set: (@attack, @decay, @sustain, @release) ->

	getTimeUntilRelease: () ->
		return @attack + @decay

	getEnvelopeDuration: () ->
		return @attack + @decay + @release


window.Audanism.Audio.Module.ASDR = ASDR