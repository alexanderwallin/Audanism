###
	Class that takes care of all the music
###
class Conductor

	constructor: () ->
		@organism = null

		@audiolet = new Audiolet()

		@noise = new Audanism.Sound.Noise(@audiolet)

		@nodeSounds = []

	setOrganism: (organism) ->
		@organism = organism

		#for node in @organism.getNodes()
		#	@nodeSounds[node.nodeId] = new Audanism.Sound.Synth(@audiolet, 400 + Math.random() * 1000)

	mute: () ->
		@noise.gain.gain.setValue 0

	unmute: () ->
		@noise.gain.gain.setValue 1

	updateSounds: () ->

		# Organism noise
		disharmonyData = @organism.getDisharmonyHistoryData(200)
		disharmonyNew = disharmonyData[disharmonyData.length - 1][2]
		disharmonyOld = disharmonyData[0][2]
		disharmonyRatio = disharmonyNew / disharmonyOld

		console.log '... disharmonies', disharmonyOld, disharmonyNew
		console.log '... ratio', disharmonyRatio
		console.log '... ---> freq =', disharmonyRatio * 1000

		@noise.lpf.frequency.setValue disharmonyRatio * 1000


Audanism.Sound.Conductor = Conductor