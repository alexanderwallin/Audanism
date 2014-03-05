// Generated by CoffeeScript 1.4.0

/*
	Environment
*/


(function() {
  var Environment;

  Environment = (function() {

    Environment.NUM_ORGANISMS = 1;

    Environment.TIME_INTERVAL = 800;

    function Environment() {
      var i;
      this._iterationCount = 0;
      this._isRunning = true;
      this._isSingleStep = true;
      this.visualOrganism = new Audanism.Graphic.VisualOrganism();
      this._organisms = (function() {
        var _i, _ref, _results;
        _results = [];
        for (i = _i = 1, _ref = Environment.NUM_ORGANISMS; 1 <= _ref ? _i <= _ref : _i >= _ref; i = 1 <= _ref ? ++_i : --_i) {
          _results.push(new Audanism.Environment.Organism);
        }
        return _results;
      })();
      EventDispatcher.trigger('audanism/init/organism', [this._organisms[0]]);
      this._gui = new Audanism.GUI.GUI;
      this.listenToControls();
      this.createInfluenceSources();
      EventDispatcher.listen('audanism/influence', this, this.influence);
      this.initConductor();
      this.run();
    }

    Environment.prototype.run = function() {
      var _this = this;
      this.start();
      this._intervalId = setInterval(function() {
        return _this.handleIteration();
      }, Environment.TIME_INTERVAL);
      return this.handleIteration();
    };

    Environment.prototype.start = function() {
      var sourceAdapter, _i, _len, _ref, _results;
      this._isRunning = true;
      _ref = this._influenceSources;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        sourceAdapter = _ref[_i];
        _results.push(sourceAdapter.activate());
      }
      return _results;
    };

    Environment.prototype.pause = function() {
      var source, _i, _len, _ref, _results;
      this._isRunning = false;
      _ref = this._influenceSources;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        source = _ref[_i];
        _results.push(source.deactivate());
      }
      return _results;
    };

    Environment.prototype.stop = function() {
      this._isRunning = false;
      return clearInterval(this._intervalId);
    };

    Environment.prototype.step = function() {
      return this._isSingleStep = true;
    };

    Environment.prototype.listenToControls = function() {
      var _this = this;
      $(document).on('dmstart', function(e) {
        return _this.start();
      });
      $(document).on('dmpause', function(e) {
        return _this.pause();
      });
      $(document).on('dmstop', function(e) {
        return _this.stop();
      });
      return $(document).on('dmstep', function(e) {
        return _this.step();
      });
    };

    Environment.prototype.handleIteration = function() {
      var organism, _i, _len, _ref, _results;
      this._iterationCount++;
      if (this._isRunning || this._isSingleStep) {
        if ((this.conductor != null) && this.conductor.isMuted) {
          this.conductor.unmute();
        }
        _ref = this._organisms;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          organism = _ref[_i];
          organism.performNodeComparison();
          if (this._iterationCount % 10 === 0) {
            EventDispatcher.trigger('audanism/node/add', {
              'numNodes': 1
            });
          }
          EventDispatcher.trigger('audanism/iteration', [
            {
              'count': this._iterationCount,
              'organism': organism
            }
          ]);
          _results.push(this._isSingleStep = false);
        }
        return _results;
      } else {
        if ((this.conductor != null) && !this.conductor.isMuted) {
          return this.conductor.mute();
        }
      }
    };

    Environment.prototype.createInfluenceSources = function() {
      this._influenceSources = [];
      this._influenceSources.push(new Audanism.SourceAdapter.InstagramSourceAdapter(this));
      return this._influenceSources.push(new Audanism.SourceAdapter.WheatherSourceAdapter());
    };

    Environment.prototype.influence = function(influenceData) {
      var argNum, argVal, cell, factor, factorType, factors, influenceInfo, node, nodes, num, numType, organism, type, valType, valueMod, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _results, _results1;
      if (!this._isRunning) {
        return;
      }
      if (influenceData.node != null) {
        _ref = this._organisms;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          organism = _ref[_i];
          factor = influenceData.node.factor === 'rand' ? getRandomElements(organism.getFactors()) : organism.getFactorOfType(influenceData.node.factor);
          node = influenceData.node.node === 'rand' ? organism._getRandomNodesOfFactorType(factor.factorType, 1)[0] : organism.getNode(influenceData.node.node);
          influenceInfo = {
            'node': {
              'node': node,
              'factor': factor,
              'value': influenceData.node.valueModifier
            },
            'meta': influenceData.meta
          };
          EventDispatcher.trigger('audanism/influence/node', [influenceInfo]);
          node.addCellValue(factor.factorType, influenceData.node.valueModifier);
          EventDispatcher.trigger('audanism/influence/node/after', [influenceInfo]);
        }
      }
      if (influenceData.factor != null) {
        _ref1 = this._organisms;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          organism = _ref1[_j];
          factor;

          if (influenceData.factor.factor === 'rand') {
            factorType = randomInt(1, Audanism.Environment.Organism.NUM_FACTORS);
            factor = organism.getFactorOfType(factorType);
          }
          if (factor) {
            influenceInfo = {
              'factor': {
                'factor': factor,
                'value': influenceData.factor.valueModifier
              },
              'meta': influenceData.meta
            };
            EventDispatcher.trigger('audanism/influence/factor', influenceInfo);
            factor.addValue(influenceData.factor.valueModifier);
            EventDispatcher.trigger('audanism/influence/factor/after', influenceInfo);
          }
        }
      }
      if (influenceData.random != null) {
        type = influenceData.random['object'];
        argNum = influenceData.random.num;
        argVal = influenceData.random.valueModifier;
        num = 0;
        valueMod = -1;
        numType = typeof argNum;
        if (numType === 'integer') {
          num = argNum;
        } else if (numType === 'array') {
          num = Math.randomRange(argNum[1], argNum[0]);
        } else if (numType === 'string' && argNum === 'rand') {
          num = Math.randomRange(type === 'factor' ? 1 : 5);
        }
        if (type === 'factor') {
          _ref2 = this._organisms;
          _results = [];
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            organism = _ref2[_k];
            factors = getRandomElements(organism.getFactors(), num);
            _results.push((function() {
              var _l, _len3, _results1;
              _results1 = [];
              for (_l = 0, _len3 = factors.length; _l < _len3; _l++) {
                factor = factors[_l];
                valType = typeof argVal;
                if (valType === 'integer') {
                  valueMod = argVal;
                } else if (valType === 'array') {
                  valueMod = Math.randomRange(argVal[1], argVal[0]);
                } else if (valType === 'string' && argVal === 'rand') {
                  valueMod = Math.randomRange(5, -5);
                }
                _results1.push(organism.getFactorOfType(factor.factorType).addValue(valueMod));
              }
              return _results1;
            })());
          }
          return _results;
        } else if (type === 'node') {
          _ref3 = this._organisms;
          _results1 = [];
          for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
            organism = _ref3[_l];
            nodes = getRandomElements(organism.getNodes(), num);
            _results1.push((function() {
              var _len4, _m, _results2;
              _results2 = [];
              for (_m = 0, _len4 = nodes.length; _m < _len4; _m++) {
                node = nodes[_m];
                valType = typeof argVal;
                if (valType === 'integer') {
                  valueMod = argVal;
                } else if (valType === 'array') {
                  valueMod = Math.randomRange(argVal[1], argVal[0]);
                } else if (valType === 'string' && argVal === 'rand') {
                  valueMod = Math.randomRange(50, -50);
                }
                cell = getRandomElements(node.getCells(), 1)[0];
                _results2.push(cell.addFactorValue(valueMod));
              }
              return _results2;
            })());
          }
          return _results1;
        }
      }
    };

    Environment.prototype.initConductor = function() {
      this.conductor = new Audanism.Audio.Conductor();
      this.conductor.setOrganism(this._organisms[0]);
      return this.conductor.mute();
      /*
      		$spectrum = $('<div id="spectrum" />').css({
      			'position': 'fixed'
      			'left': 0
      			'right': 0
      			'top': 0
      			'bottom': 0
      			'z-index': 9999
      			#'height': window.innerHeight
      		}).appendTo($('#container'))
      
      		for i in [0..@conductor.analyser.frequencyBinCount-1]
      			dLeft = i / @conductor.analyser.frequencyBinCount
      			dWidth = Math.round( $(window).width() / @conductor.analyser.frequencyBinCount )
      
      			$spectrum.append($('<div />').attr('id', 'bar-' + i).css({
      				'position': 'absolute', 
      				'top': 0, 
      				'left': i * dWidth + 1
      				'width': dWidth - 2
      				'height': 10
      				'background-color': 'red'
      			}))
      
      		EventDispatcher.listen 'audanism/iteration', @, (frame) =>
      			console.log('adjust freq bars')
      			frequencyData = @conductor.getFrequencyData()
      			#console.log(frequencyData.join(' | '))
      
      			i = -1
      
      			for freqData in frequencyData
      				i++
      				console.log(freqData)
      
      				if i is 0
      					console.log( $('#bar-' + i) )
      
      				$('#bar-' + i).css('height', 10 + Math.round(freqData))
      */

    };

    return Environment;

  })();

  window.Audanism.Environment.Environment = Environment;

}).call(this);
