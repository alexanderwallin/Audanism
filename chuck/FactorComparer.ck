class FactorComparer

	@getFactorDisharmonyForNodes: (factor, nodes) ->
		disharmony = 0
		disharmony += FactorComparer.getFactorDisharmonyForNode factor, node for node in nodes
		disharmony

	@getFactorDisharmonyForNode: (factor, node) ->

		return 0.01 * Math.abs(factor.factorValue - node.getCellValue(factor.factorType))

	# Returns an array of associative relative disharmonies
	# between the given factors.
	@getRelativeDisharmonyForFactors: (factors) ->


window.FactorComparer = FactorComparer