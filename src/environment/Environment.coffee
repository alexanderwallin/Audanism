###
	Environment

	The environment contains a set of organisms, a "conductor" 
	(responsible for the generative audio), handles outer influences 
	and the main loop.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
###
class Environment

	# The total number of organisms to create
	@NUM_ORGANISMS: 1

	# The time in milliseconds between each iteration
	@TIME_INTERVAL: 500

	#
	# Constructor
	#
	# Creates organisms and interpreters. Initializes the loop and
	# handles core actions in each iteration
	#
	constructor: () ->
		
		# Running state variables
		@_iterationCount = 0
		@_isRunning      = false
		@_isSingleStep   = false
		
		# Visualizer
		@visualOrganism  = new Audanism.Graphic.VisualOrganism()
		
		# Create organisms
		@_organisms      = (new Audanism.Environment.Organism for i in [1..Environment.NUM_ORGANISMS])
		EventDispatcher.trigger 'audanism/init/organism', [@_organisms[0]]

		# GUI
		@_gui = new Audanism.GUI.GUI

		# Controls
		@listenToControls()

		# Influnces
		@createInfluenceSources()
		EventDispatcher.listen 'audanism/influence', @, @influence

		# Conductor
		@initConductor()

		# Go.
		@run()
		EventDispatcher.listen 'audanism/controls/start', @, @start
		EventDispatcher.listen 'audanism/controls/pause', @, @pause
		EventDispatcher.listen 'audanism/controls/stop',  @, @stop
		EventDispatcher.listen 'audanism/controls/step',  @, @step

	#
	# Initializes the loop
	#
	run: () ->
		@_intervalId = setInterval =>
			@handleIteration()
		, Environment.TIME_INTERVAL

	#
	# Starts/resumes the loop
	#
	start: () ->
		@_isRunning = true

		# Activate sources
		sourceAdapter.activate() for sourceAdapter in @_influenceSources

	#
	# Pauses the loop
	#
	pause: () ->
		@_isRunning = false

		# Deactivate sources
		(source.deactivate() for source in @_influenceSources)

	#
	# Stops the loop
	#
	stop: () ->
		@_isRunning = false
		clearInterval @_intervalId

	#
	# Performs one step of the loop
	#
	step: () ->
		@_isSingleStep = true

	#
	# UI controls listener
	#
	listenToControls: () ->
		$(document).on 'dmstart', (e) =>
			EventDispatcher.trigger 'audanism/controls/start' #@start()
		$(document).on 'dmpause', (e) =>
			EventDispatcher.trigger 'audanism/controls/pause' #@pause()
		$(document).on 'dmstop', (e) =>
			EventDispatcher.trigger 'audanism/controls/stop' #@stop()
		$(document).on 'dmstep', (e) =>
			EventDispatcher.trigger 'audanism/controls/step' #@step()

	#
	# Handles the current iteration by listening to 
	#
	handleIteration: () ->
		@_iterationCount++
		
		# If running, trigger node comparisons for all organisms
		if @_isRunning or @_isSingleStep

			for organism in @_organisms
				
				# Do comparison!
				organism.performNodeComparison()

				# Add nodes?
				if @_iterationCount % 10 is 0
					#organism.addNumNodes 10
					EventDispatcher.trigger 'audanism/node/add', { 'numNodes':1 }

				# Trigger event
				EventDispatcher.trigger 'audanism/iteration', [{ 'count':@_iterationCount, 'organism':organism}]

				@_isSingleStep = false

	#
	# Creates influence sources
	#
	createInfluenceSources: () ->
		@_influenceSources = []

		# Add sources
		#@_influenceSources.push new RandomSourceAdapter(@)
		#@_influenceSources.push new TwitterSourceAdapter(@)
		@_influenceSources.push new Audanism.SourceAdapter.InstagramSourceAdapter(6000, 'art')
		@_influenceSources.push new Audanism.SourceAdapter.InstagramSourceAdapter(3000, 'audanism')
		@_influenceSources.push new Audanism.SourceAdapter.WheatherSourceAdapter(4000)

	#
	# Handles an influence
	#
	influence: (influenceData) ->
		return if not @_isRunning

		# Node alteration
		if influenceData.node?

			# Iterate organisms
			for organism in @_organisms

				# Get matching node
				factor = if influenceData.node.factor is 'rand' then getRandomElements organism.getFactors() else organism.getFactorOfType influenceData.node.factor
				node   = if influenceData.node.node is 'rand' then organism._getRandomNodesOfFactorType(factor.factorType, 1)[0] else organism.getNode influenceData.node.node

				# Affect node
				influenceInfo = { 'node':{ 'node':node, 'factor':factor, 'value':influenceData.node.valueModifier }, 'meta':influenceData.meta }
				EventDispatcher.trigger 'audanism/influence/node', [influenceInfo]
				node.addCellValue factor.factorType, influenceData.node.valueModifier
				EventDispatcher.trigger 'audanism/influence/node/after', [influenceInfo]

		# Factor alteration
		if influenceData.factor?

			for organism in @_organisms
				factor

				# Random factor
				if influenceData.factor.factor is 'rand'
					factorType = randomInt( 1, Audanism.Environment.Organism.NUM_FACTORS )
					factor = organism.getFactorOfType( factorType )

				if factor
					influenceInfo = { 'factor':{ 'factor':factor, 'value':influenceData.factor.valueModifier }, 'meta':influenceData.meta }
					EventDispatcher.trigger 'audanism/influence/factor', influenceInfo
					factor.addValue influenceData.factor.valueModifier
					EventDispatcher.trigger 'audanism/influence/factor/after', influenceInfo


		# Random alteration
		if influenceData.random?

			type = influenceData.random['object']
			argNum = influenceData.random.num
			argVal = influenceData.random.valueModifier

			num = 0
			valueMod = -1

			# Num objects to alter
			numType = typeof argNum
			if numType is 'integer'	then num = argNum
			else if numType is 'array' then num = Math.randomRange argNum[1], argNum[0]
			else if numType is 'string' and argNum is 'rand' 
				num = Math.randomRange(if type is 'factor' then 1 else 5)

			# Factor alteration
			if type is 'factor'
				for organism in @_organisms
					
					# Get factors
					factors = getRandomElements organism.getFactors(), num
					for factor in factors

						# The value to alter
						valType = typeof argVal
						
						if valType is 'integer' 	then valueMod = argVal
						else if valType is 'array'	then valueMod = Math.randomRange argVal[1], argVal[0]
						else if valType is 'string' and argVal is 'rand' 
							valueMod = Math.randomRange 5, -5

						# Add the value
						organism.getFactorOfType(factor.factorType).addValue valueMod

			# Node alteration
			else if type is 'node'
				for organism in @_organisms
					
					# Get factors
					nodes = getRandomElements organism.getNodes(), num
					for node in nodes

						# The value to alter
						valType = typeof argVal
						
						if valType is 'integer' 	then valueMod = argVal
						else if valType is 'array'	then valueMod = Math.randomRange argVal[1], argVal[0]
						else if valType is 'string' and argVal is 'rand' 
							valueMod = Math.randomRange 50, -50

						# Add the value
						cell = getRandomElements(node.getCells(), 1)[0]
						cell.addFactorValue valueMod

	#
	# Let there be music.
	#
	initConductor: () ->
		@conductor = new Audanism.Audio.Conductor()
		@conductor.setOrganism @_organisms[0]
		#@conductor.mute()


window.Audanism.Environment.Environment = Environment


