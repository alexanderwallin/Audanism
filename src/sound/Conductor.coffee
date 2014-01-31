###
	Class that takes care of all the music
###
class Conductor

	constructor: () ->
		self = @

		@organism         = null
		@audiolet         = new Audiolet()
		@noise            = new Audanism.Sound.Noise(@audiolet)
		
		@influenceSounds  = (new Audanism.Sound.Instrument.NodeInfluenceSound2(@audiolet) for i in [0..4])
		@comparisonSounds = (new Audanism.Sound.Instrument.NodeComparisonSound1(@audiolet) for i in [0..1])

		# Listenings
		$(document).on 'audanism/influence/node', (e, influenceData) =>
			self.handleNodeInfluence.call self, e, influenceData
		$(document).on 'audanism/alternodes', (e, nodes) =>
			self.handleNodeComparison.call self, e, nodes


	setOrganism: (organism) ->
		@organism = organism

	mute: () ->
		@noise.gain.gain.setValue 0
		#s.synth.gain.gain.setValue 0 for s in @nodeSounds

	unmute: () ->
		@noise.gain.gain.setValue 1
		#s.synth.gain.gain.setValue 1 for s in @nodeSounds

	updateSounds: () ->

		# Organism noise
		disharmonyData = @organism.getDisharmonyHistoryData(200)
		disharmonyNew = disharmonyData[disharmonyData.length - 1][2]
		disharmonyOld = disharmonyData[0][2]
		disharmonyRatio = disharmonyNew / disharmonyOld

		#console.log '... disharmonies', disharmonyOld, disharmonyNew
		#console.log '... ratio', disharmonyRatio
		#console.log '... ---> freq =', disharmonyRatio * 1000

		@noise.lpf.frequency.setValue disharmonyRatio * 1000

	handleNodeInfluence: (e, influenceData) ->
		console.log 'perform hit on', influenceData, @organism
		console.log '   has meta:', influenceData.meta
		#console.log @nodeSounds
		#s = @nodeSounds[influenceData.node.nodeId]
		#s.hit();

		if (!@organism || !influenceData.meta)
			return

		nodeId = influenceData.node.node.nodeId
		nodeFreq = 80 + (nodeId * 40)
		nodePan = nodeId / @organism.getNodes().length

		length = Math.pow(influenceData.meta.current * 0.2, 3)

		console.log '--- hit synth', influenceData.meta.current - 1, ', s =', @influenceSounds[influenceData.meta.current - 1]
		console.log '--- values:', nodeFreq, nodePan, length

		@influenceSounds[influenceData.meta.current - 1].hit(nodeFreq, nodePan, length)
		#new Audanism.Sound.Instrument.NodeInfluenceSound2(nodeFreq, nodePan)

	handleNodeComparison: (e, comparisonData) ->

		#minor = new MinorScale()

		for i in [0..comparisonData.nodes.length-1]
			node   = comparisonData.nodes[i]
			freq   = 80 + Math.pow(node.getCell(comparisonData.factorType).factorValue, 1.1)

			# Adjust freq to harmonic minor scale
			# ...

			if (comparisonData.action is DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1 and i is 0) or (comparisonData.action is DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2 and i is 1)
				length = 0.1
			else
				length = 1

			console.log 'compnode -- val:', node.getCell(comparisonData.factorType).factorValue, ' => freq:', freq
			console.log '         -- action:', comparisonData.action, ' => length:', length

			#setTimeout () =>
			#new Audanism.Sound.Instrument.NodeComparisonSound1 freq, length
			#, i * 500

			@comparisonSounds[i].hit(freq, length)



Audanism.Sound.Conductor = Conductor