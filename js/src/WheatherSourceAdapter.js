// Generated by CoffeeScript 1.4.0

/*
	Listens for weather.
*/


(function() {
  var WheatherSourceAdapter,
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  WheatherSourceAdapter = (function(_super) {

    __extends(WheatherSourceAdapter, _super);

    function WheatherSourceAdapter(interval) {
      this.interval = interval != null ? interval : 5000;
      WheatherSourceAdapter.__super__.constructor.call(this, 'weather', this.interval);
      this.queryUrl = "http://www.yr.no/place/%s/%s/%s/forecast.xml";
      this.jqxhr = null;
      this.queryInterval;
      this.towns = null;
    }

    WheatherSourceAdapter.prototype.activate = function() {
      var _this = this;
      this.active = true;
      return this.queryInterval = setInterval(function() {
        return _this.queryWeather();
      }, this.interval);
    };

    WheatherSourceAdapter.prototype.deactive = function() {
      this.active = false;
      return clearInterval(this.queryInterval);
    };

    WheatherSourceAdapter.prototype.fetchTowns = function() {
      var _this = this;
      return $.ajax({
        url: '/js/data/yr-capitals.json',
        dataType: 'json',
        success: function(response) {
          return _this.towns = response;
        },
        error: function(error) {
          return console.error(error);
        }
      });
    };

    WheatherSourceAdapter.prototype.getATown = function() {
      if (this.towns) {
        return this.towns[randomInt(0, this.towns.length - 1)];
      }
      return null;
    };

    WheatherSourceAdapter.prototype.queryWeather = function() {
      var _this = this;
      if (this.jqxhr || !this.active) {
        return;
      }
      return this.jqxhr = $.ajax({
        dataType: 'xml',
        type: 'get',
        url: '/ajax/town-weather.php',
        data: {},
        success: function(response) {
          _this.processWeather(response);
          return _this.jqxhr = null;
        },
        error: function(error) {
          return _this.jqxhr = null;
        }
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
      EventDispatcher.trigger('audanism/influence', influenceData);
      return EventDispatcher.trigger('audanism/influence/factor/done', [[influenceData]]);
    };

    return WheatherSourceAdapter;

  })(Audanism.SourceAdapter.SourceAdapter);

  window.Audanism.SourceAdapter.WheatherSourceAdapter = WheatherSourceAdapter;

}).call(this);
