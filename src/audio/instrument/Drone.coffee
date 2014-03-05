###
	Drone
###
class Drone extends Audanism.Audio.Instrument.Instrument

	constructor: (@instrumentsIn, @unison = true) ->
		super(@instrumentsIn, 'MonoistEnvModWide', false)

		@autoPans = (null for i in [0..@voices.length-1])
		@vibrates = (null for i in [0..@voices.length-1])

		@droneNote = 0

	setNote: (note) ->
		@droneNote = note

		for voice in @voices
			if voice
				for osc in voice.oscillators
					osc.frequency.value = Audanism.Audio.Module.Harmonizer.getFreqFromNote( note )

				voice.setUnison( @unison )

	setUnison: (@unison) ->
		#console.log 'Drone #setUnison', @unison
		for voice in @voices
			if voice
				voice.setUnison @unison

	onNoteOn: (note) ->
		#console.log('Drone#onNoteOn', note)
		#console.trace()
		#return

		###
		# Auto-pan
		autoPan = {
			note: note
			frame: 0
			interval: null
			speed: 0.01 + Math.random() * 0.7
		}

		autoPan.interval = setInterval () =>
			autoPan.frame++

			xDeg = autoPan.frame + 90
			zDeg = xDeg + 90
			if zDeg > 90
				zDeg = 180 - zDeg

			x = Math.sin(autoPan.speed * xDeg * Math.PI / 10)
			z = Math.sin(autoPan.speed * zDeg * Math.PI / 10)

			console.log(x, z)
			@voices[note].pan.setPosition( x, 0, z )
		, 100

		@autoPans[note] = autoPan
		###

		@setUnison @unison

		# Vibrate
		vibrate = {
			note: note
			frame: -1
			interval: null
			speed: 0.1 + Math.random() * 1.3
			maxGain: @voices[note].masterVol.gain.value
		}

		# Start at 0
		@voices[note].masterVol.gain.value = 0

		vibrate.interval = setInterval () =>

			try
				vibrate.frame++
				dVol = (1 + Math.sin((vibrate.speed / 2) * (vibrate.frame / 10) - Math.PI / 2)) / 2
				@voices[note].masterVol.gain.value = vibrate.maxGain * dVol
				#console.log(dVol)

				###
				if (dVol <= 0.01)
					@voices[note].noteOff()
					setTimeout
				###

			catch e
		, 100

		@vibrates[note] = vibrate


	onNoteOff: (note) ->
		if @autoPans[note]
			clearInterval( @autoPans[note].interval )
			@autoPans[note] = null

		if @vibrates[note]
			clearInterval( @vibrates[note].interval )
			@vibrates[note] = null

	kill: () ->
		for vibrate in @vibrates
			if not vibrate
				continue
			
			if vibrate.interval
				clearInterval( vibrate.interval )


window.Audanism.Audio.Instrument.Drone = Drone
