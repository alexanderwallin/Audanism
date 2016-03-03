###
	Conductor
###

Constants = require '../environment/Constants.coffee'
EventDispatcher = require '../event/EventDispatcher.coffee'

AudioContext = require './AudioContext.coffee'
NoisePink = require './instrument/NoisePink.coffee'
Drone = require './instrument/Drone.coffee'
TestInstrument = require './instrument/TestInstrument.coffee'
Pad = require './instrument/Pad.coffee'
PercArpeggiator = require './instrument/PercArpeggiator.coffee'

Reverb = require './fx/Reverb.coffee'

Harmonizer = require './module/Harmonizer.coffee'

class Conductor

	# Constructor
	constructor: () ->

		# Create an audio context
		if not AudioContext
			alert('Sorry, your browser does not support AudioContext, try Chrome!')

		# State
		@isMuted = false

		# Create the end audio chain
		@createEndChain()

		#
		# Instruments
		#

		# Noise
		@noise = new NoisePink( @instrumentsIn )
		@noise.setLpfFrequency( 1000 )

		# Factor drones
		@factorDrones = (new Drone( @instrumentsIn ) for i in [0..Constants.NUM_FACTORS-1])

		@compareInstr = new TestInstrument( @instrumentsIn )
		@influencePad = new Pad( @instrumentsIn )

		@arpeggiator = new PercArpeggiator( @instrumentsIn, 4, 0 )

		# Listenings
		EventDispatcher.listen 'audanism/controls/togglesound', @, @toggleMute
		EventDispatcher.listen 'audanism/iteration',            @, @updateSounds
		EventDispatcher.listen 'audanism/influence/node',       @, @handleNodeInfluence
		EventDispatcher.listen 'audanism/alter/nodes',          @, @handleNodeComparison
		EventDispatcher.listen 'audanism/performance/bad',      @, @onPermanceBad
		EventDispatcher.listen 'audanism/organism/stressmode',  @, @onStressModeChange

	createEndChain: () ->

		# Create a void oscillator to keep the end chain alive
		@void                 = AudioContext.createOscillator()
		@void.frequency.value = 440
		@voidGain             = AudioContext.createGain()
		@voidGain.gain.value  = 0.0

		# Output connection for all instruments
		@instrumentsIn            = AudioContext.createGain()
		@instrumentsIn.gain.value = 0.2

		# Master reverb
		@masterRev     = new Reverb(2, 50, 1)

		# Master compressor
		@compressor    = AudioContext.createDynamicsCompressor()
		@compressor.threshold.value = -24
		@compressor.ratio.value = 6

		# Analyser
		@analyser = AudioContext.createAnalyser()
		@analyser.fftSize = 512

		# Connect
		@void.connect( @voidGain )
		@voidGain.connect( @instrumentsIn )
		@void.start( 0 )

		@instrumentsIn.connect( @masterRev.in )
		@masterRev.out.connect( @compressor )
		@instrumentsIn.connect( @compressor )

		@compressor.connect( @analyser )
		@analyser.connect( AudioContext.destination )

	getFrequencyData: () ->
		frequencyData = new Uint8Array( @analyser.frequencyBinCount )
		@analyser.getByteFrequencyData( frequencyData )

		return frequencyData

	setOrganism: (@organism) ->

	mute: () ->
		console.log('Conductor #mute()')
		@isMuted = true

		@arpeggiator.stop()
		(drone.notesOff() for drone in @factorDrones)
		(drone.kill() for drone in @factorDrones)

	unmute: () ->
		console.log('Conductor #unmute()')
		@isMuted = false

		@arpeggiator.start()
		(drone.noteOn( drone.droneNote ) for drone in @factorDrones)

	toggleMute: () ->
		console.log 'Conductor #toggleMute'
		if @isMuted then @unmute() else @mute()
		console.log '... now muted:', @isMuted

	updateSounds: (iterationInfo) ->
		#console.log('#updateSounds', iterationInfo, iterationInfo.count % 10)

		if @isMuted
			return

		factors = @organism.getFactors()

		# Drones
		fd = 0
		for drone in @factorDrones
			note = Harmonizer.getNoteFromFreq( factors[fd].disharmony / 10 )
			if iterationInfo.count is 1 then drone.noteOn( note ) else drone.setNote( note )
			fd++

		if iterationInfo.count % 10 is not 0
			return

		# Get some history data
		disharmonyData  = @organism.getDisharmonyHistoryData(200)
		disharmonyNew   = disharmonyData[disharmonyData.length - 1][2]
		disharmonyOld   = disharmonyData[0][2]
		disharmonyRatio = disharmonyNew / disharmonyOld

		#console.log '... disharmonies', disharmonyOld, disharmonyNew
		#console.log '... ratio', disharmonyRatio
		#console.log '... ---> freq =', disharmonyRatio * 1000
		
		# Organism noise
		if @noise?
			#console.log( 'noise lpf freq', disharmonyRatio * 1000 )
			@noise.setLpfFrequency( disharmonyRatio * 1000 )

		# Arpeggiator stuff
		if iterationInfo.count % 4 is 1
			@arpeggiator.midNote += if disharmonyRatio > 1 then 1 else -1
			#console.log('arpeggiator mid note', @arpeggiator.midNote)
		if iterationInfo.count % 9 is 1 and disharmonyData.length > 1
			@arpeggiator.shuffleAmount = 0.01 * (Math.round(disharmonyNew) % 100)
			#console.log('arpeggiator shuffle amount', @arpeggiator.shuffleAmount, disharmonyNew)
		if iterationInfo.count % 10 is 1 
			#console.log('arpeggiator frequency', disharmonyRatio * 2)
			@arpeggiator.setFrequency( Math.max(6, disharmonyRatio) )


	handleNodeComparison: (comparisonData) ->
		if @isMuted
			return

		for i in [0..comparisonData.nodes.length-1]
			node   = comparisonData.nodes[i]
			freq   = 90 + Math.pow(node.getCell(comparisonData.factorType).factorValue, 1.3)
			note   = Harmonizer.getNoteFromFreq( freq )

			@compareInstr.noteOn( note )


	handleNodeInfluence: (influenceData) ->
		#return

		if @isMuted
			return
		if not @organism or not influenceData.meta
			return

		nodeId = influenceData.node.node.nodeId
		nodeFreq = 80 + (nodeId * 40)
		nodePan = nodeId / @organism.getNodes().length

		@influencePad.noteOn( Harmonizer.getNoteFromFreq( nodeFreq ) )

		# Influence action sound
		#if influenceData.meta.source is 'instagram' and influenceData.meta.current is influenceData.meta.total and @influenceActionSounds.length < 3
		#	influenceActionSound = new Audanism.Sound.Instrument.InfluenceActionSound1()
		#	influenceActionSound.hit()
		#	@influenceActionSounds.push influenceActionSound
		#	#console.log 'add influence action sound', influenceActionSound


	onStressModeChange: (inStressMode) ->
		#console.log 'Conductor #onStressModeChange', 'tell drons to go out of unison?', inStressMode
		for drone in @factorDrones
			drone.setUnison !inStressMode

	onPermanceBad: () ->
		if @isMuted
			return

		@mute()

		#console.log(' ··············· pause conductor')

		arpFreq = @arpeggiator.frequency
		@arpeggiator.setFrequency( 0.2 )

		setTimeout () =>
			#console.log(' ··············· resume conductor')
			@unmute()
			@arpeggiator.setFrequency( arpFreq )
		, 10000

module.exports = Conductor
