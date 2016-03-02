// Generated by CoffeeScript 1.10.0

/*
	Node

	A node contains a set of NodeCell objects, which are alterable via
	methods here.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
 */

(function() {
  var Node;

  Node = (function() {
    Node._idCounter = 0;

    Node.NUM_CELLS = 2;

    Node.prototype.clone = function() {
      var cell, key, newNode;
      newNode = new Audanism.Node.Node;
      Node._idCounter--;
      for (key in this) {
        newNode[key] = this[key];
      }
      newNode._cells = (function() {
        var j, len, ref, results;
        ref = newNode._cells;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          cell = ref[j];
          results.push(cell.clone());
        }
        return results;
      })();
      return newNode;
    };

    function Node() {
      var factorIndexes, i, j, ref, results;
      this.nodeId = Node._idCounter++;
      factorIndexes = (function() {
        results = [];
        for (var j = 1, ref = Audanism.Environment.Organism.NUM_FACTORS; 1 <= ref ? j <= ref : j >= ref; 1 <= ref ? j++ : j--){ results.push(j); }
        return results;
      }).apply(this);
      this._cells = (function() {
        var k, ref1, results1;
        results1 = [];
        for (i = k = 1, ref1 = Audanism.Node.Node.NUM_CELLS; 1 <= ref1 ? k <= ref1 : k >= ref1; i = 1 <= ref1 ? ++k : --k) {
          results1.push(new Audanism.Node.NodeCell(factorIndexes.splice(Math.floor(Math.random() * factorIndexes.length), 1)[0], 0));
        }
        return results1;
      })();
      this._cells.sort(function(a, b) {
        return a.factorType > b.factorType;
      });
    }

    Node.prototype.getCells = function() {
      return this._cells;
    };

    Node.prototype.getCell = function(factorType) {
      wantedCell;
      var cell, j, len, ref, wantedCell;
      ref = this._cells;
      for (j = 0, len = ref.length; j < len; j++) {
        cell = ref[j];
        if (cell.factorType === factorType) {
          wantedCell = cell;
          break;
        }
      }
      return wantedCell;
    };

    Node.prototype.hasCellOfFactorType = function(factorType) {
      var cell, hasCell, j, len, ref;
      hasCell = false;
      ref = this._cells;
      for (j = 0, len = ref.length; j < len; j++) {
        cell = ref[j];
        hasCell = hasCell || cell.factorType === factorType;
      }
      return hasCell;
    };

    Node.prototype.getCellValue = function(factorType) {
      var cell;
      cell = this.getCell(factorType);
      if (cell) {
        return cell.factorValue;
      } else {
        return 0;
      }
    };

    Node.prototype.setCellValue = function(factorType, value) {
      var cell;
      cell = this.getCell(factorType);
      cell.factorValue = value;
      if (cell.factorValue < 0) {
        cell.factorValue = 0;
      }
      if (cell.factorValue > 100) {
        return cell.factorValue = 100;
      }
    };

    Node.prototype.addCellValue = function(factorType, addValue) {
      return this.setCellValue(factorType, this.getCellValue(factorType) + addValue);
    };

    Node.prototype.getCellValues = function(asString) {
      var cell, cellValues;
      if (asString == null) {
        asString = false;
      }
      cellValues = (function() {
        var j, len, ref, results;
        ref = this._cells;
        results = [];
        for (j = 0, len = ref.length; j < len; j++) {
          cell = ref[j];
          results.push(cell.factorValue);
        }
        return results;
      }).call(this);
      if (asString) {
        return cellValues.join(" ");
      } else {
        return cellValues;
      }
    };

    Node.prototype.getString = function() {
      return "#" + this.nodeId + " {" + (this.getCellValues(true)) + "}";
    };

    Node.prototype.toString = function() {
      return this.getString();
    };

    return Node;

  })();

  window.Audanism.Node.Node = Node;

}).call(this);
