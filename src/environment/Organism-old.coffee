###
Organism
###
class Organism

	# Options
	@NUM_FACTORS: 5
	@NUM_SOUNDS: 1
	@TIME_INTERVAL: 3000

	###
	Constructor
	###
	constructor: () ->

		# Create factors
		@_factorValues = ((0.01 * Math.floor(Math.random() * 100)) for i in [1..Organism.NUM_FACTORS])
		@_factors = (new Factor i, factorValue for factorValue, i in @_factorValues)

		# Create sounds
		@_sounds = (new Sound for i in [1..Organism.NUM_SOUNDS])

		console.log @_factors, @_sounds

		# GUI
		@createGUI()

		# Some data to represent the organism's state
		@state =
			disharmony: 0 			# A float between 0 and 1
			performedMutations: 0	# The number of performed mutations
			iterations: 0			# The number of iterations run
		@stateHistory = []			# History data used to render disharmony graph

		# Autorun?
		@__isInTherapy = false

		# Start therapy loop
		@therapyLoop()
	

	###
	Creates a (jQuery) GUI
	###
	createGUI: () ->
		@$factors = $("#factors")
		@$sounds = $("#sounds")
		@$state = $("#organism-state")

		# Factors
		for factor, i in @_factors
			factorEl = $("<div class='factor' data-factor='#{i}' data-factor-value='#{factor.factorValue}'><span class='factor-value'>#{factor.factorValue}</span></div>")
			factorEl
				.append =>
					"<span class='factor-modifier' data-factor-modifier='5' data-factor-target='#{ i }'>+</span>
					<span class='factor-modifier' data-factor-modifier='-5' data-factor-target='#{ i }'>-</span>"
				.find(".factor-modifier").on "click", (e) =>
					console.log "factor modifier clicked", e.target

					factorTarget = parseInt $(e.target).attr "data-factor-target"
					factorModifications = (0 for f in [1..@_factors.length])
					factorModifications[factorTarget] = parseInt $(e.target).attr "data-factor-modifier"

					$factorParent = $(e.target).parent()
					currentFactorValue = parseInt $factorParent.attr("data-factor-value")
					$factorParent.attr("data-factor-value", currentFactorValue + factorModifications[factorTarget])
					$factorParent.find(".factor-value").html( $factorParent.attr("data-factor-value") )

					@perceive factorModifications
				.end()
				.appendTo @$factors

			factor.$factorEl = factorEl

		# Sounds
		for sound, j in @_sounds
			bucketsHtml = ("<li>#{ factorValue }</li>" for factorValue in sound.getBucketValues())
			soundEl = $("<div class='sound' data-sound='#{ sound.soundId }' data-buckets='#{ JSON.toString sound.getBucketValues() }'></div>")
				.html "<ul class='sound-buckets'>#{ bucketsHtml.join "" }</ul>"
			soundEl.appendTo @$sounds
			sound.$soundEl = soundEl

		# Start/stop
		$("a").on 'click', (e) =>
			e.preventDefault()

			switch $(e.target).attr "href"
				when "#start" 	then @startTherapy()
				when "#stop" 	then @stopTherapy()

		google.setOnLoadCallback =>
			#console.log 'google.setOnLoadCallback'
			@$disharmonyChart = $("#disharmony-chart")

			@disharmonyChart = new google.visualization.LineChart @$disharmonyChart.get 0;

			$(document).on 'updategui.dm', =>
				@drawCharts()


	updateGUI: () ->
		(sound.updateSoundEl() for sound in @_sounds)

		# State and data
		@$state.html "Total disharmony: #{ @state.disharmony }<br />No. mutations: #{ @state.performedMutations }"

		$(document).trigger 'updategui.dm'

	drawCharts: () ->

		disharmonyData = @stateHistory.slice -300
		disharmonyData.unshift ['Iteration', 'Disharmony']

		data = google.visualization.arrayToDataTable disharmonyData

		options =
			title: 'Disharmony chart'
			#hAxis:
			#	viewWindowMode: 'explicit'
			#	viewWindow:
			#		max: 300
			vAxis:
				viewWindowMode: 'explicit'
				viewWindow:
					min: 0

		#console.log "@drawCharts --- stateHistory:", @stateHistory, "data:", data

		@disharmonyChart.draw data, options

	perceive: (factorModifications) ->

		console.log "@perceive", factorModifications

		# Stop therapy
		#@stopTherapy()

		# Update factor values
		@_factors[i].modifyValue valueDiff for valueDiff, i in factorModifications

		# Spread the modifications upon the nodes
		for modification, i in factorModifications
			if modification > 0
				modifiedSound = (SoundAdvisor.selectSounds @_sounds, 1)[0]
				modifiedSound.addBucketValue i, modification
				modifiedSound.updateSoundEl()
				console.log "modified sound", modifiedSound
			else if modification < 0
				console.log "subtract:", modification

				while modification < 0
					modifiedSound = (SoundAdvisor.selectSounds @_sounds, 1)[0]
					currentBucketValue = modifiedSound.getBucketValue i
					console.log "\tsubtracting from #{ modifiedSound.getString() }, current bucket:", currentBucketValue

					if currentBucketValue + modification >= 0
						modifiedSound.setBucketValue i, (currentBucketValue + modification)
						modification = 0
						console.log "\t\t-> #{modifiedSound.getString()} does the trick"
					else
						console.log "\t\tremove all from", modifiedSound.getString(), "(#{ i }) = #{modifiedSound.getBucketValue i}"
						modifiedSound.setBucketValue i, 0
						modification += currentBucketValue

					console.log "\t\t(modification left: #{modification})"

		@updateGUI()

		# Start therapy
		#@startTherapy()

	getTotalDisharmony: () ->
		disharmonies = (sound.getDisharmony() for sound in @_sounds)
		@state.disharmony = disharmonies.reduce (t, s) -> t + s
		@state.disharmony

	stopTherapy: () -> 
		@_isInTherapy = false

	startTherapy: () -> 
		@_isInTherapy = true

	therapyLoop: () ->
		setInterval =>
			@performTherapy()
		, Organism.TIME_INTERVAL
	
	performTherapy: () ->
		if @_isInTherapy
			for factor in @_factors
				HarmonyCalculator.calcFactorValueFromSounds factor.factorType, @_sounds

	performTherapyzzz: () ->
		if @_isInTherapy
			console.log "\n--- PERFORM THERAPY ---\n"

			soundsToCompare = SoundAdvisor.selectSounds @_sounds, 2
			#console.log "Sounds to compare:", (sound.getString() for sound in soundsToCompare), "\n"
			#console.log (sound.soundId for sound in soundsToCompare)

			$(".in-comparison").removeClass "in-comparison"
			sound.$soundEl.addClass "in-comparison" for sound in soundsToCompare

			currSoundDiffs = SoundAdvisor.getSoundDiffs soundsToCompare
			currSoundDiffsValue = SoundAdvisor.getTotalDiffsValue currSoundDiffs
			#console.log "\tThe current diff value sum from the compared sounds are: #{ currSoundDiffsValue }"

			# Get all potential actions to change the diffs and sort them,
			# lowest diff first
			potentialSoundDiffs = SoundAdvisor.getPotentialSoundDiffs soundsToCompare
			potentialSoundDiffs.sort (a, b) =>
				a.diffValueSum > b.diffValueSum

			potentialSoundDiffValues = (diff.diffValueSum for diff in potentialSoundDiffs)
			#console.log "potential sound diff values", potentialSoundDiffValues

			#console.log "before actions:", (sound.getString() for sound in soundsToCompare)

			if potentialSoundDiffs.length > 0
				console.log "-> Perform action", potentialSoundDiffs[0].actionKey, "on", soundsToCompare[0].getString(), "and", soundsToCompare[1].getString()
				actionInfo = potentialSoundDiffs[0].actionKey.split ":"
				
				console.log "\t\tAction info:", actionInfo

				actionNr = parseInt actionInfo[1], 10

				switch actionNr
					when 1
						soundsToCompare[0].addBucketValue actionInfo[0], -1
						soundsToCompare[1].addBucketValue actionInfo[0], 1
					when 2
						soundsToCompare[0].addBucketValue actionInfo[0], 1
						soundsToCompare[1].addBucketValue actionInfo[0], -1
					else
						console.log "\t\t\tactionNr (#{ actionNr }) is neither 1 nor 2"

				@state.performedMutations++
			else
				console.log "no action available"

			#console.log "after actions:", (sound.getString() for sound in soundsToCompare)

			@state.iterations++

			@stateHistory.push [@state.iterations, @getTotalDisharmony()]

			@updateGUI()

			#@stopTherapy()

window.Organism = Organism