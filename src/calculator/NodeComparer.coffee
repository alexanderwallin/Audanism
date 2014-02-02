class NodeComparer

	# Comparison modes
	@COMPARISON_MODE_UNKNOWN: 0
	@COMPARISON_MODE_FACTOR_HARMONY: 1
	@COMPARISON_MODE_ORGANISM_HARMONY: 2

	# Compares the given nodes using the given comparison mode,
	# and then alters them striving for reduced disharmony.
	@alterNodesInComparisonMode: (nodes, comparisonMode) ->
		#console.log "NodeComparer.alterNodesInComparisonMode --- mode: #{ comparisonMode }, nodes:", nodes

		if comparisonMode == NodeComparer.COMPARISON_MODE_FACTOR_HARMONY
			@_alterNodesUsingFactorHarmonyComparison nodes 
		else 
			@_alterNodesUsingOrganismHarmonyComparison nodes

	# Compares the given nodes striving for an alteration giving
	# less factor disharmony.
	@_alterNodesUsingFactorHarmonyComparison: (nodes) ->
		#console.log "   #_alterNodesUsingFactorHarmonyComparison"

		for node in nodes
			$(".node[data-node-id=#{ node.nodeId }]").addClass('comparing')

		# 
		for aCell in nodes[0].getCells()
			for bCell in nodes[1].getCells()
				# console.log "        aCell.type =", aCell.factorType, "bCell.type = ", bCell.factorType, "==> ", aCell.factorType is bCell.factorType
				if aCell.factorType is bCell.factorType
					console.log "      alter factor #{ aCell.factorType } for cells in #{ nodes[0].nodeId } and #{ nodes[1].nodeId }"

					# Get factor disharmony for all possible actions
					FactorComparer.getFactorDisharmonyForNodes 


	# Compares the given nodes striving for an alteration giving
	# less organism disharmony.
	@_alterNodesUsingOrganismHarmonyComparison: (nodes) ->
		#console.log "   #_alterNodesUsingOrganismHarmonyComparison"


window.NodeComparer = NodeComparer