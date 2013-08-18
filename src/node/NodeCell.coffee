###
	A node cell
###
class NodeCell

	clone: () ->
		new NodeCell @factorType, @factorValue

	constructor: (@factorType, @factorValue) ->


window.NodeCell = NodeCell