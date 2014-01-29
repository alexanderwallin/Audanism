/*
	Organism
*/
Organism {

	// Options
	classvar NUM_FACTORS = 5;
	classvar DEFAULT_NUM_NODES = 40;
	classvar DISTRIBUTE_FACTOR_VALUES = false;

	// Stress thresholds - the thresholds for when the organism enters
	// and leaves stress mode
	classvar STRESS_THRESHOLD_ENTER = 1;
	classvar STRESS_THRESHOLD_LEAVE = 2;

	// Constructor
	constructor { arg numNodes = -1;

		// Disharmony
		this._sumDisharmony = 0
		this._actualDisharmony = 0

		// Stress mode
		this._inStressMode = true
		$('#stressmode').change (e) =>
			this._inStressMode = $(e.currentTarget).attr('checked') is 'checked'

		// Create factors
		this._factors = (Factor.createFactor i, 0 for i in [1..Organism.NUM_FACTORS])

		// Create nodes
		numNodes = Organism.DEFAULT_NUM_NODES if numNodes <= 0
		this._createNodes numNodes

		// Disharmony calculator
		this.disharmonyCalculator = new DisharmonyCalculator @

		// Disharmony history
		this.disharmonyHistory = []

		// GUI
		this._gui = new GUI

	//
	// Returns the node with the given id.
	//
	getNode { arg nodeId;
		if this._nodes[nodeId]? then this._nodes[nodeId] else null

	//
	// Returns all nodes that have a cell with the given factor type.
	//
	getNodesWithCellsOfFactorType { arg factorType;
		this._nodeCellIndex[factorType]

	//
	// Returns the organism's nodes
	//
	getNodes {
		this._nodes

	//
	// Returns the organism's factors
	//
	getFactors {
		this._factors

	//
	// Returns, if found, the factor within the organism that has the given
	// factor type.
	//
	getFactorOfType { arg factorType;
		foundFactor = null
		for factor in this._factors
			foundFactor = factor if factor.factorType is factorType
		foundFactor

	//
	// Compares and alters children nodes
	//
	performNodeComparison { arg numComparisons = 1;

		
		this.disharmonyCalculator.debug = true

		// First, perform node comparison and alterations
		for i in [1..numComparisons]
			
			// Get two nodes to compare
			nodes = this._getRandomNodes 2

			// Trigger alteration of nodes
			comparisonMode = if this._inStressMode and false then DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY else DisharmonyCalculator.NODE_COMPARISON_MODE_ORGANISM_HARMONY
			this.disharmonyCalculator.alterNodesInComparisonMode nodes, comparisonMode

		this.disharmonyCalculator.debug = false

		// Then, update disharmony state
		this._sumDisharmony 	= this.disharmonyCalculator.getSummedOrganismDisharmony @
		this._actualDisharmony 	= this.disharmonyCalculator.getActualOrganismDisharmony @
		this.disharmonyHistory.push [this.disharmonyHistory.length, this._sumDisharmony, this._actualDisharmony]

		factor.disharmony = this.disharmonyCalculator.getFactorDisharmonyForNodes factor, this._nodes for factor in this._factors

		// Check if it should enter or leave stress mode
		if not this._inStressMode and this._actualDisharmony < Organism.STRESS_THRESHOLD_ENTER
			this._inStressMode = true
		else if this._inStressMode and this._actualDisharmony > Organism.STRESS_THRESHOLD_LEAVE
			this._inStressMode = false

	// Returns the disharmony history data, reduced to the
	// given number of data entries.
	getDisharmonyHistoryData { arg numEntries = 300;
		if numEntries > 0 then this.disharmonyHistory.slice -numEntries else this.disharmonyHistory.slice -this.disharmonyHistory.length

	// Creates the organism's nodes
	_createNodes { arg numNodes;

		// Create indexes
		this._nodeCellIndex = []
		this._nodeCellIndex[factor.factorType] = [] for factor in this._factors

		// Create nodes array with node IDs as key
		nodes = (new Node() for i in [1..numNodes])
		this._nodes = []
		this._nodes[node.nodeId] = node for node in nodes
		
		// Add nodes to indexes
		for node in nodes
			for cell in node.getCells()
				this._nodeCellIndex[cell.factorType].push node

		// Distribute the factor values amongst the nodes
		if Organism.DISTRIBUTE_FACTOR_VALUES
			for factor in this._factors
				nodesWithFactorCells = this.getNodesWithCellsOfFactorType factor.factorType
				getRandomElements(nodesWithFactorCells, 1)[0].addCellValue(factor.factorType, 1) for i in [1..factor.factorValue]
		else
			for node in nodes
				for cell in node.getCells()
					cell.factorValue = Math.randomRange 0, 100

	//
	// Returns a given number of randomly selected nodes
	//
	_getRandomNodes { arg numNodes;
		allNodeIndexes = [0..(this._nodes.length-1)]

		nodeIndexes = (allNodeIndexes.splice(Math.floor(Math.random() * allNodeIndexes.length), 1) for i in [1..numNodes])

		(this._nodes[i] for i in nodeIndexes)

	//
	// Returns the given number of nodes that has a cell with
	// the given factor type.
	//
	_getRandomNodesOfFactorType { arg factorType, numNodes;
		getRandomElements(this._nodeCellIndex[factorType], numNodes)




