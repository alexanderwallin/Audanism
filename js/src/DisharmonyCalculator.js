// Generated by CoffeeScript 1.10.0

/*
	DisharmonyCalculator

	The disharmony calculator 

	@author Alexander Wallin
	@url    http://alexanderwallin.com
 */

(function() {
  var DisharmonyCalculator;

  DisharmonyCalculator = (function() {
    DisharmonyCalculator.NODE_COMPARISON_MODE_UNKNOWN = 0;

    DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY = 1;

    DisharmonyCalculator.NODE_COMPARISON_MODE_ORGANISM_HARMONY = 2;

    DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_NONE = 3;

    DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1 = 4;

    DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2 = 5;

    DisharmonyCalculator.NODE_ACTION_SAVE_VALUE_1 = 6;

    DisharmonyCalculator.NODE_ACTION_SAVE_VALUE_2 = 7;

    DisharmonyCalculator.NODE_ACTION_SAVE_BOTH = 8;

    function DisharmonyCalculator(_organism, debug) {
      this._organism = _organism;
      this.debug = debug != null ? debug : false;
    }


    /*
    		Organism disharmony
     */

    DisharmonyCalculator.prototype.getSummedOrganismDisharmony = function() {
      var avgDisharmony, factor, i, len, ref, sumDisharmony;
      sumDisharmony = 0;
      ref = this._organism.getFactors();
      for (i = 0, len = ref.length; i < len; i++) {
        factor = ref[i];
        sumDisharmony += this.getFactorDisharmonyForNodes(factor, this._organism.getNodes());
      }
      avgDisharmony = sumDisharmony / this._organism.getNodes().length;
      return sumDisharmony;
    };

    DisharmonyCalculator.prototype.getActualOrganismDisharmony = function() {
      var actualDisharmony, correlatingFactorType, correlationValue, correlations, disharmonies, disharmonyDiff, factor, factorType, i, j, k, len, ref, ref1, ref2;
      disharmonies = [];
      ref = this._organism.getFactors();
      for (i = 0, len = ref.length; i < len; i++) {
        factor = ref[i];
        disharmonies[factor.factorType] = this.getFactorDisharmonyForNodes(factor, this._organism.getNodes());
      }
      correlations = Audanism.Factor.Factor.FACTOR_CORRELATIONS;
      for (factorType = j = 1, ref1 = Audanism.Environment.Organism.NUM_FACTORS; 1 <= ref1 ? j <= ref1 : j >= ref1; factorType = 1 <= ref1 ? ++j : --j) {
        for (correlatingFactorType = k = 1, ref2 = Audanism.Environment.Organism.NUM_FACTORS; 1 <= ref2 ? k <= ref2 : k >= ref2; correlatingFactorType = 1 <= ref2 ? ++k : --k) {
          if ((correlations[factorType] != null) && (correlations[factorType][correlatingFactorType] != null)) {
            correlationValue = correlations[factorType][correlatingFactorType];
            disharmonyDiff = Math.abs(disharmonies[factorType] - disharmonies[correlatingFactorType]);
            disharmonies[factorType] += Math.pow(disharmonyDiff, 2.2) * (100 - correlationValue) / (100 * disharmonyDiff);
          }
        }
      }
      actualDisharmony = disharmonies.reduce(function(a, b) {
        return a + b;
      });
      return actualDisharmony;
    };


    /*
    		Factor-node disharmony
     */

    DisharmonyCalculator.prototype.getFactorDisharmonyForNodes = function(factor, nodes) {
      var disharmony, i, len, node;
      disharmony = 0;
      for (i = 0, len = nodes.length; i < len; i++) {
        node = nodes[i];
        if (node.hasCellOfFactorType(factor.factorType)) {
          disharmony += this.getFactorDisharmonyForNode(factor, node);
        }
      }
      return disharmony;
    };

    DisharmonyCalculator.prototype.getFactorDisharmonyForNode = function(factor, node) {
      var cell, disharmony, ref;
      disharmony = 0;
      cell = node.getCell(factor.factorType);
      if (!cell) {
        return;
      }
      if ((0 <= (ref = cell.factorValue) && ref <= factor.factorValue)) {
        disharmony = this._calcFactorDisharmonyForNode_lteF(cell.factorValue, factor.factorValue);
      } else {
        disharmony = this._calcFactorDisharmonyForNode_gtF(cell.factorValue, factor.factorValue);
      }
      return disharmony;
    };

    DisharmonyCalculator.prototype.getRelativeDisharmonyForFactors = function(factors) {};


    /*
    		Node comparison
     */

    DisharmonyCalculator.prototype.alterNodesInComparisonMode = function(nodes, comparisonMode) {
      var aCell, bCell, cell, cellsToCompare, comparisonFn, currentDisharmony, factor, factorType, i, j, k, l, len, len1, len2, len3, neededSaveNode, newDisharmony1, newDisharmony2, node, nodeAction, ref, ref1, smallestNewDisharmony, testNodes;
      comparisonFn = comparisonMode === Audanism.Calculator.NODE_COMPARISON_MODE_FACTOR_HARMONY ? 'getFactorDisharmonyForNodes' : 'getActualOrganismDisharmony';
      cellsToCompare = [];
      ref = nodes[0].getCells();
      for (i = 0, len = ref.length; i < len; i++) {
        aCell = ref[i];
        ref1 = nodes[1].getCells();
        for (j = 0, len1 = ref1.length; j < len1; j++) {
          bCell = ref1[j];
          if (aCell.factorType === bCell.factorType) {
            cellsToCompare.push(aCell.factorType);
          }
        }
      }
      for (k = 0, len2 = cellsToCompare.length; k < len2; k++) {
        factorType = cellsToCompare[k];
        testNodes = nodes;
        nodeAction;
        neededSaveNode = false;
        for (l = 0, len3 = nodes.length; l < len3; l++) {
          node = nodes[l];
          cell = node.getCell(factorType);
          if (cell.factorValue === 0) {
            node.addCellValue(factorType, 1);
            neededSaveNode = true;
          }
          if (cell.factorValue === 100) {
            node.addCellValue(factorType, -1);
            neededSaveNode = true;
          }
          if (neededSaveNode) {
            return;
          }
        }
        factor = this._organism.getFactorOfType(factorType);
        currentDisharmony = this[comparisonFn](factor, testNodes);
        testNodes[0].addCellValue(factorType, -1);
        testNodes[1].addCellValue(factorType, 1);
        newDisharmony1 = this[comparisonFn](factor, testNodes);
        testNodes[0].addCellValue(factorType, 2);
        testNodes[1].addCellValue(factorType, -2);
        newDisharmony2 = this[comparisonFn](factor, testNodes);
        testNodes[0].addCellValue(factorType, -1);
        testNodes[1].addCellValue(factorType, 1);
        smallestNewDisharmony = newDisharmony1 < newDisharmony2 ? newDisharmony1 : newDisharmony2;
        nodeAction = newDisharmony1 < newDisharmony2 ? Audanism.Calculator.DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1 : Audanism.Calculator.DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2;
        this._performAction(nodes, factorType, nodeAction);
      }
      return true;
    };

    DisharmonyCalculator.prototype._performAction = function(nodes, factorType, action) {
      switch (action) {
        case Audanism.Calculator.DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_1:
          nodes[0].addCellValue(factorType, -1);
          nodes[1].addCellValue(factorType, 1);
          break;
        case Audanism.Calculator.DisharmonyCalculator.NODE_ACTION_MOVE_VALUE_2:
          nodes[0].addCellValue(factorType, 1);
          nodes[1].addCellValue(factorType, -1);
      }
      return EventDispatcher.trigger('audanism/alter/nodes', [
        {
          'nodes': nodes,
          'factorType': factorType,
          'action': action
        }
      ]);
    };

    DisharmonyCalculator.prototype._calcFactorDisharmonyForNode_lteF = function(c, F) {
      var result;
      result = -(Math.pow(c, 2)) / (Math.pow(F, 2)) + 1;
      result = Math.pow(result, 6);
      result = Math.pow(result + 1, 10);
      return result;
    };

    DisharmonyCalculator.prototype._calcFactorDisharmonyForNode_gtF = function(c, F) {
      var result;
      result = -((c - F) * (c - 200 + F)) / Math.pow(100 - F, 2);
      result = Math.pow(result, 6);
      result = Math.pow(result + 1, 10);
      return result;
    };

    return DisharmonyCalculator;

  })();

  window.Audanism.Calculator.DisharmonyCalculator = DisharmonyCalculator;

}).call(this);
