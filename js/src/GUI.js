// Generated by CoffeeScript 1.4.0

/*
	GUI super class
*/


(function() {
  var GUI;

  GUI = (function() {

    function GUI() {
      var _this = this;
      this.$factorsWrap = $('#factors');
      this.$nodesWrap = $('#nodes');
      this.$meter = $('#disharmony-meter .value');
      this._renderedFactors = false;
      this._renderedNodes = false;
      this._setupControls();
      if (typeof google !== "undefined" && google !== null) {
        google.setOnLoadCallback(function() {
          _this.$disharmonyChart = $("#disharmony-chart");
          return _this.disharmonyChart = new google.visualization.LineChart(_this.$disharmonyChart.get(0));
        });
      }
    }

    GUI.prototype._setupControls = function() {
      var _this = this;
      return $('#controls .btn').click(function(e) {
        return $(document).trigger("dm" + ($(e.currentTarget).attr('href').replace("#", "")));
      });
    };

    GUI.prototype.update = function(factors, nodes, tableData) {
      this._updateFactors(factors);
      this._updateNodes(nodes);
      this._drawCharts(tableData);
      if (tableData.length > 0) {
        return this.$meter.html("" + (Math.round(tableData[tableData.length - 1][2])) + "<br /><small style='font-weight:normal;'>" + (Math.round(tableData[tableData.length - 1][1])) + "</small>");
      }
    };

    GUI.prototype._drawCharts = function(tableData) {
      var data, options;
      return;
      if (!(this.disharmonyChart != null)) {
        return;
      }
      tableData.unshift(['Iteration', 'Sum dish.', 'Actual dish.']);
      data = google.visualization.arrayToDataTable(tableData);
      options = {
        title: 'Disharmony chart',
        vAxis: {
          viewWindowMode: 'explicit',
          viewWindow: {
            min: 0
          }
        }
      };
      return this.disharmonyChart.draw(data, options);
    };

    GUI.prototype._updateFactors = function(factors) {
      var factor, _i, _len, _results;
      if (!this._renderedFactors) {
        return this._buildFactors(factors);
      } else {
        _results = [];
        for (_i = 0, _len = factors.length; _i < _len; _i++) {
          factor = factors[_i];
          _results.push($(".factor[data-factor-type='" + factor.factorType + "']").attr('data-factor-disharmony', factor.disharmony).attr('data-factor-name', factor.name).find('.factor-value').html(factor.factorValue));
        }
        return _results;
      }
    };

    GUI.prototype._buildFactors = function(factors) {
      var factor, factorsHtml;
      factorsHtml = ((function() {
        var _i, _len, _results;
        _results = [];
        for (_i = 0, _len = factors.length; _i < _len; _i++) {
          factor = factors[_i];
          _results.push("<div class=\"factor\" data-factor-type=\"" + factor.factorType + "\"><span class=\"factor-name\">" + factor.name + "</span> <span class=\"factor-value\">" + factor.factorValue + "</span></div>");
        }
        return _results;
      })()).join("");
      this.$factorsWrap.html(factorsHtml);
      return this._renderedFactors = true;
    };

    GUI.prototype._updateNodes = function(nodes) {
      var $node, cell, node, _i, _len, _results;
      if (!this._renderedNodes) {
        return this._buildNodes(nodes);
      } else {
        _results = [];
        for (_i = 0, _len = nodes.length; _i < _len; _i++) {
          node = nodes[_i];
          $node = this.$nodesWrap.find(".node[data-node-id=" + node.nodeId + "]");
          _results.push((function() {
            var _j, _len1, _ref, _results1;
            _ref = node.getCells();
            _results1 = [];
            for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
              cell = _ref[_j];
              _results1.push($node.find(".node-cell[data-cell-factor='" + cell.factorType + "']").html(cell.factorValue));
            }
            return _results1;
          })());
        }
        return _results;
      }
    };

    GUI.prototype._buildNodes = function(nodes) {
      var cell, cellsHtml, node, nodeHtml, _i, _len;
      for (_i = 0, _len = nodes.length; _i < _len; _i++) {
        node = nodes[_i];
        cellsHtml = ((function() {
          var _j, _len1, _ref, _results;
          _ref = node.getCells();
          _results = [];
          for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
            cell = _ref[_j];
            _results.push("<li class=\"node-cell\" data-cell-factor=\"" + cell.factorType + "\">" + cell.factorValue + "</li>");
          }
          return _results;
        })()).join("");
        cellsHtml = "<ul class=\"node-cells\">" + cellsHtml + "</ul>";
        nodeHtml = "<div class=\"node\" data-node-id=\"" + node.nodeId + "\">" + cellsHtml + "</div>";
        this.$nodesWrap.append(nodeHtml);
      }
      return this._renderedNodes = true;
    };

    return GUI;

  })();

  window.GUI = GUI;

}).call(this);
