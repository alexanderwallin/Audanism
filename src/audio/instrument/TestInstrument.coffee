###
	Test instrument
###
class TestInstrument extends Audanism.Audio.Instrument.Instrument

	constructor: (@instrumentsIn) ->
		super( @instrumentsIn, 'MonoistEnv', true )

	setupVoice: (voice) ->
		voice.masterVol.gain.value = 0.1
		voice.pan.setPosition( 1 - Math.random() * 2, 0, 1 - Math.random() * 2 )


window.Audanism.Audio.Instrument.TestInstrument = TestInstrument