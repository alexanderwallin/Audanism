###
	Factor

	A factor a factor type and a value. They are used when calculating
	disharmonic relations to nodes sharing the same parent organism.

	@author Alexander Wallin
	@url    http://alexanderwallin.com
###

Utils = require '../util/utilities.coffee'

#OpennessFactor = require './OpennessFactor.coffee'
#ConscientiousnessFactor = require './ConscientiousnessFactor.coffee'
#ExtraversionFactor = require './ExtraversionFactor.coffee'
#AgreeablenessFactor = require './AgreeablenessFactor.coffee'
#NeuroticismFactor = require './NeuroticismFactor.coffee'

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

	#
	# Factor factory method
	#
	@createFactor: (factorType, factorValue = 0) ->
		switch factorType
			when Factor.TYPE_OPENNESS then new OpennessFactor()
			when Factor.TYPE_CONSCIENTIOUSNESS then new ConscientiousnessFactor()
			when Factor.TYPE_EXTRAVERSION then new ExtraversionFactor()
			when Factor.TYPE_AGREEABLENESS then new AgreeablenessFactor()
			when Factor.TYPE_NEUROTICISM then new NeuroticismFactor()
			else null

	#
	# Constructor
	#
	constructor: (@factorType, @factorValue) ->

		@factorValue = Utils.randomInt(10, 90) if not @factorValue

		# Meta
		@name = @constructor.name.replace /^(\w+)Factor$/, "$1"

		# Disharmony states
		@disharmony = 0
		@relativeDisharmony = []
		@disharmonyHistory = []

	#
	# Adds some value to the factor's value.
	#
	addValue: (value) ->
		@factorValue += value
		@factorValue = 0 if @factorValue < 0
		@factorValue = 100 if @factorValue > 100

	#
	# Adds a disharmony value to the factor's disharmony history.
	#
	setDisharmony: (disharmony) ->
		@disharmony = disharmony
		@disharmonyHistory.push disharmony

	#
	# Return a string representation of this factor
	#
	toString: () ->
		"<Factor ##{ @factorType } (#{ @name }); factorValue = #{ @factorValue }>"

#window.Audanism.Factor.Factor = Factor;
module.exports = Factor

class AgreeablenessFactor extends Factor
	constructor: () ->
		super(Factor.TYPE_AGREEABLENESS)

class ConscientiousnessFactor extends Factor
	constructor: () ->
		super(Factor.TYPE_CONSCIENTIOUSNESS)

class OpennessFactor extends Factor
	constructor: () ->
		super(Factor.TYPE_OPENNESS)

class ExtraversionFactor extends Factor
	constructor: () ->
		super(Factor.TYPE_EXTRAVERSION)

class NeuroticismFactor extends Factor
	constructor: () ->
		super(Factor.TYPE_NEUROTICISM)

