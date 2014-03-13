###
	Source adapter super class.

	A source adapater listens to any type of outer data feed
	and adapts it to data interpretable to the environment.
###
class SourceAdapter

	# Constructor
	constructor: (@sourceId, @interval = 5000) ->
		@active = false

	# Activates the source adapter. 
	activate: () ->
		@active = true

	# Deactivates/pauses the source adapter.
	deactivate: () ->
		@active = false

	# Sets the interval in which the source adapter fetches och listens for
	# new data
	setInterval: (@interval) ->

	# Adapts/translates the source data into data that the environment
	# understands.
	getAdaptedSourceData: (sourceData) ->
		influenceData =
			'factors': [{
				'factor':        null
				'valueModifier': null
				# 'factorExtension': {}
			}]
			'node': [{
				'node':          null
				'factorType':    null
				'valueModifier': 0
				# 'nodeModifier': {}
			}]
			'random': [{
				'object':        'node' # 'factor'
				'num':           [0, 1] # 123, 'rand'
				'valueModifier': [0, 1] # 123, 'rand'
			}]
		

	# Notifies the listener about the outer influence brought on by
	# the source.
	triggerInfluence: (influenceData) ->
		#console.log "!!!  Trigger influence:", influenceData, "on", @listener
		@listener.influence influenceData if @listener.influence?

window.Audanism.SourceAdapter.SourceAdapter = SourceAdapter