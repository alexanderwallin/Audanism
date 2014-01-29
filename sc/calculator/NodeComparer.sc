NodeComparer {

	// Comparison modes
	classvar COMPARISON_MODE_UNKNOWN = 0;
	classvar COMPARISON_MODE_FACTOR_HARMONY = 1;
	classvar COMPARISON_MODE_ORGANISM_HARMONY = 2;

	// Compares the given nodes using the given comparison mode,
	// and then alters them striving for reduced disharmony.
	*alterNodesInComparisonMode { arg nodes, comparisonMode;

		if comparisonMode == NodeComparer.COMPARISON_MODE_FACTOR_HARMONY
			this._alterNodesUsingFactorHarmonyComparison nodes 
		else 
			this._alterNodesUsingOrganismHarmonyComparison nodes

	// Compares the given nodes striving for an alteration giving
	// less factor disharmony.
	*_alterNodesUsingFactorHarmonyComparison { arg nodes;

		for node in nodes
			$(".node[data-node-id=#{ node.nodeId }]").addClass('comparing')

		// 
		for aCell in nodes[0].getCells()
			for bCell in nodes[1].getCells()
				if aCell.factorType is bCell.factorType

					// Get factor disharmony for all possible actions
					FactorComparer.getFactorDisharmonyForNodes 


	// Compares the given nodes striving for an alteration giving
	// less organism disharmony.
	*_alterNodesUsingOrganismHarmonyComparison { arg nodes;


