// Generated by CoffeeScript 1.4.0

/*
	An organism node.
*/


(function() {
  var Node;

  Node = (function() {

    Node._idCounter = 0;

    Node.NUM_CELLS = 2;

    Node.prototype.clone = function() {
      var cell, key, newNode;
      newNode = new Node;
      Node._idCounter--;
      for (key in this) {
        newNode[key] = this[key];
      }
      newNode._cells = (function() {
        var _i, _len, _ref, _results;
        _ref = newNode._cells;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          cell = _ref[_i];
          _results.push(cell.clone());
        }
        return _results;
      })();
      return newNode;
    };

    function Node() {
      var factorIndexes, i, _i, _ref, _results;
      this.nodeId = Node._idCounter++;
      factorIndexes = (function() {
        _results = [];
        for (var _i = 1, _ref = Organism.NUM_FACTORS; 1 <= _ref ? _i <= _ref : _i >= _ref; 1 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
      this._cells = (function() {
        var _j, _ref1, _results1;
        _results1 = [];
        for (i = _j = 1, _ref1 = Node.NUM_CELLS; 1 <= _ref1 ? _j <= _ref1 : _j >= _ref1; i = 1 <= _ref1 ? ++_j : --_j) {
          _results1.push(new NodeCell(factorIndexes.splice(Math.floor(Math.random() * factorIndexes.length), 1)[0], 0));
        }
        return _results1;
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

      var cell, wantedCell, _i, _len, _ref;
      _ref = this._cells;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cell = _ref[_i];
        if (cell.factorType === factorType) {
          wantedCell = cell;
          break;
        }
      }
      return wantedCell;
    };

    Node.prototype.hasCellOfFactorType = function(factorType) {
      var cell, hasCell, _i, _len, _ref;
      hasCell = false;
      _ref = this._cells;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        cell = _ref[_i];
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
      console.log('     #addCellValue', factorType, addValue);
      this.setCellValue(factorType, this.getCellValue(factorType) + addValue);
      return console.log('     ... new value', this.getCellValue(factorType));
    };

    Node.prototype.getCellValues = function(asString) {
      var cell, cellValues;
      if (asString == null) {
        asString = false;
      }
      cellValues = (function() {
        var _i, _len, _ref, _results;
        _ref = this._cells;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          cell = _ref[_i];
          _results.push(cell.factorValue);
        }
        return _results;
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

  window.Node = Node;

}).call(this);
