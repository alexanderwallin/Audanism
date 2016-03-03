
synthesizers = {
	Monoist: require '../synthesizer/Monoist.coffee'
	MonoistEnv: require '../synthesizer/MonoistEnv.coffee'
	MonoistEnvMod: require '../synthesizer/MonoistEnvMod.coffee'
	MonoistEnvModWide: require '../synthesizer/MonoistEnvModWide.coffee'
	MonoistEnvMulti: require '../synthesizer/MonoistEnvMulti.coffee'
	MonoistPerc: require '../synthesizer/MonoistPerc.coffee'
}

###
	Instrument super-class
###
class Instrument

	# Constructor
	constructor: (@instrumentsIn, @synthesizer, @autoRelease) ->
		#console.log('Instrument#constructor()', @instrumentsIn, @synthesizer, @autoRelease)

		# Default to auto-release
		@autoRelease ?= true

		# Init an empty set of voices
		@voices       = (null for i in [0..120])
		@noteTimers   = (null for i in [0..120])


	# Creates a voice
	createVoice: (note) ->
		#console.log('Instrument#createVocie()', note, @voices[note])
		#return

		if @beforeCreateVoice
			@beforeCreateVoice(note)

		if not @voices[note]
			@voices[note] = new synthesizers[@synthesizer](note)

			if (@setupVoice)
				@setupVoice( @voices[note] )

			@voices[note].masterVol.connect( @instrumentsIn )

		return @voices[note]


	# Destroys the voice at the given note
	killVoiceAtNote: (note) ->
		#console.log('Instrument#killVoiceAtNote()', note)
		if @voices[note]
			#console.log('  --- noteOff:', note)
			#@voices[note].noteOff()

			setTimeout () =>
				#console.log('  --- KILL VOICE!', note, @voices[note])
				@voices[note] = null
			, (@voices[note].asdr.getEnvelopeDuration() * 1000) + 1


	# Hits a note
	noteOn: (note, length) ->
		#console.log('Instrument#noteOn()', note, length)

		# Stop the note-killing timer, if it's running
		if (@noteTimers[note])
			#console.log(' --- kill note timer', @noteTimers[note])
			clearTimeout( @noteTimers[note] )
			@noteTimers[note] = null

		# Create voice
		voice = @createVoice( note )

		# Trigger note
		length ?= 0
		noteLength = if @autoRelease then length else -1
		voice.noteOn( noteLength )

		# Kill note when done
		if @autoRelease
			@noteTimers[note] = setTimeout () =>
				#console.log('  --- KILL VOICE!', note, voice)
				@voices[note].stop()
				@voices[note].masterVol.disconnect( 0 )
				@voices[note] = null
				clearTimeout( @noteTimers[note] )
				@noteTimers[note] = null

				# Callback
				if (@onNoteOff)
					@onNoteOff(note)

			, (voice.asdr.getEnvelopeDuration() * 1000) + 10


		# Callbacks
		if (@onNoteOn)
			@onNoteOn(note, length)

	notesOff: () ->
		for voice in @voices
			if not voice
				continue

			note = voice.note
			voice.noteOff()

			setTimeout () =>
				#console.log('  --- KILL VOICE!', note, voice, @voices[note])
				#voice.stop()
				#voice.masterVol.disconnect( 0 )
				@voices[note] = null
				clearTimeout( @noteTimers[note] )
				@noteTimers[note] = null

				# Callback
				if (@onNoteOff)
					@onNoteOff(note)
			, voice.asdr.release + 1


module.exports = Instrument

