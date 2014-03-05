###
	A node cell
###
class NodeCell

	clone: () ->
		new Audanism.Node.NodeCell @factorType, @factorValue

	constructor: (@factorType, @factorValue) ->

	addFactorValue: (value) ->
		@factorValue += value
		@factorValue = 0 if @factorValue < 0
		@factorValue = 100 if @factorValue > 100


window.Audanism.Node.NodeCell = NodeCell