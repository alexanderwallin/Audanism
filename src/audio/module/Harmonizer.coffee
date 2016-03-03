
Utils = require '../../util/utilities.coffee'

###
	Harmonizer - utility for getting notes, scale notes, frequeceies
	and more.
###
class Harmonizer

	@SCALE_MAJOR: [0, 2, 4, 5, 7, 9, 11]
	@SCALE_MINOR: [0, 2, 3, 5, 7, 9, 10]

	@getFreqFromNote: (note, scale) ->
		scale ?= 'minor'

		note = 440 * Math.pow( 2, (note-69) / 12 )

		if scale and scale is 'minor'
			note = Math.round(note)

			closestNoteInOctave = Math.abs(note - 69) % 12
			for n in Harmonizer.SCALE_MINOR
				if note is n
					break
				note = note + 1


		if scale and scale is 'major'
			console.log()

		return note

	@getNoteFromFreq: (freq) ->
		return Math.round( Utils.logWithBase( 2, freq / 440 ) * 12 + 69 )



module.exports = Harmonizer;