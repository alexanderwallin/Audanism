###
	Listens for weather.
###
class WheatherSourceAdapter extends Audanism.SourceAdapter.SourceAdapter

	# Constructor
	constructor: (@interval = 5000) ->
		super('weather', @interval)

		# Query params
		@queryUrl = "http://www.yr.no/place/%s/%s/%s/forecast.xml"

		# Ajax handler
		@jqxhr = null

		# Interval
		@queryInterval

		# List of towns
		@towns = null


	# Sets up mouse event listeners
	activate: () ->
		@active = true

		@queryInterval = setInterval () =>
			@queryWeather()
		, @interval


	# Deactivate
	deactive: () ->
		@active = false

		clearInterval( @queryInterval )


	# Fetches a list of towns
	fetchTowns: () ->
		$.ajax({
			url: '/js/data/yr-capitals.json',
			dataType: 'json'
			success: (response) =>
				@towns = response
			error: (error) ->
				console.error(error)
		});


	# Returns a town from the list of towns
	getATown: () ->
		if @towns
			return @towns[ randomInt(0, @towns.length - 1) ]
		
		return null


	# Performs a query for photos
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
	

	# Process photos
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
