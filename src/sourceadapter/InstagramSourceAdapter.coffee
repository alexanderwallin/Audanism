###
	Listens for Instagram pictures.
###
class InstagramSourceAdapter extends SourceAdapter

	# Constructor
	constructor: (@listener) ->
		super(@listener)

		# Query params
		@clientId = "f42a4ce0632e412ea5a0353c2b5e581f"
		@photoSinceId = 0
		@tag = if window.location.anchro then window.location.anchor.replace(/^(.*?)instatag=([^&]+)(.*)$/, "$1") || "belieber" else "belieber"
		@queryUrl = "https://api.instagram.com/v1/tags/#{ @tag }/media/recent"

		# Ajax handler
		@jqxhr = null

		# Instagram GUI
		@igGui = $('<div />', { 'id':'ig-photo' }).append('<img class="ig-photo" src="" /><span class="ig-caption">').appendTo($('#container'))


	# Sets up mouse event listeners
	activate: () ->
		#console.log('ISA activate')

		_this = @
		_queryPhotos = @queryPhotos

		setInterval () =>
			@queryPhotos.call _this
		, 3000


	# Performs a query for photos
	queryPhotos: () ->
		#console.log('••• query instagram photots', @queryUrl, '•••')

		if (@jqxhr)
			return

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

		#	console.log 'instagram data', data

		#$(document).on 'didLoadInstagram', (event, response) =>
		#	console.log('didLoadInstagram', response)

		#$(document).instagram {
		#	'hash': 'belieber'
		#	'clientId': @clientId
		#}
	

	# Process photos
	processPhotos: (photos) ->
		#console.log('••• parse instagram photos •••')

		interpreter = new TextInterpreter

		for photo in photos

			# Store since id
			if (photo.id is @photoSinceId)
				#console.log('   ## same photo, continue')
				continue

			@photoSinceId = photo.id

			# Get caption
			if (!photo.caption)
				#console.log('   ## no caption, continue')
				continue

			caption = photo.caption.text

			# Update IG GUI
			@igGui.find('.ig-photo').attr('src', photo.images.thumbnail.url)
			@igGui.find('.ig-caption').html(caption)
			@igGui.fadeTo(50, 1)
			setTimeout () =>
				@igGui.fadeTo(1000, 0)
			, 2000

			# Get values
			captionVals = interpreter.getNumCharsInGroups caption, 5
			#console.log('vals for text', caption, captionVals)

			# Trigger alteration
			for i in [0..captionVals.length-1]

				if not captionVals[i]
					continue

				modVal = Math.round captionVals[i] * 20
				modVal = if Math.random() >= 0.5 then modVal * -1 else modVal

				influenceData = {
					'node': {
						'node':          'rand'
						'factor':        i+1
						'valueModifier': modVal
					},
					'meta': {
						'current':       i + 1,
						'total':         captionVals.length
						'source':        'instagram',
						'sourceData':    photo
					}
				}
				#console.log('....... influence data', influenceData)

				#@triggerInfluence influenceData

				EventDispatcher.trigger 'audanism/influence', influenceData

		@jqxhr = null



	# Adapts data into environment interpretable data
	adaptSourceData: () ->



window.InstagramSourceAdapter = InstagramSourceAdapter 