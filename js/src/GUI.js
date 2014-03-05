// Generated by CoffeeScript 1.4.0

/*
	GUI super class
*/


(function() {
  var GUI;

  GUI = (function() {

    function GUI() {
      this.$organismStats = $('#organism-stats');
      this.$factorStats = $('#factor-stats');
      this.$influences = $('#influences');
      this.$influenceTemplate = this.$influences.find('.template').clone(true).removeClass('template');
      this.$influences.find('.template').hide();
      this._renderedFactors = false;
      this._renderedNodes = false;
      this._setupControls();
      this._showCozyInfo();
      EventDispatcher.listen('audanism/iteration', this, this.onIteration);
      EventDispatcher.listen('audanism/influence/node/done', this, this.onInfluenceNodeDone);
      EventDispatcher.listen('audanism/influence/factor/after', this, this.onInfluenceFactorAfter);
      EventDispatcher.listen('audanism/organism/stressmode', this, this.onStressModeChange);
      /*
      		if google?
      			google.setOnLoadCallback =>
      				@$disharmonyChart = $("#disharmony-chart")
      				@disharmonyChart = new google.visualization.LineChart @$disharmonyChart.get 0;
      				#console.log 'google.setOnLoadCallback', @disharmonyChart
      */

    }

    GUI.prototype._setupControls = function() {
      var _this = this;
      $('#controls .btn').click(function(e) {
        e.preventDefault();
        return $(document).trigger("dm" + ($(e.currentTarget).attr('href').replace("#", "")));
      });
      $(document).on('dmstart', function(e) {
        return $('body').removeClass('paused').addClass('running');
      });
      return $(document).on('dmpause', function(e) {
        return $('body').removeClass('running').addClass('paused');
      });
    };

    GUI.prototype._showCozyInfo = function() {
      var hour, showSelector;
      hour = new Date().getHours();
      showSelector = '';
      switch (hour) {
        case 23:
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
          showSelector = 'night';
          break;
        case 6:
        case 7:
        case 8:
          showSelector = 'early-morning';
          break;
        case 9:
        case 10:
        case 11:
          showSelector = 'morning';
          break;
        case 12:
        case 13:
        case 14:
        case 15:
          showSelector = 'midday';
          break;
        case 16:
        case 17:
        case 18:
        case 19:
          showSelector = 'afternoon';
          break;
        case 20:
        case 21:
        case 22:
          showSelector = 'evening';
      }
      console.log(showSelector);
      return $('.time-of-day').filter('.' + showSelector).show();
    };

    GUI.prototype.onIteration = function(iterationInfo) {
      var $factorDish, $factorValues, disharmony, factor, organism, _i, _len, _ref, _results;
      organism = iterationInfo.organism;
      disharmony = organism.getDisharmonyHistoryData(1);
      this.$organismStats.find('#summed-disharmony .value').html(Math.round(organism._sumDisharmony)).end().find('#actual-disharmony .value').html(Math.round(organism._actualDisharmony)).end();
      $factorValues = this.$factorStats.find('#factor-values');
      $factorDish = this.$factorStats.find('#factor-disharmonies');
      _ref = organism.getFactors();
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        factor = _ref[_i];
        $factorValues.find('[data-factor="' + factor.factorType + '"]').html(decimalAdjust('round', factor.factorValue, -1));
        _results.push($factorDish.find('[data-factor="' + factor.factorType + '"]').html(numberSuffixed(factor.disharmony, -1)));
      }
      return _results;
    };

    GUI.prototype.onInfluenceNodeDone = function(influenceInfoList) {
      influenceBoxInfo;

      var influenceBoxInfo, influenceEntry, photo;
      influenceEntry = influenceInfoList[0];
      if (influenceEntry.meta.source === 'instagram') {
        photo = influenceEntry.meta.sourceData;
        influenceBoxInfo = {
          'source': influenceEntry.meta.source,
          'summary': '<img src="' + photo.images.thumbnail.url + '" /><span class="caption">' + photo.caption.text.substring(0, 30) + '</span>',
          'url': photo.link,
          'type': 'Nodes',
          'value': null
        };
      }
      if (influenceBoxInfo) {
        return this.appendInfluenceBox(influenceBoxInfo);
      }
    };

    GUI.prototype.onInfluenceFactorAfter = function(influenceInfo) {
      influenceBoxInfo;

      var influenceBoxInfo;
      if (influenceInfo.meta.source = 'yr.no') {
        influenceBoxInfo = {
          'source': influenceInfo.meta.source,
          'summary': influenceInfo.meta.summary,
          'type': 'Factor ' + influenceInfo.factor.factor.factorType
        };
      }
      if (influenceBoxInfo) {
        return this.appendInfluenceBox(influenceBoxInfo);
      }
    };

    GUI.prototype.appendInfluenceBox = function(influenceBoxInfo) {
      var $box, $boxes, numBoxes;
      $box = this.$influenceTemplate.clone();
      $box.find('.influence-source').html(influenceBoxInfo.source);
      $box.find('.influence-summary').html(influenceBoxInfo.summary);
      $box.find('.influence-link').html($('<a />', {
        'href': influenceBoxInfo.url
      }).html('Link'));
      $box.find('.influence-type').html(influenceBoxInfo.type);
      $box.find('.influence-value').html(influenceBoxInfo.value || '');
      this.$influences.append($box);
      $box.show();
      $boxes = this.$influences.find('.influence');
      numBoxes = $boxes.size();
      if (numBoxes > 6) {
        return this.$influences.find('.influence').filter(function() {
          return $boxes.index(this) < numBoxes - 6;
        }).hide();
      }
    };

    GUI.prototype.onStressModeChange = function(stressMode) {
      return this.$organismStats.find('.stress-mode-indicator').toggleClass('stressed', stressMode);
    };

    return GUI;

  })();

  window.Audanism.GUI.GUI = GUI;

}).call(this);
