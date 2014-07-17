###
	GUI

	The GUI handles visual updates, statistics tables, controls and 
	their actions.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
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

		@$wiki              = $('#wiki')

		# Controls
		@_setupControls()

		# Wiki
		@_setupWiki()

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

	#
	# Add UI controls listeners
	#
	_setupControls: () ->
		$('#controls .btn').click (e) =>
			e.preventDefault()
			#$(e.currentTarget).addClass('active').siblings().removeClass('active')

			EventDispatcher.trigger 'audanism/controls/' + $(e.currentTarget).attr('href').replace("#", "")

		EventDispatcher.listen 'audanism/controls/start', @, () =>
			$('body').removeClass('paused').addClass('running')

		EventDispatcher.listen 'audanism/controls/pause audanism/controls/stop', @, () =>
			$('body').removeClass('running').addClass('paused')

		EventDispatcher.listen 'audanism/controls/toggleview', @, () =>
			$('body').toggleClass('clean-view')

		EventDispatcher.listen 'audanism/controls/togglesound', @, () =>
			$('body').toggleClass('muted')

	#
	# Wiki handler
	#
	_setupWiki: () ->
		$('#wiki').fadeTo(2000, 1.0)

		# Start btn
		$(document).on 'click', '#intro-btn-start', (e) =>
			e.preventDefault()
			EventDispatcher.trigger 'audanism/controls/start'
			@$wiki.fadeOut 500, () =>
				$('#intro-btn-start').html('Resume')

		# Wiki links
		$(document).on 'click', '[data-target-tab]', (e) =>
			e.preventDefault()
			@_setWikiContent($(e.currentTarget).attr('data-target-tab'))

		# Wiki toggle
		$(document).on 'click', '[data-toggle-wiki]', (e) =>
			e.preventDefault()
			action = $(e.currentTarget).attr('data-toggle-wiki')

			if action is 'show'
				@$wiki.fadeIn(500)
			else
				@$wiki.fadeOut(500)

	#
	# Sets the wiki content from a tab index
	#
	_setWikiContent: (tabIndex) =>
		if not @$wiki.is(':visible')
			@$wiki.fadeIn(500)

		# Show the tab
		$('.tab-content').removeClass('active').filter("[data-tab='#{ tabIndex }']").addClass('active')

		# Set active table of contents link
		@$wiki.find('a[data-target-tab]').removeClass('active').filter("[data-target-tab='#{ tabIndex }']").addClass('active')

	#
	# Display useless, but cozy information
	#
	_showCozyInfo: () ->
		hour = new Date().getHours()
		showSelector = ''

		switch hour
			when 23, 0, 1, 2, 3, 4, 5
				showSelector = 'night'
			when 5, 6, 7
				showSelector = 'early-morning'
			when 8, 9, 10
				showSelector = 'morning'
			when 11, 12, 13
				showSelector = 'midday'
			when 14, 15, 16, 17
				showSelector = 'afternoon'
			when 18, 19, 20, 21, 22
				showSelector = 'evening'

		#console.log(showSelector)
		$('.time-of-day').filter('.' + showSelector).show()

	#
	# Envinronment iteration handler
	#
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

	#
	# Display information about a node influence
	#
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

	#
	# Displays information about a factor influence
	#
	onInfluenceFactorAfter: (influenceInfo) ->
		#console.log('GUI #onInfluenceFactorAfter', influenceInfo)

		influenceBoxInfo

		if influenceInfo.meta.source is 'weather'
			influenceBoxInfo = {
				'source':  influenceInfo.meta.source
				'summary': influenceInfo.meta.summary
				'type':    'Factor ' + influenceInfo.factor.factor.factorType
			}

		if influenceBoxInfo
			@appendInfluenceBox influenceBoxInfo

	#
	# Appends an influence box to the influence feed.
	#
	appendInfluenceBox: (influenceBoxInfo) ->
		#console.log '#appendInfluenceBox', influenceBoxInfo

		$box = @$influenceTemplate.clone().attr('data-influence-source', influenceBoxInfo.source)

		$box.find('.influence-source').html(influenceBoxInfo.source);
		$box.find('.influence-summary').html(influenceBoxInfo.summary);
		$box.find('.influence-link').html($('<a />', { 'href':influenceBoxInfo.url, 'target':'_blank' }).html('Link'))
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

	#
	# Updates stress mode indicator when the mode has changed
	#
	onStressModeChange: (stressMode) ->
		@$organismStats.find('.stress-mode-indicator').toggleClass('stressed', stressMode)


window.Audanism.GUI.GUI = GUI