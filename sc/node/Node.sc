
//Audanism.nodes.NodeCell;

/*
	An organism node.
*/
Node {

	// An incrementing node ID
	classvar idCounter;

	// The number of cells that each node should have
	const numCells = 5;

	*initClass {
		idCounter = 0;
	}

	*new {
		^super.new.init;
	}

	var <nodeId, <cells;

	init {
		Node.idCounter = Node.idCounter + 1;
		this.nodeId = Node.idCounter;

		var factorIndexes = (1..5);
		var emptyCellVals = 0!5;

		this.cells = Array.newClean(Node.numCells);
		0.dup(Node.numCells).do{ arg count;
			this.cells[count] = NodeCell.new(factorIndexes.removeAt(rand(factorIndexes)), Array.newFrom(emptyCellVals));
		};
	}

	getCell { arg factorType;
		var wantedCell;

		this.cells.do{ arg item;
			if (item.factorType == factorType)
				wantedCell = item;
		}

		^wantedCell;
	}

	hasCellOfFactorType { arg factorType;
		var hasCell = false
		this.cells.do{ arg item;
			hasCell = hasCell || item.factorType == factorType;
		}
		^hasCell
	}

	getCellValue { arg factorType;
		cell = this.getCell(factorType);
		if (cell, {
			^cell.factorValue;
		}, {
			^0;
		});
	}

	setCellValue { arg factorType, value;
		cell = this.getCell(factorType);
		var newVal;
		newVal = if (value > 100, { 100 }, { value });
		newVal = if (valu < 0, { 0 }, { value });

		cell.setFactorValue_(value);
	}

	addCellValue { arg factorType, addValue;
		this.setCellValue(factorType, this.getCellValue(factorType) + addValue);
	}

	getCellValues { arg asString = false;
		cellValues = (cell.factorValue for cell in this._cells)
		if (asString, {
			^cellValues.asString()
		}, {
			^cellValues
		});
	}

	getString {
		//"##{ this.nodeId } {#{ this.getCellValues(true) }}"
		^this.getCellValues();
	}

	toString {
		^this.getString();
	}
}




