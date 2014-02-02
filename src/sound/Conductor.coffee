###
	Class that takes care of all the music
###
class Conductor

	constructor: () ->
		self = @

		@muted            = true

		@organism         = null
		@audiolet         = new Audiolet()

		@noise            = new Audanism.Sound.Noise(@audiolet)
		
		@influenceSounds  = (new Audanism.Sound.Instrument.NodeInfluenceSound2(@audiolet) for i in [0..4])
		@influenceActionSounds = []

		@comparisonSounds = (new Audanism.Sound.Instrument.NodeComparisonSound1(@audiolet) for i in [0..1])
		

		# Listenings
		EventDispatcher.listen 'audanism/iteration', @, @updateSounds

		$(document).on 'audanism/influence/node', (e, influenceData) =>
			self.handleNodeInfluence.call self, e, influenceData
		$(document).on 'audanism/alternodes', (e, nodes) =>
			self.handleNodeComparison.call self, e, nodes


	setOrganism: (organism) ->
		@organism = organism

	mute: () ->
		if @noise?
			@noise.gain.gain.setValue 0
		#s.synth.gain.gain.setValue 0 for s in @nodeSounds
		@muted = true

	unmute: () ->
		if @noise?
			@noise.gain.gain.setValue 1
		#s.synth.gain.gain.setValue 1 for s in @nodeSounds
		@muted = false

	updateSounds: (iterationInfo) ->
		console.log('#updateSounds', iterationInfo)

		if iterationInfo.count % 10 is not 0
			return

		# Organism noise
		disharmonyData = @organism.getDisharmonyHistoryData(200)
		disharmonyNew = disharmonyData[disharmonyData.length - 1][2]
		disharmonyOld = disharmonyData[0][2]
		disharmonyRatio = disharmonyNew / disharmonyOld

		#console.log '... disharmonies', disharmonyOld, disharmonyNew
		#console.log '... ratio', disharmonyRatio
		#console.log '... ---> freq =', disharmonyRatio * 1000

		if @noise?
			@noise.lpf.frequency.setValue disharmonyRatio * 1000


	handleNodeInfluence: (e, influenceData) ->
		
		if @muted
			return

		#console.log 'perform hit on', influenceData, @organism
		console.log '   has meta:', influenceData.meta
		#console.log @nodeSounds
		#s = @nodeSounds[influenceData.node.nodeId]
		#s.hit();

		if (!@organism || !influenceData.meta)
			return

		nodeId = influenceData.node.node.nodeId
		nodeFreq = 80 + (nodeId * 40)
		nodePan = nodeId / @organism.getNodes().length

		length = 0.4 #Math.pow(influenceData.meta.current * 0.2, 3)

		#console.log '--- hit synth', influenceData.meta.current - 1, ', s =', @influenceSounds[influenceData.meta.current - 1]
		#console.log '--- values:', nodeFreq, nodePan, length

		@influenceSounds[influenceData.meta.current - 1].hit(nodeFreq, nodePan, length)
		#new Audanism.Sound.Instrument.NodeInfluenceSound2(nodeFreq, nodePan)

		# Influence action sound
		if influenceData.meta.source is 'instagram' and influenceData.meta.current is influenceData.meta.total and @influenceActionSounds.length < 3
			influenceActionSound = new Audanism.Sound.Instrument.InfluenceActionSound1()
			influenceActionSound.hit()
			@influenceActionSounds.push influenceActionSound
			console.log 'add influence action sound', influenceActionSound


	handleNodeComparison: (e, comparisonData) ->

		if @muted
			return

		#minor = new MinorScale()

		for i in [0..comparisonData.nodes.length-1]
			node   = comparisonData.nodes[i]
			freq   = 80 + Math.pow(node.getCell(comparisonData.factorType).factorValue, 1.1)
			pan    = node.nodeId / @organism.getNodes().length

			# Adjust freq to harmonic minor scale
			# ...

			#if (comparisonData.action is DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1 and i is 0) or (comparisonData.action is DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2 and i is 1)
			#	length = 0.1
			#else
			#	length = 1
			length = 0.1

			#console.log 'compnode -- val:', node.getCell(comparisonData.factorType).factorValue, ' => freq:', freq
			#console.log '         -- action:', comparisonData.action, ' => length:', length

			#setTimeout () =>
			#new Audanism.Sound.Instrument.NodeComparisonSound1 freq, length
			#, i * 500

			@comparisonSounds[i].hit(freq, pan, length)


Audanism.Sound.Conductor = Conductor