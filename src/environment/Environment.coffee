###
	Environment
###
class Environment

	# The total number of organisms to create
	@NUM_ORGANISMS: 1

	# The time in milliseconds between each iteration
	@TIME_INTERVAL: 500

	# Constructor
	#
	# Creates organisms and interpreters. Initializes the loop and
	# handles core actions in each iteration
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

	# Initializes the loop
	run: () ->
		#@start()

		@_intervalId = setInterval =>
			@handleIteration()
		, Environment.TIME_INTERVAL

		#@handleIteration()

	# Starts/resumes the loop
	start: () ->
		@_isRunning = true

		# Activate sources
		sourceAdapter.activate() for sourceAdapter in @_influenceSources

	# Pauses the loop
	pause: () ->
		@_isRunning = false

		# Deactivate sources
		(source.deactivate() for source in @_influenceSources)

	# Stops the loop
	stop: () ->
		@_isRunning = false
		clearInterval @_intervalId

	# Performs one step of the loop
	step: () ->
		@_isSingleStep = true

	listenToControls: () ->
		$(document).on 'dmstart', (e) =>
			EventDispatcher.trigger 'audanism/controls/start' #@start()
		$(document).on 'dmpause', (e) =>
			EventDispatcher.trigger 'audanism/controls/pause' #@pause()
		$(document).on 'dmstop', (e) =>
			EventDispatcher.trigger 'audanism/controls/stop' #@stop()
		$(document).on 'dmstep', (e) =>
			EventDispatcher.trigger 'audanism/controls/step' #@step()

	# Handles the current iteration by listening to 
	handleIteration: () ->
		@_iterationCount++
		# console.log "#handleIteration #{ @_iterationCount }, running: #{ @_isRunning }, step: #{ @_isSingleStep }"

		# If running, trigger node comparisons for all organisms
		if @_isRunning or @_isSingleStep

			if @conductor? and @conductor.isMuted
				@conductor.unmute()

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
		else

			if @conductor? and not @conductor.isMuted
				@conductor.mute()

	#
	createInfluenceSources: () ->
		@_influenceSources = []

		# Add sources
		#@_influenceSources.push new RandomSourceAdapter(@)
		#@_influenceSources.push new TwitterSourceAdapter(@)
		@_influenceSources.push new Audanism.SourceAdapter.InstagramSourceAdapter(@)
		@_influenceSources.push new Audanism.SourceAdapter.WheatherSourceAdapter()


	#
	influence: (influenceData) ->
		return if not @_isRunning

		#console.log "---"
		#console.log "#influence", influenceData


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
					
					#console.log('——— changed factor', factor, 'by value', influenceData.factor.valueModifier)


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

						#console.log "    --> influence: factor #{ factor.factorType } by #{ valueMod }"
						#console.log "        ... before: #{ factor }"
						organism.getFactorOfType(factor.factorType).addValue valueMod
						#console.log "        ... after: #{ factor }"

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

						#console.log "    --> influence: node #{ node.nodeId }->#{ cell.factorType } by #{ valueMod }"
						#console.log "        ... before: #{ node }"
						cell.addFactorValue valueMod
						#console.log "        ... after: #{ node }"

		#console.log "---"


	initConductor: () ->
		@conductor = new Audanism.Audio.Conductor()

		@conductor.setOrganism @_organisms[0]
		@conductor.mute()

		###
		$spectrum = $('<div id="spectrum" />').css({
			'position': 'fixed'
			'left': 0
			'right': 0
			'top': 0
			'bottom': 0
			'z-index': 9999
			#'height': window.innerHeight
		}).appendTo($('#container'))

		for i in [0..@conductor.analyser.frequencyBinCount-1]
			dLeft = i / @conductor.analyser.frequencyBinCount
			dWidth = Math.round( $(window).width() / @conductor.analyser.frequencyBinCount )

			$spectrum.append($('<div />').attr('id', 'bar-' + i).css({
				'position': 'absolute', 
				'top': 0, 
				'left': i * dWidth + 1
				'width': dWidth - 2
				'height': 10
				'background-color': 'red'
			}))

		EventDispatcher.listen 'audanism/iteration', @, (frame) =>
			console.log('adjust freq bars')
			frequencyData = @conductor.getFrequencyData()
			#console.log(frequencyData.join(' | '))

			i = -1

			for freqData in frequencyData
				i++
				console.log(freqData)

				if i is 0
					console.log( $('#bar-' + i) )

				$('#bar-' + i).css('height', 10 + Math.round(freqData))
		###


window.Audanism.Environment.Environment = Environment


