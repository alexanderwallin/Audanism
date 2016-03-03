###
	Node

	A node contains a set of NodeCell objects, which are alterable via
	methods here.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
###

Constants = require '../environment/Constants.coffee'
NodeCell = require './NodeCell.coffee'

class Node

	# An incrementing node ID
	@_idCounter: 0

	# The number of cells that each node should have
	@NUM_CELLS: 2

	#
	# Node clone method
	#
	clone: () ->
		newNode = new Node
		Node._idCounter--

		for key of @
			newNode[key] = @[key]

		newNode._cells = (cell.clone() for cell in newNode._cells)
		newNode

	#
	# Constructor
	#
	constructor: () ->
		@nodeId = Node._idCounter++

		# Create a list of factor indexes
		factorIndexes = [1..Constants.NUM_FACTORS]

		# Create cells
		@_cells = (new NodeCell factorIndexes.splice(Math.floor(Math.random() * factorIndexes.length), 1)[0], 0 for i in [1..Node.NUM_CELLS])

		# Sort cells on factor type
		@_cells.sort (a, b) ->
			a.factorType > b.factorType

	#
	# Returns the node's cells
	#
	getCells: () ->
		@_cells

	#
	# Returns the cell with the given factor type, if it exists
	#
	getCell: (factorType) ->
		wantedCell

		for cell in @_cells
			if cell.factorType is factorType
				wantedCell = cell
				break

		wantedCell

	#
	# Returns whether the node has a cell of the given factor type
	#
	hasCellOfFactorType: (factorType) ->
		hasCell = false
		for cell in @_cells
			hasCell = hasCell or cell.factorType is factorType 
		hasCell

	#
	# Returns the value of the cell with the given factor type, if
	# it exits.
	#
	getCellValue: (factorType) ->
		cell = @getCell factorType
		if cell then cell.factorValue else 0

	#
	# Sets a cell's value, if a cell with the given factor type exists.
	#
	setCellValue: (factorType, value) ->
		#console.log '#setCellValue', factorType, value
		cell = @getCell factorType
		cell.factorValue = value
		cell.factorValue = 0 if cell.factorValue < 0
		cell.factorValue = 100 if cell.factorValue > 100

	#
	# Adds some value to the cell with the given factor type, if it
	# exists.
	#
	addCellValue: (factorType, addValue) ->
		#console.log('     #addCellValue', factorType, addValue)
		@setCellValue factorType, @getCellValue(factorType) + addValue
		#console.log('     ... new value', @getCellValue factorType)

	#
	# Returns a list or comma-separated string with all the node's 
	# cells' values.
	#
	getCellValues: (asString = false) ->
		cellValues = (cell.factorValue for cell in @_cells)
		if asString	
			return cellValues.join " " 
		else
			return cellValues

	#
	# Returns a string representation of the node.
	#
	getString: () ->
		"##{ @nodeId } {#{ @getCellValues(true) }}"

	#
	# Alias for getString()
	#
	toString: () ->
		@getString()


#window.Audanism.Node.Node = Node
module.exports = Node