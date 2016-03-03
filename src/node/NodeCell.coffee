###
	NodeCell

	A node cell has a factor type and a value.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
###
class NodeCell

	#
	# Returns a copy of this cell
	#
	clone: () ->
		new NodeCell @factorType, @factorValue

	#
	# Constructor
	#
	constructor: (@factorType, @factorValue) ->

	#
	# Adds some value to the cell's value
	#
	addFactorValue: (value) ->
		@factorValue += value
		@factorValue = 0 if @factorValue < 0
		@factorValue = 100 if @factorValue > 100


#window.Audanism.Node.NodeCell = NodeCell
module.exports = NodeCell