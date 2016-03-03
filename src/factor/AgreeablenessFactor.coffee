
Factor = require './Factor.coffee'

class AgreeablenessFactor extends Factor

	constructor: () ->
		super(Factor.TYPE_AGREEABLENESS)

#window.Audanism.Factor.AgreeablenessFactor = AgreeablenessFactor

module.exports = AgreeablenessFactor