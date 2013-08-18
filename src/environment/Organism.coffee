###
	Organism
###
class Organism

	# Options
	@NUM_FACTORS: 5
	@DEFAULT_NUM_NODES: 40

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

		# Create factors
		@_factors = (Factor.createFactor i, 0 for i in [1..Organism.NUM_FACTORS])

		# Create nodes
		numNodes = Organism.DEFAULT_NUM_NODES if numNodes <= 0
		@_nodes = (new Node() for i in [1..numNodes])
		console.log "Created nodes:", numNodes, @_nodes

		# Disharmony calculator
		@disharmonyCalculator = new DisharmonyCalculator @

		# Disharmony history
		@disharmonyHistory = []

		# GUI
		@_gui = new GUI

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

		console.log "#performNodeComparison, #{ DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY }"
		
		@disharmonyCalculator.debug = true

		# First, perform node comparison and alterations
		for i in [1..numComparisons]
			
			# Get two nodes to compare
			nodes = @_getRandomNodes 2

			# Trigger alteration of nodes
			comparisonMode = if @_inStressMode then DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY else DisharmonyCalculator.NODE_COMPARISON_MODE_ORGANISM_HARMONY
			@disharmonyCalculator.alterNodesInComparisonMode nodes, comparisonMode

		@disharmonyCalculator.debug = false

		# Then, update disharmony state
		@_sumDisharmony 	= @disharmonyCalculator.getSummedOrganismDisharmony @
		@_actualDisharmony 	= @disharmonyCalculator.getActualOrganismDisharmony @
		@disharmonyHistory.push [@disharmonyHistory.length, @_sumDisharmony]

		factor.disharmony = @disharmonyCalculator.getFactorDisharmonyForNodes factor, @_nodes for factor in @_factors

		# Check if it should enter or leave stress mode
		if not @_inStressMode and @_actualDisharmony < Organism.STRESS_THRESHOLD_ENTER
			@_inStressMode = true
		else if @_inStressMode and @_actualDisharmony > Organism.STRESS_THRESHOLD_LEAVE
			@_inStressMode = false

	getDisharmonyHistoryData: (numEntries = 300) ->
		#console.log "#getDisharmonyHistoryData", @disharmonyHistory
		if numEntries > 0 then @disharmonyHistory.slice -numEntries else @disharmonyHistory.slice -@disharmonyHistory.length

	#
	# Returns a given number of randomly selected nodes
	#
	_getRandomNodes: (numNodes) ->
		allNodeIndexes = [0..(@_nodes.length-1)]

		nodeIndexes = (allNodeIndexes.splice(Math.floor(Math.random() * allNodeIndexes.length), 1) for i in [1..numNodes])

		#console.log "#_getRandomNodes", allNodeIndexes, nodeIndexes
		(@_nodes[i] for i in nodeIndexes)


window.Organism = Organism
