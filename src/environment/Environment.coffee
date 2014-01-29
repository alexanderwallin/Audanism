###
	Environment
###
class Environment

	# The total number of organisms to create
	@NUM_ORGANISMS: 1

	# The time in milliseconds between each iteration
	@TIME_INTERVAL: 100

	# Constructor
	#
	# Creates organisms and interpreters. Initializes the loop and
	# handles core actions in each iteration
	constructor: () ->
		
		@_iterationCount = 0
		@_isRunning = false
		@_isSingleStep = true

		@_organisms = (new Organism for i in [1..Environment.NUM_ORGANISMS])

		@_gui = new GUI

		for organism in @_organisms
			@_gui.update organism.getFactors(), organism.getNodes(), organism.getDisharmonyHistoryData 200

		@listenToControls()

		@createInfluenceSources()

		@run()

	# Initializes the loop
	run: () ->
		@_intervalId = setInterval =>
			@handleIteration()
		, Environment.TIME_INTERVAL

		@handleIteration()

	# Starts/resumes the loop
	start: () ->
		@_isRunning = true

	# Pauses the loop
	pause: () ->
		@_isRunning = false

	# Stops the loop
	stop: () ->
		@_isRunning = false
		clearInterval @_intervalId

	# Performs one step of the loop
	step: () ->
		@_isSingleStep = true

	listenToControls: () ->
		$(document).on 'dmstart', (e) =>
			@start()
		$(document).on 'dmpause', (e) =>
			@pause()
		$(document).on 'dmstop', (e) =>
			@stop()
		$(document).on 'dmstep', (e) =>
			@step()

	# Handles the current iteration by listening to 
	handleIteration: () ->
		@_iterationCount++
		# console.log "#handleIteration #{ @_iterationCount }, running: #{ @_isRunning }, step: #{ @_isSingleStep }"

		# If running, trigger node comparisons for all organisms
		if @_isRunning or @_isSingleStep
			for organism in @_organisms
				
				# Do comparison!
				organism.performNodeComparison() 

				# Update GUI
				@_gui.update organism.getFactors(), organism.getNodes(), organism.getDisharmonyHistoryData 200

				@_isSingleStep = false

	#
	createInfluenceSources: () ->
		@_influenceSources = []

		# Add sources
		#@_influenceSources.push new RandomSourceAdapter(@)
		#@_influenceSources.push new TwitterSourceAdapter(@)
		@_influenceSources.push new InstagramSourceAdapter(@)

		# Activate sources
		sourceAdapter.activate() for sourceAdapter in @_influenceSources

	#
	influence: (influenceData) ->
		return if not @_isRunning

		console.log "---"
		console.log "#influence", influenceData


		# Node alteration
		if influenceData.node?

			# Iterate organisms
			for organism in @_organisms

				console.log '-- organism factors', organism.getFactors()

				# Get matching node
				factor = if influenceData.node.factor is 'rand' then getRandomElements organism.getFactors() else organism.getFactorOfType influenceData.node.factor
				node = if influenceData.node.node is 'rand' then organism._getRandomNodesOfFactorType(factor.factorType, 1)[0] else organism.getNode influenceData.node.node

				console.log '-- factor', factor
				console.log '-- node', node

				# Affect node
				console.log('--> node:', node.nodeId, ', factor:', factor.factorType, ', value:', influenceData.node.valueModifier)
				node.addCellValue factor.factorType, influenceData.node.valueModifier
				
				$node = $("[data-node-id='#{ node.nodeId }']").addClass('altered')
				setTimeout () =>
					$node.removeClass('altered')
				, 2000


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

			# Apply alteration
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

						console.log "    --> influence: factor #{ factor.factorType } by #{ valueMod }"
						console.log "        ... before: #{ factor }"
						organism.getFactorOfType(factor.factorType).addValue valueMod
						console.log "        ... after: #{ factor }"

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

						cell = getRandomElements(node.getCells(), 1)[0]

						console.log "    --> influence: node #{ node.nodeId }->#{ cell.factorType } by #{ valueMod }"
						console.log "        ... before: #{ node }"
						cell.addFactorValue valueMod
						console.log "        ... after: #{ node }"

		console.log "---"


window.Environment = Environment

# Initialize environment
$(window).ready =>
	environment = new Environment
	window.environment = environment
