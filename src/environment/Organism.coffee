###
	Organism

	An organism object contains sets of nodes and factors. It has a stress 
	mode, which is used to determine ways of calculating its disharmony.
	The threshold for when to enter or leave stress mode is self-adjusting 
	over time, meaning it will normalize to the current disharmony state 
	every once in a while.

	It also provides methods for getting historical disharmony data regarding
	its nodes and factors.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
###
class Organism

	# Options
	@NUM_FACTORS: 5
	@DEFAULT_NUM_NODES: 10
	@DISTRIBUTE_FACTOR_VALUES: false

	# Stress thresholds - the thresholds for when the organism enters
	# and leaves stress mode
	@STRESS_THRESHOLD_ENTER: 1
	@STRESS_THRESHOLD_LEAVE: 2

	# Constructor
	constructor: (numNodes = -1) ->

		# Disharmony
		@_sumDisharmony = 0
		@_actualDisharmony = 0

		# Stress mode
		@_inStressMode = false
		@stress = {
			thresholdEnter: 0
			thresholdLeave: 0
		}

		EventDispatcher.trigger 'audanism/organism/stressmode', @_inStressMode

		@_stressAdjustmentTime     = 8000
		@_stressAdjustmentInterval = setInterval @adjustStressThresholds.bind(@), @_stressAdjustmentTime


		# Create factors
		@_factors = (Audanism.Factor.Factor.createFactor i, 0 for i in [1..Audanism.Environment.Organism.NUM_FACTORS])
		EventDispatcher.trigger 'audanism/init/factors', [@_factors]

		# Create nodes
		numNodes = Audanism.Environment.Organism.DEFAULT_NUM_NODES if numNodes <= 0
		@_createNodes numNodes
		EventDispatcher.trigger 'audanism/init/nodes', [@_nodes]
		EventDispatcher.listen 'audanism/node/add', @, (info) =>
			@_createNodes info.numNodes

		# Disharmony calculator
		@disharmonyCalculator = new Audanism.Calculator.DisharmonyCalculator @

		# Disharmony history
		@disharmonyHistory = []

	#
	# Returns the node with the given id.
	#
	getNode: (nodeId) ->
		if @_nodes[nodeId]? then @_nodes[nodeId] else null

	#
	# Returns all nodes that have a cell with the given factor type.
	#
	getNodesWithCellsOfFactorType: (factorType) ->
		@_nodeCellIndex[factorType]

	#
	# Returns the organism's nodes
	#
	getNodes: () ->
		@_nodes

	#
	# Returns the organism's factors
	#
	getFactors: () ->
		@_factors

	#
	# Returns, if found, the factor within the organism that has the given
	# factor type.
	#
	getFactorOfType: (factorType) ->
		foundFactor = null
		for factor in @_factors
			foundFactor = factor if factor.factorType is factorType
		foundFactor

	#
	# Compares and alters children nodes
	#
	performNodeComparison: (numComparisons = 1) ->

		#console.log "#performNodeComparison, #{ DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY }"
		@isInitialComparison = @_sumDisharmony is 0

		@disharmonyCalculator.debug = true

		# First, perform node comparison and alterations
		for i in [1..numComparisons]
			
			# Get two nodes to compare
			nodes = @_getRandomNodes 2

			# Trigger alteration of nodes
			comparisonMode = if @_inStressMode and false then Audanism.Calculator.DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY else Audanism.Calculator.DisharmonyCalculator.NODE_COMPARISON_MODE_ORGANISM_HARMONY

			# Notify observes
			EventDispatcher.trigger 'audanism/compare/nodes', [{ 'nodes':nodes, 'comparisonMode':comparisonMode }]

			# Perform comparison
			@disharmonyCalculator.alterNodesInComparisonMode nodes, comparisonMode

		@disharmonyCalculator.debug = false

		# Then, update disharmony state
		@_sumDisharmony 	= @disharmonyCalculator.getSummedOrganismDisharmony @
		@_actualDisharmony 	= @disharmonyCalculator.getActualOrganismDisharmony @
		@disharmonyHistory.push [@disharmonyHistory.length, @_sumDisharmony, @_actualDisharmony]

		factor.setDisharmony @disharmonyCalculator.getFactorDisharmonyForNodes factor, @_nodes for factor in @_factors

		if @isInitialComparison
			@stress.thresholdEnter = @_actualDisharmony * 1.2
			#console.log 'initial stress threshold enter': @stress.thresholdEnter

		#console.log '@_actualDisharmony', Math.round(@_actualDisharmony), Math.round(@stress.thresholdEnter), Math.round(@stress.thresholdLeave)

		# Check if it should enter or leave stress mode
		if not @_inStressMode and @_actualDisharmony > @stress.thresholdEnter
			#console.log ' -----------------------------------------'
			#console.log ' #=#=#=#=#=#==# STRESS MODE =#=#=#=#=#=#=#'
			#console.log ' -----------------------------------------'

			@_inStressMode = true
			@stress.thresholdLeave = @stress.thresholdEnter * 1
			EventDispatcher.trigger 'audanism/organism/stressmode', @_inStressMode

			# Retart stress level adjustment interval
			clearInterval @_stressAdjustmentInterval
			@_stressAdjustmentInterval = setInterval @adjustStressThresholds.bind(@), @_stressAdjustmentTime

		else if @_inStressMode and @_actualDisharmony < @stress.thresholdLeave
			#console.log ' -----------------------------------------'
			#console.log ' #=#=#=#=#=#==# LEAVE STRESS MODE =#=#=#=#=#=#=#'
			#console.log ' -----------------------------------------'

			@_inStressMode = false
			@stress.thresholdEnter = @stress.thresholdLeave * 1.2
			EventDispatcher.trigger 'audanism/organism/stressmode', @_inStressMode

			# Retart stress level adjustment interval
			clearInterval @_stressAdjustmentInterval
			@_stressAdjustmentInterval = setInterval @adjustStressThresholds.bind(@), @_stressAdjustmentTime

	#
	# Returns the disharmony history data, reduced to the
	# given number of data entries.
	#
	getDisharmonyHistoryData: (numEntries = 300) ->
		#console.log "#getDisharmonyHistoryData", @disharmonyHistory
		if numEntries > 0 then @disharmonyHistory.slice -numEntries else @disharmonyHistory.slice -@disharmonyHistory.length

	#
	# Returns a disharmony average from a given number of entries
	#
	getAverageDisharmony: (numEntries, type = 'sum') ->
		history = @getDisharmonyHistoryData numEntries

		sum = 0
		for entry in history
			sum += (if type is 'actual' then entry[2] else entry[1])

		return sum / history.length

	#
	# Returns the relative change in disharmony from some given number
	# of entries back in time.
	#
	getDisharmonyChange: (entriesBack = 2, type = 'sum') ->
		history = @getDisharmonyHistoryData entriesBack
		dataIndex = if type is 'actual' then 2 else 1
		return history[history.length - 1][dataIndex] / history[0][dataIndex]

	#
	# Returns a factor's relative change in disharmony from some given
	# number of entries back.
	#
	getDisharmonyChangeForFactor: (factorType, entriesBack = 2) ->
		factor = @getFactorOfType factorType
		history = factor.disharmonyHistory.slice( if entriesBack < factor.disharmonyHistory.length then -entriesBack else 0 )
		return history[history.length - 1] / history[0]

	#
	# Offsets the disharmony threshold depending on whether in stress mode
	#
	adjustStressThresholds: () ->
		if @_inStressMode
			@stress.thresholdLeave = @_actualDisharmony * 1
		else
			@stress.thresholdEnter = @_actualDisharmony * 1.2

		#console.log('@adjustStressThresholds', 'new thresholds:', @stress)

	#
	# Creates the organism's nodes
	#
	_createNodes: (numNodes) ->

		# Create indexes
		if not @_nodeCellIndex
			@_nodeCellIndex = []
			@_nodeCellIndex[factor.factorType] = [] for factor in @_factors

		# Create nodes array with node IDs as key
		if not @_nodes
			@_nodes = []
		nodes = (new Audanism.Node.Node() for i in [1..numNodes])
		@_nodes[node.nodeId] = node for node in nodes
		
		# Add nodes to indexes
		for node in nodes
			for cell in node.getCells()
				@_nodeCellIndex[cell.factorType].push node

		# Distribute the factor values amongst the nodes
		if Organism.DISTRIBUTE_FACTOR_VALUES
			for factor in @_factors
				nodesWithFactorCells = @getNodesWithCellsOfFactorType factor.factorType
				getRandomElements(nodesWithFactorCells, 1)[0].addCellValue(factor.factorType, 1) for i in [1..factor.factorValue]
		else
			for node in nodes
				for cell in node.getCells()
					cell.factorValue = Math.randomRange 0, 100

	#
	# Returns a given number of randomly selected nodes
	#
	_getRandomNodes: (numNodes) ->
		allNodeIndexes = [0..(@_nodes.length-1)]

		nodeIndexes = (allNodeIndexes.splice(Math.floor(Math.random() * allNodeIndexes.length), 1) for i in [1..numNodes])

		#console.log "#_getRandomNodes", allNodeIndexes, nodeIndexes
		(@_nodes[i] for i in nodeIndexes)

	#
	# Returns the given number of nodes that has a cell with
	# the given factor type.
	#
	_getRandomNodesOfFactorType: (factorType, numNodes) ->
		#console.log '#_getRandomNodesOfFactorType', factorType, numNodes, @_nodeCellIndex
		getRandomElements(@_nodeCellIndex[factorType], numNodes)



window.Audanism.Environment.Organism = Organism
