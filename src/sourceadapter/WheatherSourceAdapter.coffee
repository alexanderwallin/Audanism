###
	WheatherSourceAdapter

	Sends requests for weather forecasts and triggers influence events
	when it recieves them.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
###
class WheatherSourceAdapter extends Audanism.SourceAdapter.SourceAdapter

	#
	# Constructor
	#
	constructor: (@interval = 5000) ->
		super('weather', @interval)

		# Query params
		@queryUrl = "http://www.yr.no/place/%s/%s/%s/forecast.xml"

		# Ajax handler
		@jqxhr = null

		# Interval
		@queryInterval

	#
	# Sets up mouse event listeners
	#
	activate: () ->
		@active = true

		@queryInterval = setInterval () =>
			@queryWeather()
		, @interval

	#
	# Deactivate
	#
	deactive: () ->
		@active = false

		clearInterval( @queryInterval )

	#
	# Performs a query for wheater data
	#
	queryWeather: () ->
		#console.log('••• query wheather •••', @jqxhr)

		# Abort if an ongoing request is not ready
		if @jqxhr or not @active
			return

		# Make ajax call
		@jqxhr = $.ajax {
			dataType: 'xml'
			type:     'get'
			url:      '/ajax/town-weather.php' #townInfo.slice( -1 )
			data:     {}
			success: (response) =>
				@processWeather response
				@jqxhr = null
			error: (error) =>
				#console.log('An error occurred while fetching weather data:', error)
				@jqxhr = null
		}
	
	#
	# Process wheather data and trigger influence event
	#
	processWeather: (townWeather) ->
		#console.log('••• parse wheather •••', townWeather)

		# Parse XML
		$xml   = $( townWeather )
		$nextForecast = $xml.find('tabular time[period="0"]')

		# Info object
		influenceData = {
			'factor': {
				'factor':        'rand'
				#'valueModifier': ''
			},
			'meta': {
				'current':       1
				'total':         1
				'source':        @sourceId
				'sourceData':    townWeather
				#'summary':      ''
			}
		}

		switch randomInt(0, 1)
			
			# Wind
			when 0
				windSpeed = parseFloat( $nextForecast.find('windSpeed').attr('mps') )
				influenceData.factor.valueModifier = if randomInt(0, 1) is 1 then windSpeed else -windSpeed
				influenceData.meta.sourceAttr      = 'wind'
				influenceData.meta.summary         = 'Wind blowing at ' + windSpeed + ' mps in ' + $xml.find('location name').text()

			# Temperature
			when 1
				temperature = parseFloat( $nextForecast.find('temperature').attr('value') )
				influenceData.factor.valueModifier = 10 * (temperature - 10) / 60
				influenceData.meta.sourceAttr      = 'temperature'
				influenceData.meta.summary         = "It's around " + temperature + "°C in " + $xml.find('location name').text()


		# Trigger influence
		EventDispatcher.trigger 'audanism/influence', influenceData
		EventDispatcher.trigger 'audanism/influence/factor/done', [[influenceData]]


window.Audanism.SourceAdapter.WheatherSourceAdapter = WheatherSourceAdapter
