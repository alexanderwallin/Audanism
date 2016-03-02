// Generated by CoffeeScript 1.10.0

/*
	NodeCell

	A node cell has a factor type and a value.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
 */

(function() {
  var NodeCell;

  NodeCell = (function() {
    NodeCell.prototype.clone = function() {
      return new Audanism.Node.NodeCell(this.factorType, this.factorValue);
    };

    function NodeCell(factorType, factorValue) {
      this.factorType = factorType;
      this.factorValue = factorValue;
    }

    NodeCell.prototype.addFactorValue = function(value) {
      this.factorValue += value;
      if (this.factorValue < 0) {
        this.factorValue = 0;
      }
      if (this.factorValue > 100) {
        return this.factorValue = 100;
      }
    };

    return NodeCell;

  })();

  window.Audanism.Node.NodeCell = NodeCell;

}).call(this);
