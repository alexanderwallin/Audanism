###
	GUI super class
###
class GUI

	# Constructor
	constructor: () ->

		# Cached jQuery objects
		@$organismStats     = $('#organism-stats')
		@$factorStats       = $('#factor-stats')
		
		@$influences        = $('#influences')
		@$influenceTemplate = @$influences.find('.template').clone(true).removeClass('template')
		@$influences.find('.template').hide()

		@$introPage         = $('#intro-page')

		# Controls
		@_setupControls()

		# Intro page
		@_setupIntroPage()

		# Some coziness in the stats sidebar
		@_showCozyInfo()

		# Event listeners
		EventDispatcher.listen 'audanism/iteration',              @, @onIteration
		EventDispatcher.listen 'audanism/influence/node/done',    @, @onInfluenceNodeDone
		EventDispatcher.listen 'audanism/influence/factor/after', @, @onInfluenceFactorAfter
		EventDispatcher.listen 'audanism/organism/stressmode',    @, @onStressModeChange

		###
		if google?
			google.setOnLoadCallback =>
				@$disharmonyChart = $("#disharmony-chart")
				@disharmonyChart = new google.visualization.LineChart @$disharmonyChart.get 0;
				#console.log 'google.setOnLoadCallback', @disharmonyChart
		###

	_setupControls: () ->
		$('#controls .btn').click (e) =>
			e.preventDefault()
			EventDispatcher.trigger 'audanism/controls/' + $(e.currentTarget).attr('href').replace("#", "")
			#$(document).trigger "dm#{ $(e.currentTarget).attr('href').replace("#", "") }"

		EventDispatcher.listen 'audanism/controls/start', @, () =>
		#$(document).on 'dmstart', (e) =>
			$('body').removeClass('paused').addClass('running')

		EventDispatcher.listen 'audanism/controls/pause audanism/controls/stop', @, () =>
		#$(document).on 'dmpause', (e) =>
			$('body').removeClass('running').addClass('paused')


	_setupIntroPage: () ->
		#console.log(@$introPage)
		$('#intro-content').fadeTo(2000, 1.0)

		$(document).on 'click', '#intro-btn-start', (e) =>
			e.preventDefault()
			EventDispatcher.trigger 'audanism/controls/start'
			@$introPage.fadeOut 500


	_showCozyInfo: () ->
		hour = new Date().getHours()
		showSelector = ''

		switch hour
			when 23, 0, 1, 2, 3, 4, 5
				showSelector = 'night'
			when 6, 7, 8
				showSelector = 'early-morning'
			when 9, 10, 11
				showSelector = 'morning'
			when 12, 13, 14, 15
				showSelector = 'midday'
			when 16, 17, 18, 19
				showSelector = 'afternoon'
			when 20, 21, 22
				showSelector = 'evening'

		#console.log(showSelector)
		$('.time-of-day').filter('.' + showSelector).show()


	onIteration: (iterationInfo) ->
		#console.log('GUI #onIteration', @$organismStats)
		
		organism = iterationInfo.organism

		# Organism disharmony
		disharmony = organism.getDisharmonyHistoryData( 1 )
		@$organismStats.find('#summed-disharmony .value').html(Math.round(organism._sumDisharmony)).end().find('#actual-disharmony .value').html(Math.round(organism._actualDisharmony)).end()

		# Factor stats
		$factorValues = @$factorStats.find('#factor-values')
		$factorDish   = @$factorStats.find('#factor-disharmonies')
		for factor in organism.getFactors()
			$factorValues.find('[data-factor="' + factor.factorType + '"]').html(decimalAdjust('round', factor.factorValue, -1))
			$factorDish.find('[data-factor="' + factor.factorType + '"]').html(numberSuffixed(factor.disharmony, -1))


	onInfluenceNodeDone: (influenceInfoList) ->
		#console.log('GUI #onInfluenceNodeAfter', influenceInfoList)

		influenceBoxInfo

		influenceEntry = influenceInfoList[0]

		if influenceEntry.meta.source is 'instagram'
			photo = influenceEntry.meta.sourceData

			influenceBoxInfo = {
				'source':  influenceEntry.meta.source
				'summary': '<img src="' + photo.images.thumbnail.url + '" /><span class="caption">' + photo.caption.text.substring(0, 30) + '</span>'
				'url':     photo.link
				'type':    'Nodes'
				'value':   null
			}

		if influenceBoxInfo
			@appendInfluenceBox influenceBoxInfo


	onInfluenceFactorAfter: (influenceInfo) ->
		#console.log('GUI #onInfluenceFactorAfter', influenceInfo)

		influenceBoxInfo

		if influenceInfo.meta.source = 'yr.no'
			influenceBoxInfo = {
				'source':  influenceInfo.meta.source
				'summary': influenceInfo.meta.summary
				'type':    'Factor ' + influenceInfo.factor.factor.factorType
			}

		if influenceBoxInfo
			@appendInfluenceBox influenceBoxInfo


	appendInfluenceBox: (influenceBoxInfo) ->
		$box = @$influenceTemplate.clone()#.css('opacity', 0)

		$box.find('.influence-source').html(influenceBoxInfo.source);
		$box.find('.influence-summary').html(influenceBoxInfo.summary);
		$box.find('.influence-link').html($('<a />', { 'href':influenceBoxInfo.url }).html('Link'))
		$box.find('.influence-type').html(influenceBoxInfo.type)
		$box.find('.influence-value').html(influenceBoxInfo.value || '')

		@$influences.append($box)
		$box.show() #.fadeTo(300, 1.0)

		$boxes = @$influences.find('.influence')
		numBoxes = $boxes.size()
		if numBoxes > 6
			@$influences.find('.influence').filter(() ->
				return $boxes.index(@) < numBoxes - 6
			).hide()#.animate({ 'opacity':0, 'height':0, 'margin-bottom':0 }, 300, () ->
			#	$(@).hide()
			#)

	onStressModeChange: (stressMode) ->
		@$organismStats.find('.stress-mode-indicator').toggleClass('stressed', stressMode)

window.Audanism.GUI.GUI = GUI