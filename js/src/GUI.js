// Generated by CoffeeScript 1.4.0

/*
	GUI super class
*/


(function() {
  var GUI,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  GUI = (function() {

    function GUI() {
      this._setWikiContent = __bind(this._setWikiContent, this);
      this.$organismStats = $('#organism-stats');
      this.$factorStats = $('#factor-stats');
      this.$influences = $('#influences');
      this.$influenceTemplate = this.$influences.find('.template').clone(true).removeClass('template');
      this.$influences.find('.template').hide();
      this.$wiki = $('#wiki');
      this._setupControls();
      this._setupWiki();
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
        return EventDispatcher.trigger('audanism/controls/' + $(e.currentTarget).attr('href').replace("#", ""));
      });
      EventDispatcher.listen('audanism/controls/start', this, function() {
        return $('body').removeClass('paused').addClass('running');
      });
      return EventDispatcher.listen('audanism/controls/pause audanism/controls/stop', this, function() {
        return $('body').removeClass('running').addClass('paused');
      });
    };

    GUI.prototype._setupWiki = function() {
      var _this = this;
      $('#wiki').fadeTo(2000, 1.0);
      $(document).on('click', '#intro-btn-start', function(e) {
        e.preventDefault();
        EventDispatcher.trigger('audanism/controls/start');
        return _this.$wiki.fadeOut(500, function() {
          return $('#intro-btn-start').html('Resume');
        });
      });
      $(document).on('click', '[data-target-tab]', function(e) {
        e.preventDefault();
        return _this._setWikiContent($(e.currentTarget).attr('data-target-tab'));
      });
      return $(document).on('click', '[data-toggle-wiki]', function(e) {
        var action;
        e.preventDefault();
        action = $(e.currentTarget).attr('data-toggle-wiki');
        if (action === 'show') {
          return _this.$wiki.fadeIn(500);
        } else {
          return _this.$wiki.fadeOut(500);
        }
      });
    };

    GUI.prototype._setWikiContent = function(tabIndex) {
      if (!this.$wiki.is(':visible')) {
        this.$wiki.fadeIn(500);
      }
      $('.tab-content').removeClass('active').filter("[data-tab='" + tabIndex + "']").addClass('active');
      return this.$wiki.find('a[data-target-tab]').removeClass('active').filter("[data-target-tab='" + tabIndex + "']").addClass('active');
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
        case 5:
        case 6:
        case 7:
          showSelector = 'early-morning';
          break;
        case 8:
        case 9:
        case 10:
          showSelector = 'morning';
          break;
        case 11:
        case 12:
        case 13:
          showSelector = 'midday';
          break;
        case 14:
        case 15:
        case 16:
        case 17:
          showSelector = 'afternoon';
          break;
        case 18:
        case 19:
        case 20:
        case 21:
        case 22:
          showSelector = 'evening';
      }
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
