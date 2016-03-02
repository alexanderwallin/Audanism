###
	InstagramSourceAdapter

	Listens for Instagram pictures on a given tag. When a new picture
	is fetched, the InstagramSourceAdapter spits out an influence 
	event with information about the picture.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
###
class InstagramSourceAdapter extends Audanism.SourceAdapter.SourceAdapter

	#
	# Constructor
	#
	constructor: (@interval = 5000, @tag = 'audanism') ->
		super('instagram', @interval)

		# Query params
		@clientId     = "f42a4ce0632e412ea5a0353c2b5e581f"
		@photoSinceId = 0
		#@tag          = if window.location.hash.match(/instatag=\w+/) then window.location.hash.replace(/^#instatag=([^&]+)$/, "$1") || "art" else "art"
		@queryUrl     = "https://api.instagram.com/v1/tags/#{ @tag }/media/recent"

		# Ajax handler
		@jqxhr        = null

	#
	# Starts the query interval
	#
	activate: () ->
		@active = true

		@queryInterval = setInterval () =>
			@queryPhotos()
		, @interval

		#@queryPhotos()

	#
	# Deactivates the listener
	#
	deactive: () ->
		@active = false

		clearInterval( @queryInterval )

	#
	# Performs a query for photos
	#
	queryPhotos: () ->
		#console.log('••• query instagram photots', @queryUrl, '•••')

		if @jqxhr or not @active
			return

		# Create a request
		@jqxhr = $.ajax {
			dataType: 'jsonp',
			url: @queryUrl, 
			data: {
				client_id: @clientId,
				count: 1,
				max_id: @photoSinceId
			},
			success: (response) =>
				#console.log('did fetch data', response)
				@processPhotos response.data
		}
	
	#
	# Processes a set of photos
	#
	processPhotos: (photos) ->
		interpreter = new Audanism.Util.TextInterpreter

		influenceDataList = []

		for photo in photos

			# Store since id
			if (photo.id is @photoSinceId)
				continue

			@photoSinceId = photo.id

			# Get caption
			if (!photo.caption)
				continue

			caption = photo.caption.text

			# Get values
			captionVals = interpreter.getNumCharsInGroups caption, 5

			# Trigger alteration
			for i in [0..captionVals.length-1]

				if not captionVals[i]
					continue

				modVal = Math.round captionVals[i] * 20
				modVal = if Math.random() >= 0.5 then -modVal else modVal

				influenceData = {
					'node': {
						'node':          'rand'
						'factor':        i+1
						'valueModifier': modVal
					},
					'meta': {
						'current':       i + 1,
						'total':         captionVals.length
						'source':        @sourceId,
						'sourceData':    photo
					}
				}

				influenceDataList.push influenceData

				EventDispatcher.trigger 'audanism/influence', influenceData

		influenceDataList = influenceDataList.filter (x) => x.node.valueModifier

		if influenceDataList.length > 0
			EventDispatcher.trigger 'audanism/influence/node/done', [influenceDataList]

		@jqxhr = null



window.Audanism.SourceAdapter.InstagramSourceAdapter = InstagramSourceAdapter 