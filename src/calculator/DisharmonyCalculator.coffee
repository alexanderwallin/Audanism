###
	DisharmonyCalculator

	The disharmony calculator 

	@author Alexander Wallin
	@url    http://alexanderwallin.com
###

Constants = require '../environment/Constants.coffee'
EventDispatcher = require '../event/EventDispatcher.coffee'
Factor = require '../factor/Factor.coffee'
#Organism = require '../environment/Organism.coffee'

class DisharmonyCalculator

	# Comparison modes
	@NODE_COMPARISON_MODE_UNKNOWN:          0
	@NODE_COMPARISON_MODE_FACTOR_HARMONY:   1
	@NODE_COMPARISON_MODE_ORGANISM_HARMONY: 2

	# Node actions
	@NODE_ACTION_MOVE_VALUE_NONE: 3
	@NODE_ACTION_MOVE_VALUE_1:    4
	@NODE_ACTION_MOVE_VALUE_2:    5
	@NODE_ACTION_SAVE_VALUE_1:    6
	@NODE_ACTION_SAVE_VALUE_2:    7
	@NODE_ACTION_SAVE_BOTH:       8

	#
	# Constructor
	#
	constructor: (@_organism, @debug = false) ->


	###
		Organism disharmony
	###

	# Returns the sum of factor disharmony within the organism
	getSummedOrganismDisharmony: () ->
		#console.log "#getSummedOrganismDisharmony"
		sumDisharmony = 0
		sumDisharmony += @getFactorDisharmonyForNodes factor, @_organism.getNodes() for factor in @_organism.getFactors()
		avgDisharmony = sumDisharmony / @_organism.getNodes().length
		sumDisharmony

	#
	# Returns the sum of factor disharmony within the organism,
	# adjusted with the disharmony existing between the factors
	# themselves.
	#
	getActualOrganismDisharmony: () ->
		disharmonies = []
		disharmonies[factor.factorType] = @getFactorDisharmonyForNodes factor, @_organism.getNodes() for factor in @_organism.getFactors()
		#console.log "#getActualOrganismDisharmony"
		#console.log "      ... before:", disharmonies

		# Adjust disharmonies according to correlations
		correlations = Factor.FACTOR_CORRELATIONS
		
		# Iterate the number of factors
		for factorType in [1..Constants.NUM_FACTORS]

			# Iterate all correlation
			for correlatingFactorType in [1..Constants.NUM_FACTORS]

				# If correlation exists...
				if correlations[factorType]? and correlations[factorType][correlatingFactorType]?

					# Get correlation value
					correlationValue = correlations[factorType][correlatingFactorType]

					# We use subtractions, since a positive correlation means less disharmony
					disharmonyDiff = Math.abs(disharmonies[factorType] - disharmonies[correlatingFactorType])
					disharmonies[factorType] += Math.pow(disharmonyDiff, 2.2) * (100 - correlationValue) / (100 * disharmonyDiff)

		# Sum it up and return the value
		actualDisharmony = disharmonies.reduce (a, b) -> a + b
		actualDisharmony


	###
		Factor-node disharmony
	###

	#
	# Returns the sum of disharmony existing between a given factor
	# and a set of nodes with cells affecting that factor.
	#
	getFactorDisharmonyForNodes: (factor, nodes) ->
		#console.log "#getFactorDisharmonyForNodes", factor.factorType, nodes if @debug

		disharmony = 0
		for node in nodes
			#console.log "  -- check against node #{ node.nodeId }" if @debug
			disharmony += @getFactorDisharmonyForNode factor, node if node.hasCellOfFactorType factor.factorType
		disharmony

	#
	# Returns the disharmony between a given factor and a given node.
	#
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
		

	#
	# Returns an array of associative relative disharmonies
	# between the given factors.
	#
	getRelativeDisharmonyForFactors: (factors) ->


	###
		Node comparison
	###

	#
	# Compares the given nodes using the given comparison mode,
	# and then alters them striving for reduced disharmony.
	#
	alterNodesInComparisonMode: (nodes, comparisonMode) ->
		#console.log "DisharmonyCalculator.alterNodesInComparisonMode --- mode: #{ comparisonMode }, nodes:", nodes

		# Deside what comparison method to use
		comparisonFn = if comparisonMode is DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY then 'getFactorDisharmonyForNodes' else 'getActualOrganismDisharmony'

		# Check which cells should be subjects for alteration
		cellsToCompare = []
		for aCell in nodes[0].getCells()
			for bCell in nodes[1].getCells()
				if aCell.factorType is bCell.factorType
					cellsToCompare.push aCell.factorType

		for factorType in cellsToCompare

			# Make a copy of the nodes
			testNodes = nodes #(node.clone() for node in nodes)

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
					#console.log " >>> ABRUPT: Needed to rescue nodes <<<"
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

			# Perform the given action
			@_performAction nodes, factorType, nodeAction

		return true

	#
	# Perform a given alteration action on two nodes
	#
	_performAction: (nodes, factorType, action) ->
		switch action
			when DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1
				nodes[0].addCellValue factorType, -1
				nodes[1].addCellValue factorType, 1
			when DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2
				nodes[0].addCellValue factorType, 1
				nodes[1].addCellValue factorType, -1
		#console.log "   after: #{ nodes[0].getString() }   #{ nodes[1].getString() }"

		EventDispatcher.trigger 'audanism/alter/nodes', [{ 'nodes':nodes, 'factorType':factorType, 'action':action }]

	#
	# Calculate disharmony when the given value is lower than
	# the value to compare to.
	#
	_calcFactorDisharmonyForNode_lteF: (c, F) ->
		result = -(Math.pow c, 2)/(Math.pow F, 2) + 1
		result = Math.pow result, 6
		result = Math.pow (result + 1), 10
		result

	#
	# Calculate disharmony when the given value is higher than
	# the value to compare to.
	#
	_calcFactorDisharmonyForNode_gtF: (c, F) ->
		result = -((c-F)*(c-200+F)) / Math.pow (100-F), 2
		result = Math.pow result, 6
		result = Math.pow (result + 1), 10
		result


#window.Audanism.Calculator.DisharmonyCalculator = DisharmonyCalculator
module.exports = DisharmonyCalculator