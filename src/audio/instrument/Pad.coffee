###
	Pad
###
class Pad extends Audanism.Audio.Instrument.Instrument

	constructor: (@instrumentsIn) ->
		super( @instrumentsIn, 'MonoistEnvMod' )

	setupVoice: (voice) ->

		###
		# Actually, all this doesn't work, but at least 
		# we get a spread effect
		relNote = voice.note / 120

		xRad = (2 * relNote - 1) * (Math.PI / 2)
		zRad = xRad + Math.PI / 2
		zRad = Math.PI - zRad if zRad > Math.PI / 2

		x = Math.sin(xRad)
		z = Math.sin(zRad)

		#voice.pan.setPosition( x, 0, z )
		###

		voice.pan.setPosition( 1 - Math.random() * 2, 0, 1 - Math.random() * 2 )

	playChord: (baseNote) ->
		notes = [
			baseNote - 12
			baseNote
			baseNote + 7 # Fifth
			baseNote + 10 # Seventh
			baseNote + 15 # Minor
		]

		for note in notes
			@noteOn( note )


window.Audanism.Audio.Instrument.Pad = Pad