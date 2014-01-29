###
	Listens for Instagram pictures.
###
class InstagramSourceAdapter extends SourceAdapter

	# Constructor
	constructor: (@listener) ->
		super(@listener)

		@clientId = "f42a4ce0632e412ea5a0353c2b5e581f"
		@photoSinceId = 0

		@tag = "belieber"
		@queryUrl = "http://api.instagram.com/v1/tags/belieber/media/recent?client_id=#{ @clientId }"

	# Sets up mouse event listeners
	activate: () ->
		console.log('ISA activate')

		_this = @
		_queryPhotos = @queryPhotos

		setInterval () =>
			@queryPhotos.call _this
		, 10000

	# Performs a query for photos
	queryPhotos: () ->
		console.log('query instagram photots', @queryUrl)

		$.get @queryUrl, (data) =>
			console.log 'instagram data', data


	# Adapts the mouse data into environment interpretable data
	adaptSourceData: () ->


window.InstagramSourceAdapter = InstagramSourceAdapter 