###
	Interprets text in different ways
###
class TextInterpreter

	# Constructor
	constructor: () ->


	getNumCharsInGroups: (str, numGroups, normalized) ->
		chars       = str.split('')
		numChars    = 26
		counts      = (0 for i in [0..numGroups-1])
		countRatios = null
		normalized  = if normalized? then normalized else true

		# Get character counts for each group
		for char in chars
			charVal = char.toUpperCase().charCodeAt(0) - 65

			if (charVal >= numChars || charVal < 0)
				continue

			charIndex = Math.floor(charVal / (numChars / numGroups))
			#console.log('char', char, 'w/ val', charVal, '-- index', charIndex)

			counts[charIndex] = counts[charIndex] + 1

		# Normalize
		if (normalized)

			# Get total sum
			sum = 0
			(sum += i for i in counts)
			countRatios = (i / sum for i in counts)

			#console.log '...counts', counts
			#console.log '...sum', sum
			#console.log '...ratios', countRatios

			# Get biggest value
			largestVal = -1
			for val in countRatios
				if (val > largestVal)
					largestVal = val

			#console.log '...largest val', largestVal

			# Do the normalization
			for i in [0..countRatios.length-1]
				val = countRatios[i]
				#console.log '   ...normalize', val, 'to', (val / largestVal)
				countRatios[i] = val / largestVal

			#console.log '...ratios', countRatios

		return if normalized then countRatios else counts

window.Audanism.Util.TextInterpreter = TextInterpreter