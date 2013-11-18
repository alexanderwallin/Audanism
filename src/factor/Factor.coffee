###
	Factor
###
class Factor

	# Factor types
	@TYPE_UNKNOWN: 0
	@TYPE_OPENNESS: 1
	@TYPE_CONSCIENTIOUSNESS: 2
	@TYPE_EXTRAVERSION: 3
	@TYPE_AGREEABLENESS: 4
	@TYPE_NEUROTICISM: 5

	# Factor correlations. Duplicate matrix entries are commented out.
	@FACTOR_CORRELATIONS:
		'1': # Openness
			'2': -15
			'3': 25
		'2': # Conscientiousness
			#1: -15
			'3': 30
		'3': # Extraversion
			#1: 25
			#2: 30
			'4': 50
		'4': # Agreeableness
			#3: 50
			'5': -20
		#5: # Neuroticism
			#4: -20


	@createFactor: (factorType, factorValue = 0) ->
		switch factorType
			when Factor.TYPE_OPENNESS then new OpennessFactor()
			when Factor.TYPE_CONSCIENTIOUSNESS then new ConscientiousnessFactor()
			when Factor.TYPE_EXTRAVERSION then new ExtraversionFactor()
			when Factor.TYPE_AGREEABLENESS then new AgreeablenessFactor()
			when Factor.TYPE_NEUROTICISM then new NeuroticismFactor()
			else null

	# Constructor
	constructor: (@factorType, @factorValue = 0) ->

		# Meta
		@name = @constructor.name.replace /^(\w+)Factor$/, "$1"

		# Disharmony states
		@disharmony = 0
		@relativeDisharmony = []

	addValue: (value) ->
		@factorValue += value
		@factorValue = 0 if @factorValue < 0
		@factorValue = 100 if @factorValue > 100

	toString: () ->
		"<Factor ##{ @factorType } (#{ @name }); factorValue = #{ @factorValue }>"

window.Factor = Factor;