###
	DisharmonyCalculator
###
class DisharmonyCalculator

	# Comparison modes
	@NODE_COMPARISON_MODE_UNKNOWN: 0
	@NODE_COMPARISON_MODE_FACTOR_HARMONY: 1
	@NODE_COMPARISON_MODE_ORGANISM_HARMONY: 2

	# Node actions
	@NODE_ACTION_MOVE_VALUE_NONE: 3
	@NODE_ACTION_MOVE_VALUE_1: 4
	@NODE_ACTION_MOVE_VALUE_2: 5
	@NODE_ACTION_SAVE_VALUE_1: 6
	@NODE_ACTION_SAVE_VALUE_2: 7
	@NODE_ACTION_SAVE_BOTH: 8

	# Constructor
	constructor: (@_organism, @debug = false) ->

	###
		Organism disharmony
	###

	# Returns the sum of factor disharmony within the organism
	getSummedOrganismDisharmony: () ->
		console.log "#getSummedOrganismDisharmony"
		sumDisharmony = 0
		sumDisharmony += @getFactorDisharmonyForNodes factor, @_organism.getNodes() for factor in @_organism.getFactors()
		avgDisharmony = sumDisharmony / @_organism.getNodes().length
		sumDisharmony

	# Returns the sum of factor disharmony within the organism,
	# adjusted with the disharmony existing between the factors
	# themselves.
	getActualOrganismDisharmony: () ->
		disharmonies = []
		disharmonies[factor.factorType] = @getFactorDisharmonyForNodes factor, @_organism.getNodes() for factor in @_organism.getFactors()
		console.log "#getActualOrganismDisharmony"
		console.log "      ... before:", disharmonies

		# Adjust disharmonies according to correlations
		correlations = Factor.FACTOR_CORRELATIONS
		#correlationsArray[factor.factorType] = Factor.FACTOR_CORRELATIONS[factor.factorType] for factor in @_organism.getFactors()
		#for factorCorrelations, factorType in correlationsArray
		#	console.log "  #{ factorType }: #{ factorCorrelations }"
		#	for correlatingFactorType in factorCorrelations
		#		console.log "--- adjust for correlation #{ factorType } <---> #{ correlatingFactorType }"

		for factorType in [1..Organism.NUM_FACTORS]
			for correlatingFactorType in [1..Organism.NUM_FACTORS]
				if correlations[factorType]? and correlations[factorType][correlatingFactorType]?
					correlationValue = correlations[factorType][correlatingFactorType]

					console.log "--- adjust for correlation #{ factorType } <---> #{ correlatingFactorType } (#{ correlationValue })"

					# We use subtractions, since a positive correlation means less disharmony
					disharmonyDiff = Math.abs(disharmonies[factorType] - disharmonies[correlatingFactorType])
					disharmonies[factorType] += Math.pow(disharmonyDiff, 2.2) * (100 - correlationValue) / (100 * disharmonyDiff)

		console.log "      ... after:", disharmonies

		actualDisharmony = disharmonies.reduce (a, b) -> a + b
		console.log "  actualDisharmony =", actualDisharmony
		actualDisharmony

	###
		Factor-node disharmony
	###

	# Returns the sum of disharmony existing between a given factor
	# and a set of nodes with cells affecting that factor.
	getFactorDisharmonyForNodes: (factor, nodes) ->
		#console.log "#getFactorDisharmonyForNodes", factor.factorType, nodes if @debug

		disharmony = 0
		for node in nodes
			#console.log "  -- check against node #{ node.nodeId }" if @debug
			disharmony += @getFactorDisharmonyForNode factor, node if node.hasCellOfFactorType factor.factorType
		disharmony

	# Returns the disharmony between a given factor and a given node.
	getFactorDisharmonyForNode: (factor, node) ->
		#console.log "            #getFactorDisharmonyForNode (#{ factor.factorType }, #{ node.nodeId })" if @debug
		disharmony = 0

		cell = node.getCell factor.factorType
		return if not cell

		if 0 <= cell.factorValue <= factor.factorValue
			disharmony = @_calcFactorDisharmonyForNode_lteF cell.factorValue, factor.factorValue
		else
			disharmony = @_calcFactorDisharmonyForNode_gtF cell.factorValue, factor.factorValue

		#console.log "           disharmony for #{ node.nodeId } in [#{ factor.factorType }]:", disharmony if @debug
		disharmony
		


	# Returns an array of associative relative disharmonies
	# between the given factors.
	getRelativeDisharmonyForFactors: (factors) ->


	###
		Node comparison
	###

	# Compares the given nodes using the given comparison mode,
	# and then alters them striving for reduced disharmony.
	alterNodesInComparisonMode: (nodes, comparisonMode) ->
		console.log "DisharmonyCalculator.alterNodesInComparisonMode --- mode: #{ comparisonMode }, nodes:", nodes

		comparisonFn = if comparisonMode is DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY then 'getFactorDisharmonyForNodes' else 'getActualOrganismDisharmony'
		console.log "   comparisonFn = #{ comparisonFn }"

		#if comparisonMode is DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY
		#	 @_alterNodesUsingFactorHarmonyComparison nodes 
		#else if comparisonMode is DisharmonyCalculator.NODE_COMPARISON_MODE_ORGANISM_HARMONY
		#	@_alterNodesUsingOrganismHarmonyComparison nodes

		$(".node.comparing").removeClass('comparing')
		for node in nodes
			$(".node[data-node-id=#{ node.nodeId }]").addClass('comparing')

		# Check which cells should be subjects for alteration
		cellsToCompare = []
		for aCell in nodes[0].getCells()
			for bCell in nodes[1].getCells()
				# console.log "        aCell.type =", aCell.factorType, "bCell.type = ", bCell.factorType, "==> ", aCell.factorType is bCell.factorType
				if aCell.factorType is bCell.factorType
					cellsToCompare.push aCell.factorType

		#console.log "   ...cells to compare: ", cellsToCompare

		for factorType in cellsToCompare
			#console.log "      alter factor #{ factorType } for cells in #{ nodes[0].nodeId } and #{ nodes[1].nodeId } --- #{ @debug }"

			# Make a copy of the nodes
			testNodes = nodes #(node.clone() for node in nodes)
			Node._idCounter-- for node in nodes
			console.log testNodes
			#continue

			nodeAction
			neededSaveNode = false

			# If any cell has a value of 0 or 100, force actions evening out
			# those cells
			for node in nodes
				cell = node.getCell factorType
				if cell.factorValue is 0
					node.addCellValue factorType, 1
					neededSaveNode = true
				if cell.factorValue is 100
					node.addCellValue factorType, -1
					neededSaveNode = true
				if neededSaveNode
					console.log " >>> ABRUPT: Needed to save nodes <<<"
					return

			# Start by storing the current disharmony
			factor = @_organism.getFactorOfType factorType
			currentDisharmony = @[comparisonFn](factor, testNodes)

			# Action #1
			testNodes[0].addCellValue factorType, -1
			testNodes[1].addCellValue factorType, 1
			newDisharmony1 = @[comparisonFn](factor, testNodes)

			# Action #1
			testNodes[0].addCellValue factorType, 2
			testNodes[1].addCellValue factorType, -2
			newDisharmony2 = @[comparisonFn](factor, testNodes)

			# Reset
			testNodes[0].addCellValue factorType, -1
			testNodes[1].addCellValue factorType, 1

			smallestNewDisharmony = if newDisharmony1 < newDisharmony2 then newDisharmony1 else newDisharmony2
			nodeAction = if newDisharmony1 < newDisharmony2 then DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1 else DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2

			#console.log "         disharmony for step // 0:#{ currentDisharmony }, 1:#{ newDisharmony1 }, 2:#{ newDisharmony2 }"
			#console.log "             node action: #{ nodeAction }"
			#if currentDisharmony > smallestNewDisharmony
			@_performAction nodes, factorType, nodeAction

		return true

	# Perform a given alteration action on two nodes
	_performAction: (nodes, factorType, action) ->
		#console.log "#_performAction #{ action } on factor #{ factorType }", nodes
		#console.log "   before: #{ nodes[0].getString() }   #{ nodes[1].getString() }"
		switch action
			when DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1
				nodes[0].addCellValue factorType, -1
				nodes[1].addCellValue factorType, 1
			when DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2
				nodes[0].addCellValue factorType, 1
				nodes[1].addCellValue factorType, -1
		#console.log "   after: #{ nodes[0].getString() }   #{ nodes[1].getString() }"


	_calcFactorDisharmonyForNode_lteF: (c, F) ->
		result = -(Math.pow c, 2)/(Math.pow F, 2) + 1
		result = Math.pow result, 6
		result = Math.pow (result + 1), 10
		#console.log "     _lteF (#{ c }, #{ F }) = #{ result }" if @debug
		result

	_calcFactorDisharmonyForNode_gtF: (c, F) ->
		result = -((c-F)*(c-200+F)) / Math.pow (100-F), 2
		result = Math.pow result, 6
		result = Math.pow (result + 1), 10
		#console.log "     _gtF (#{ c }, #{ F }) = #{ result }" if @debug
		result


window.DisharmonyCalculator = DisharmonyCalculator