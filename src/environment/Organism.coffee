###
	Organism
###
class Organism

	# Options
	@NUM_FACTORS: 5
	@DEFAULT_NUM_NODES: 44
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
		@_inStressMode = true
		$('#stressmode').change (e) =>
			@_inStressMode = $(e.currentTarget).attr('checked') is 'checked'

		# Create factors
		@_factors = (Factor.createFactor i, 0 for i in [1..Organism.NUM_FACTORS])

		# Create nodes
		numNodes = Organism.DEFAULT_NUM_NODES if numNodes <= 0
		@_createNodes numNodes

		# Disharmony calculator
		@disharmonyCalculator = new DisharmonyCalculator @

		# Disharmony history
		@disharmonyHistory = []

		# GUI
		@_gui = new GUI

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
		
		@disharmonyCalculator.debug = true

		# First, perform node comparison and alterations
		for i in [1..numComparisons]
			
			# Get two nodes to compare
			nodes = @_getRandomNodes 2

			# Trigger alteration of nodes
			comparisonMode = if @_inStressMode and false then DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY else DisharmonyCalculator.NODE_COMPARISON_MODE_ORGANISM_HARMONY
			@disharmonyCalculator.alterNodesInComparisonMode nodes, comparisonMode

		@disharmonyCalculator.debug = false

		# Then, update disharmony state
		@_sumDisharmony 	= @disharmonyCalculator.getSummedOrganismDisharmony @
		@_actualDisharmony 	= @disharmonyCalculator.getActualOrganismDisharmony @
		@disharmonyHistory.push [@disharmonyHistory.length, @_sumDisharmony, @_actualDisharmony]

		factor.disharmony = @disharmonyCalculator.getFactorDisharmonyForNodes factor, @_nodes for factor in @_factors

		# Check if it should enter or leave stress mode
		if not @_inStressMode and @_actualDisharmony < Organism.STRESS_THRESHOLD_ENTER
			@_inStressMode = true
		else if @_inStressMode and @_actualDisharmony > Organism.STRESS_THRESHOLD_LEAVE
			@_inStressMode = false

	# Returns the disharmony history data, reduced to the
	# given number of data entries.
	getDisharmonyHistoryData: (numEntries = 300) ->
		#console.log "#getDisharmonyHistoryData", @disharmonyHistory
		if numEntries > 0 then @disharmonyHistory.slice -numEntries else @disharmonyHistory.slice -@disharmonyHistory.length

	# Creates the organism's nodes
	_createNodes: (numNodes) ->

		# Create indexes
		@_nodeCellIndex = []
		@_nodeCellIndex[factor.factorType] = [] for factor in @_factors

		# Create nodes array with node IDs as key
		nodes = (new Node() for i in [1..numNodes])
		@_nodes = []
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



window.Organism = Organism
