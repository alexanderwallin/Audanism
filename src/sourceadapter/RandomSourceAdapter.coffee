###
	Alters the factor and/or node values randomly
###
class RandomSourceAdapter extends Audanism.SourceAdapter.SourceAdapter

	@TIME_INTERVAL_ALTER_FACTORS: 2000
	@PROBABILITY_ALTER_FACTORS: 1

	@TIME_INTERVAL_ALTER_NODES: 500
	@PROBABILITY_ALTER_NODES: 1

	constructor: (@listener) ->
		#console.log "(RandomSourceAdapter) #constructor", @listener
		super(@listener)



	# Activates the source adapter. 
	activate: () ->
		#console.log "(RandomSourceAdapter) #activate"
		setInterval () =>
			@tryAlterFactors()
		, RandomSourceAdapter.TIME_INTERVAL_ALTER_FACTORS

		setInterval () =>
			@tryAlterNodes()
		, RandomSourceAdapter.TIME_INTERVAL_ALTER_NODES

	# Adapts/translates the source data into data that the environment
	# understands.
	getAdaptedSourceData: (sourceData) ->
		sourceData

	# 
	tryAlterFactors: () ->
		#console.log "(RandomSourceAdapter) #tryAlterFactors"

		# Probability check
		if Math.floor((Math.random() + 1) / RandomSourceAdapter.PROBABILITY_ALTER_FACTORS) is 1

			# Let the listener take care of which objects should me modified
			# and by how much
			@triggerInfluence {
				'random': {
					'object': 'factor'
					'num': 1
					'valueModifier': 'rand'
				}
			}

	#
	tryAlterNodes: () ->
		#console.log "(RandomSourceAdapter) #tryAlterNodes"

		# Probability check
		if Math.randomRange(Math.round(1 / RandomSourceAdapter.PROBABILITY_ALTER_NODES)) is 1
			#console.log "  (RandomSourceAdapter) perform node alteration"

			# Let the listener take care of which objects should me modified
			# and by how much
			@triggerInfluence {
				'random': {
					'object': 'node'
					'num': 'rand'
					'valueModifier': 'rand'
				}
			}



window.Audanism.SourceAdapter.RandomSourceAdapter = RandomSourceAdapter