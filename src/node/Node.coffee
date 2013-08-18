###
	An organism node.
###
class Node

	# An incrementing node ID
	@_idCounter: 0

	# The number of cells that each node should have
	@NUM_CELLS: 2

	clone: () ->
		newNode = new Node
		Node._idCounter--

		for key of @
			newNode[key] = @[key]

		newNode._cells = (cell.clone() for cell in newNode._cells)
		newNode

	constructor: () ->
		@nodeId = Node._idCounter++

		factorIndexes = [1..Organism.NUM_FACTORS]
		@_cells = (new NodeCell factorIndexes.splice(Math.floor(Math.random() * factorIndexes.length), 1)[0], Math.round(Math.random() * 100) for i in [1..Node.NUM_CELLS])
		@_cells.sort (a, b) ->
			a.factorType > b.factorType

	getCells: () ->
		@_cells

	getCell: (factorType) ->
		wantedCell

		for cell in @_cells
			if cell.factorType is factorType
				wantedCell = cell
				break

		wantedCell

	hasCellOfFactorType: (factorType) ->
		hasCell = false
		for cell in @_cells
			hasCell = hasCell or cell.factorType is factorType 
		hasCell

	getCellValue: (factorType) ->
		cell = @getCell factorType
		if cell then cell.factorValue else 0

	setCellValue: (factorType, value) ->
		cell = @getCell factorType
		cell.factorValue = value
		cell.factorValue = 0 if @factorValue < 0
		cell.factorValue = 100 if @factorValue > 100

	addCellValue: (factorType, addValue) ->
		@setCellValue factorType, @getCellValue(factorType) + addValue

	getCellValues: (asString = false) ->
		cellValues = (cell.factorValue for cell in @_cells)
		if asString	
			return cellValues.join " " 
		else
			return cellValues

	getString: () ->
		"##{ @nodeId } {#{ @getCellValues(true) }}"


window.Node = Node