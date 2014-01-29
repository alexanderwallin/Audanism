/*
	DisharmonyCalculator
*/
DisharmonyCalculator {

	// Comparison modes
	classvar NODE_COMPARISON_MODE_UNKNOWN = 0;
	classvar NODE_COMPARISON_MODE_FACTOR_HARMONY = 1;
	classvar NODE_COMPARISON_MODE_ORGANISM_HARMONY = 2;

	// Node actions
	classvar NODE_ACTION_MOVE_VALUE_NONE = 3;
	classvar NODE_ACTION_MOVE_VALUE_1 = 4;
	classvar NODE_ACTION_MOVE_VALUE_2 = 5;
	classvar NODE_ACTION_SAVE_VALUE_1 = 6;
	classvar NODE_ACTION_SAVE_VALUE_2 = 7;
	classvar NODE_ACTION_SAVE_BOTH = 8;

	// Constructor
	constructor { arg _organism, debug = false;
		this._organism = _organism;
		this.debug = debug;

	/*
		Organism disharmony
	*/

	// Returns the sum of factor disharmony within the organism
	getSummedOrganismDisharmony {
		sumDisharmony = 0
		sumDisharmony += this.getFactorDisharmonyForNodes factor, this._organism.getNodes() for factor in this._organism.getFactors()
		avgDisharmony = sumDisharmony / this._organism.getNodes().length
		sumDisharmony

	// Returns the sum of factor disharmony within the organism,
	// adjusted with the disharmony existing between the factors
	// themselves.
	getActualOrganismDisharmony {
		disharmonies = []
		disharmonies[factor.factorType] = this.getFactorDisharmonyForNodes factor, this._organism.getNodes() for factor in this._organism.getFactors()

		// Adjust disharmonies according to correlations
		correlations = Factor.FACTOR_CORRELATIONS
		//correlationsArray[factor.factorType] = Factor.FACTOR_CORRELATIONS[factor.factorType] for factor in this._organism.getFactors()
		//for factorCorrelations, factorType in correlationsArray
		//	for correlatingFactorType in factorCorrelations

		for factorType in [1..Organism.NUM_FACTORS]
			for correlatingFactorType in [1..Organism.NUM_FACTORS]
				if correlations[factorType]? and correlations[factorType][correlatingFactorType]?
					correlationValue = correlations[factorType][correlatingFactorType]


					// We use subtractions, since a positive correlation means less disharmony
					disharmonyDiff = Math.abs(disharmonies[factorType] - disharmonies[correlatingFactorType])
					disharmonies[factorType] += Math.pow(disharmonyDiff, 2.2) * (100 - correlationValue) / (100 * disharmonyDiff)


		actualDisharmony = disharmonies.reduce (a, b) -> a + b
		actualDisharmony

	/*
		Factor-node disharmony
	*/

	// Returns the sum of disharmony existing between a given factor
	// and a set of nodes with cells affecting that factor.
	getFactorDisharmonyForNodes { arg factor, nodes;

		disharmony = 0
		for node in nodes
			disharmony += this.getFactorDisharmonyForNode factor, node if node.hasCellOfFactorType factor.factorType
		disharmony

	// Returns the disharmony between a given factor and a given node.
	getFactorDisharmonyForNode { arg factor, node;
		disharmony = 0

		cell = node.getCell factor.factorType
		return if not cell

		if 0 <= cell.factorValue <= factor.factorValue
			disharmony = this._calcFactorDisharmonyForNode_lteF cell.factorValue, factor.factorValue
		else
			disharmony = this._calcFactorDisharmonyForNode_gtF cell.factorValue, factor.factorValue

		disharmony
		


	// Returns an array of associative relative disharmonies
	// between the given factors.
	getRelativeDisharmonyForFactors { arg factors;


	/*
		Node comparison
	*/

	// Compares the given nodes using the given comparison mode,
	// and then alters them striving for reduced disharmony.
	alterNodesInComparisonMode { arg nodes, comparisonMode;

		comparisonFn = if comparisonMode is DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY then 'getFactorDisharmonyForNodes' else 'getActualOrganismDisharmony'

		//if comparisonMode is DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY
		//	 this._alterNodesUsingFactorHarmonyComparison nodes 
		//else if comparisonMode is DisharmonyCalculator.NODE_COMPARISON_MODE_ORGANISM_HARMONY
		//	this._alterNodesUsingOrganismHarmonyComparison nodes

		$(".node.comparing").removeClass('comparing')
		for node in nodes
			$(".node[data-node-id=#{ node.nodeId }]").addClass('comparing')

		// Check which cells should be subjects for alteration
		cellsToCompare = []
		for aCell in nodes[0].getCells()
			for bCell in nodes[1].getCells()
				if aCell.factorType is bCell.factorType
					cellsToCompare.push aCell.factorType


		for factorType in cellsToCompare

			// Make a copy of the nodes
			testNodes = nodes #(node.clone() for node in nodes)
			Node._idCounter-- for node in nodes
			//continue

			nodeAction
			neededSaveNode = false

			// If any cell has a value of 0 or 100, force actions evening out
			// those cells
			for node in nodes
				cell = node.getCell factorType
				if cell.factorValue is 0
					node.addCellValue factorType, 1
					neededSaveNode = true
				if cell.factorValue is 100
					node.addCellValue factorType, -1
					neededSaveNode = true
				if neededSaveNode
					return

			// Start by storing the current disharmony
			factor = this._organism.getFactorOfType factorType
			currentDisharmony = this.[comparisonFn](factor, testNodes)

			// Action #1
			testNodes[0].addCellValue factorType, -1
			testNodes[1].addCellValue factorType, 1
			newDisharmony1 = this.[comparisonFn](factor, testNodes)

			// Action #1
			testNodes[0].addCellValue factorType, 2
			testNodes[1].addCellValue factorType, -2
			newDisharmony2 = this.[comparisonFn](factor, testNodes)

			// Reset
			testNodes[0].addCellValue factorType, -1
			testNodes[1].addCellValue factorType, 1

			smallestNewDisharmony = if newDisharmony1 < newDisharmony2 then newDisharmony1 else newDisharmony2
			nodeAction = if newDisharmony1 < newDisharmony2 then DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1 else DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2

			//if currentDisharmony > smallestNewDisharmony
			this._performAction nodes, factorType, nodeAction

		return true

	// Perform a given alteration action on two nodes
	_performAction { arg nodes, factorType, action;
		switch action
			when DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1
				nodes[0].addCellValue factorType, -1
				nodes[1].addCellValue factorType, 1
			when DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2
				nodes[0].addCellValue factorType, 1
				nodes[1].addCellValue factorType, -1


	_calcFactorDisharmonyForNode_lteF { arg c, F;
		result = -(Math.pow c, 2)/(Math.pow F, 2) + 1
		result = Math.pow result, 6
		result = Math.pow (result + 1), 10
		result

	_calcFactorDisharmonyForNode_gtF { arg c, F;
		result = -((c-F)*(c-200+F)) / Math.pow (100-F), 2
		result = Math.pow result, 6
		result = Math.pow (result + 1), 10
		result


