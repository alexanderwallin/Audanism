// Generated by CoffeeScript 1.4.0

/*
	Organism
*/


(function() {
  var Organism;

  Organism = (function() {

    Organism.NUM_FACTORS = 5;

    Organism.DEFAULT_NUM_NODES = 44;

    Organism.DISTRIBUTE_FACTOR_VALUES = false;

    Organism.STRESS_THRESHOLD_ENTER = 1;

    Organism.STRESS_THRESHOLD_LEAVE = 2;

    function Organism(numNodes) {
      var i,
        _this = this;
      if (numNodes == null) {
        numNodes = -1;
      }
      this._sumDisharmony = 0;
      this._actualDisharmony = 0;
      this._inStressMode = true;
      $('#stressmode').change(function(e) {
        return _this._inStressMode = $(e.currentTarget).attr('checked') === 'checked';
      });
      this._factors = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 1, _ref = Organism.NUM_FACTORS; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          _results.push(Factor.createFactor(i, 0));
        }
        return _results;
      })();
      if (numNodes <= 0) {
        numNodes = Organism.DEFAULT_NUM_NODES;
      }
      this._createNodes(numNodes);
      this.disharmonyCalculator = new DisharmonyCalculator(this);
      this.disharmonyHistory = [];
      this._gui = new GUI;
    }

    Organism.prototype.getNode = function(nodeId) {
      if (this._nodes[nodeId] != null) {
        return this._nodes[nodeId];
      } else {
        return null;
      }
    };

    Organism.prototype.getNodesWithCellsOfFactorType = function(factorType) {
      return this._nodeCellIndex[factorType];
    };

    Organism.prototype.getNodes = function() {
      return this._nodes;
    };

    Organism.prototype.getFactors = function() {
      return this._factors;
    };

    Organism.prototype.getFactorOfType = function(factorType) {
      var factor, foundFactor, _i, _len, _ref;
      foundFactor = null;
      _ref = this._factors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        factor = _ref[_i];
        if (factor.factorType === factorType) {
          foundFactor = factor;
        }
      }
      return foundFactor;
    };

    Organism.prototype.performNodeComparison = function(numComparisons) {
      var comparisonMode, factor, i, nodes, _i, _j, _len, _ref;
      if (numComparisons == null) {
        numComparisons = 1;
      }
      this.disharmonyCalculator.debug = true;
      for (i = _i = 1; 1 <= numComparisons ? _i <= numComparisons : _i >= numComparisons; i = 1 <= numComparisons ? ++_i : --_i) {
        nodes = this._getRandomNodes(2);
        comparisonMode = this._inStressMode && false ? DisharmonyCalculator.NODE_COMPARISON_MODE_FACTOR_HARMONY : DisharmonyCalculator.NODE_COMPARISON_MODE_ORGANISM_HARMONY;
        this.disharmonyCalculator.alterNodesInComparisonMode(nodes, comparisonMode);
      }
      this.disharmonyCalculator.debug = false;
      this._sumDisharmony = this.disharmonyCalculator.getSummedOrganismDisharmony(this);
      this._actualDisharmony = this.disharmonyCalculator.getActualOrganismDisharmony(this);
      this.disharmonyHistory.push([this.disharmonyHistory.length, this._sumDisharmony, this._actualDisharmony]);
      _ref = this._factors;
      for (_j = 0, _len = _ref.length; _j < _len; _j++) {
        factor = _ref[_j];
        factor.disharmony = this.disharmonyCalculator.getFactorDisharmonyForNodes(factor, this._nodes);
      }
      if (!this._inStressMode && this._actualDisharmony < Organism.STRESS_THRESHOLD_ENTER) {
        return this._inStressMode = true;
      } else if (this._inStressMode && this._actualDisharmony > Organism.STRESS_THRESHOLD_LEAVE) {
        return this._inStressMode = false;
      }
    };

    Organism.prototype.getDisharmonyHistoryData = function(numEntries) {
      if (numEntries == null) {
        numEntries = 300;
      }
      if (numEntries > 0) {
        return this.disharmonyHistory.slice(-numEntries);
      } else {
        return this.disharmonyHistory.slice(-this.disharmonyHistory.length);
      }
    };

    Organism.prototype._createNodes = function(numNodes) {
      var cell, factor, i, node, nodes, nodesWithFactorCells, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _len5, _m, _n, _ref, _ref1, _ref2, _results, _results1;
      this._nodeCellIndex = [];
      _ref = this._factors;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        factor = _ref[_i];
        this._nodeCellIndex[factor.factorType] = [];
      }
      nodes = (function() {
        var _j, _results;
        _results = [];
        for (i = _j = 1; 1 <= numNodes ? _j <= numNodes : _j >= numNodes; i = 1 <= numNodes ? ++_j : --_j) {
          _results.push(new Node());
        }
        return _results;
      })();
      this._nodes = [];
      for (_j = 0, _len1 = nodes.length; _j < _len1; _j++) {
        node = nodes[_j];
        this._nodes[node.nodeId] = node;
      }
      for (_k = 0, _len2 = nodes.length; _k < _len2; _k++) {
        node = nodes[_k];
        _ref1 = node.getCells();
        for (_l = 0, _len3 = _ref1.length; _l < _len3; _l++) {
          cell = _ref1[_l];
          this._nodeCellIndex[cell.factorType].push(node);
        }
      }
      if (Organism.DISTRIBUTE_FACTOR_VALUES) {
        _ref2 = this._factors;
        _results = [];
        for (_m = 0, _len4 = _ref2.length; _m < _len4; _m++) {
          factor = _ref2[_m];
          nodesWithFactorCells = this.getNodesWithCellsOfFactorType(factor.factorType);
          _results.push((function() {
            var _n, _ref3, _results1;
            _results1 = [];
            for (i = _n = 1, _ref3 = factor.factorValue; 1 <= _ref3 ? _n <= _ref3 : _n >= _ref3; i = 1 <= _ref3 ? ++_n : --_n) {
              _results1.push(getRandomElements(nodesWithFactorCells, 1)[0].addCellValue(factor.factorType, 1));
            }
            return _results1;
          })());
        }
        return _results;
      } else {
        _results1 = [];
        for (_n = 0, _len5 = nodes.length; _n < _len5; _n++) {
          node = nodes[_n];
          _results1.push((function() {
            var _len6, _o, _ref3, _results2;
            _ref3 = node.getCells();
            _results2 = [];
            for (_o = 0, _len6 = _ref3.length; _o < _len6; _o++) {
              cell = _ref3[_o];
              _results2.push(cell.factorValue = Math.randomRange(0, 100));
            }
            return _results2;
          })());
        }
        return _results1;
      }
    };

    Organism.prototype._getRandomNodes = function(numNodes) {
      var allNodeIndexes, i, nodeIndexes, _i, _j, _len, _ref, _results, _results1;
      allNodeIndexes = (function() {
        _results = [];
        for (var _i = 0, _ref = this._nodes.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; 0 <= _ref ? _i++ : _i--){ _results.push(_i); }
        return _results;
      }).apply(this);
      nodeIndexes = (function() {
        var _j, _results1;
        _results1 = [];
        for (i = _j = 1; 1 <= numNodes ? _j <= numNodes : _j >= numNodes; i = 1 <= numNodes ? ++_j : --_j) {
          _results1.push(allNodeIndexes.splice(Math.floor(Math.random() * allNodeIndexes.length), 1));
        }
        return _results1;
      })();
      _results1 = [];
      for (_j = 0, _len = nodeIndexes.length; _j < _len; _j++) {
        i = nodeIndexes[_j];
        _results1.push(this._nodes[i]);
      }
      return _results1;
    };

    Organism.prototype._getRandomNodesOfFactorType = function(factorType, numNodes) {
      return getRandomElements(this._nodeCellIndex[factorType], numNodes);
    };

    return Organism;

  })();

  window.Organism = Organism;

}).call(this);
