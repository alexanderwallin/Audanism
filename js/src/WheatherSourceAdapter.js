// Generated by CoffeeScript 1.10.0

/*
	WheatherSourceAdapter

	Sends requests for weather forecasts and triggers influence events
	when it recieves them.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
 */

(function() {
  var WheatherSourceAdapter,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  WheatherSourceAdapter = (function(superClass) {
    extend(WheatherSourceAdapter, superClass);

    function WheatherSourceAdapter(interval) {
      this.interval = interval != null ? interval : 5000;
      WheatherSourceAdapter.__super__.constructor.call(this, 'weather', this.interval);
      this.queryUrl = "http://www.yr.no/place/%s/%s/%s/forecast.xml";
      this.jqxhr = null;
      this.queryInterval;
    }

    WheatherSourceAdapter.prototype.activate = function() {
      this.active = true;
      return this.queryInterval = setInterval((function(_this) {
        return function() {
          return _this.queryWeather();
        };
      })(this), this.interval);
    };

    WheatherSourceAdapter.prototype.deactive = function() {
      this.active = false;
      return clearInterval(this.queryInterval);
    };

    WheatherSourceAdapter.prototype.queryWeather = function() {
      if (this.jqxhr || !this.active) {
        return;
      }
      return this.jqxhr = $.ajax({
        dataType: 'xml',
        type: 'get',
        url: '/ajax/town-weather.php',
        data: {},
        success: (function(_this) {
          return function(response) {
            _this.processWeather(response);
            return _this.jqxhr = null;
          };
        })(this),
        error: (function(_this) {
          return function(error) {
            return _this.jqxhr = null;
          };
        })(this)
      });
    };

    WheatherSourceAdapter.prototype.processWeather = function(townWeather) {
      var $nextForecast, $xml, influenceData, temperature, windSpeed;
      $xml = $(townWeather);
      $nextForecast = $xml.find('tabular time[period="0"]');
      influenceData = {
        'factor': {
          'factor': 'rand'
        },
        'meta': {
          'current': 1,
          'total': 1,
          'source': this.sourceId,
          'sourceData': townWeather
        }
      };
      switch (randomInt(0, 1)) {
        case 0:
          windSpeed = parseFloat($nextForecast.find('windSpeed').attr('mps'));
          influenceData.factor.valueModifier = randomInt(0, 1) === 1 ? windSpeed : -windSpeed;
          influenceData.meta.sourceAttr = 'wind';
          influenceData.meta.summary = 'Wind blowing at ' + windSpeed + ' mps in ' + $xml.find('location name').text();
          break;
        case 1:
          temperature = parseFloat($nextForecast.find('temperature').attr('value'));
          influenceData.factor.valueModifier = 10 * (temperature - 10) / 60;
          influenceData.meta.sourceAttr = 'temperature';
          influenceData.meta.summary = "It's around " + temperature + "°C in " + $xml.find('location name').text();
      }
      if (townWeather && influenceData.factor.valueModifier) {
        EventDispatcher.trigger('audanism/influence', influenceData);
        return EventDispatcher.trigger('audanism/influence/factor/done', [[influenceData]]);
      }
    };

    return WheatherSourceAdapter;

  })(Audanism.SourceAdapter.SourceAdapter);

  window.Audanism.SourceAdapter.WheatherSourceAdapter = WheatherSourceAdapter;

}).call(this);
