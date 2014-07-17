###
	
###
class FactorComparer

	# Returns the disharmony between a factor and a set of nodes
	@getFactorDisharmonyForNodes: (factor, nodes) ->
		disharmony = 0
		disharmony += FactorComparer.getFactorDisharmonyForNode factor, node for node in nodes
		disharmony

	# Returns the disharmony between a factor and a node
	@getFactorDisharmonyForNode: (factor, node) ->

		return 0.01 * Math.abs(factor.factorValue - node.getCellValue(factor.factorType))

	# Returns an array of associative relative disharmonies
	# between the given factors.
	@getRelativeDisharmonyForFactors: (factors) ->


window.Audanism.Calculator.FactorComparer = FactorComparer